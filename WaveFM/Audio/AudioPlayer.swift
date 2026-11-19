import Foundation
import AVFoundation
import MediaPlayer

@MainActor
final class AudioPlayer: ObservableObject {
    @Published var current: Station?
    @Published var isPlaying = false
    @Published var isBuffering = false
    @Published var statusMessage: String?
    @Published var volume: Float = 0.8 {
        didSet { player.volume = volume }
    }

    private let player = AVPlayer()
    private var statusObservation: NSKeyValueObservation?
    private var bufferObservation: NSKeyValueObservation?
    private var rateObservation: NSKeyValueObservation?
    private var timeoutTask: Task<Void, Never>?
    private var hasConfiguredSession = false
    private var activeID: String?

    // MARK: - 生命周期

    func configure() {
        player.volume = volume
        setupAudioSession()
        setupRemoteCommands()
        rateObservation = player.observe(\.rate, options: [.initial, .new]) { [weak self] player, _ in
            Task { @MainActor in
                self?.isPlaying = player.rate > 0.01
            }
        }
    }

    // MARK: - 播放控制

    func play(_ station: Station) {
        guard let url = URL(string: station.url) else {
            statusMessage = "音源地址无效"
            return
        }

        if current?.id == station.id {
            toggle()
            return
        }

        // 清理上一次播放的观察与超时
        timeoutTask?.cancel()
        statusObservation?.invalidate()
        bufferObservation?.invalidate()
        player.pause()

        activeID = station.id
        current = station
        isBuffering = true
        statusMessage = nil
        // 首次点击时确保音频会话已激活（configure 的 .task 可能有竞态）
        setupAudioSession()
        updateNowPlayingInfo(for: station)

        let item = AVPlayerItem(url: url)

        // ★ 关键修复：必须先把 item 挂到 player 上，AVPlayerItem 才会真正发起网络加载。
        //   旧版先观察 status 再挂载，孤立的 item 会永远停在 .unknown → 一直转圈。
        player.replaceCurrentItem(with: item)

        statusObservation = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            Task { @MainActor in
                guard let self, self.activeID == station.id else { return }
                switch item.status {
                case .readyToPlay:
                    self.isBuffering = false
                    self.statusMessage = nil
                    self.timeoutTask?.cancel()
                    self.player.play()
                case .failed:
                    self.isBuffering = false
                    let detail = item.error?.localizedDescription ?? "未知错误"
                    self.statusMessage = "连接失败：\(detail)"
                case .unknown:
                    self.isBuffering = true
                @unknown default:
                    break
                }
            }
        }

        // 缓冲恢复后自动继续播放（直播流网络抖动时有用）
        bufferObservation = item.observe(\.playbackLikelyToKeepUp, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                guard let self, self.activeID == station.id else { return }
                if item.isPlaybackLikelyToKeepUp,
                   item.status == .readyToPlay,
                   self.player.rate < 0.01 {
                    self.player.play()
                }
            }
        }

        // 20 秒超时：避免无限转圈，并给出明确诊断信息
        timeoutTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 20_000_000_000)
            guard !Task.isCancelled, self.activeID == station.id else { return }
            if item.status != .readyToPlay {
                self.isBuffering = false
                self.statusMessage = "连接超时：无法访问该音源，请检查网络或切换其他电台"
            }
        }
    }

    func toggle() {
        guard current != nil else { return }
        if isPlaying {
            player.pause()
        } else {
            setupAudioSession()
            player.play()
        }
    }

    func stop() {
        timeoutTask?.cancel()
        statusObservation?.invalidate()
        bufferObservation?.invalidate()
        player.pause()
        player.replaceCurrentItem(with: nil)
        activeID = nil
        current = nil
        isPlaying = false
        isBuffering = false
        statusMessage = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    // MARK: - 会话与锁屏控制

    private func setupAudioSession() {
        guard !hasConfiguredSession else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
            hasConfiguredSession = true
        } catch {
            statusMessage = "音频会话初始化失败：\(error.localizedDescription)"
        }
    }

    private func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                guard let self, self.current != nil else { return }
                self.setupAudioSession()
                self.player.play()
            }
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.player.pause() }
            return .success
        }
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.toggle() }
            return .success
        }
        center.nextTrackCommand.isEnabled = false
        center.previousTrackCommand.isEnabled = false
    }

    private func updateNowPlayingInfo(for station: Station) {
        let info: [String: Any] = [
            MPMediaItemPropertyTitle: station.name,
            MPMediaItemPropertyArtist: station.desc,
            MPMediaItemPropertyAlbumTitle: station.group,
            MPNowPlayingInfoPropertyIsLiveStream: true,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0
        ]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}

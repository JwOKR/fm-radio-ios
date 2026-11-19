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
    private var rateObservation: NSKeyValueObservation?
    private var timeObserver: Any?
    private var hasConfiguredSession = false

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

        statusObservation?.invalidate()
        player.pause()
        current = station
        isBuffering = true
        statusMessage = nil
        updateNowPlayingInfo(for: station)

        let item = AVPlayerItem(url: url)
        statusObservation = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            Task { @MainActor in
                guard let self, self.current?.id == station.id else { return }
                switch item.status {
                case .readyToPlay:
                    self.isBuffering = false
                    self.player.replaceCurrentItem(with: item)
                    self.player.play()
                case .failed:
                    self.isBuffering = false
                    self.statusMessage = "无法连接该电台，请切换其他音源"
                default:
                    self.isBuffering = true
                }
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
        player.pause()
        player.replaceCurrentItem(with: nil)
        statusObservation?.invalidate()
        current = nil
        isPlaying = false
        isBuffering = false
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

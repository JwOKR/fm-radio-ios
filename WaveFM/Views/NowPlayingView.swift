import SwiftUI

struct NowPlayingView: View {
    @EnvironmentObject var player: AudioPlayer
    @EnvironmentObject var store: StationStore
    @Environment(\.dismiss) private var dismiss

    private var station: Station? { player.current }
    private var accent: Color { Theme.color(hex: station?.color ?? "7B7BFF") }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [accent.opacity(0.55), Theme.background, Theme.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部栏
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Theme.text)
                    }
                    Spacer()
                    Text("正在播放")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                    if let station {
                        Button { store.toggleFavorite(station) } label: {
                            Image(systemName: store.isFavorite(station) ? "star.fill" : "star")
                                .font(.system(size: 18))
                                .foregroundStyle(store.isFavorite(station) ? .yellow : Theme.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 12)

                Spacer()

                if let station {
                    // 封面 + 声波
                    ZStack {
                        RoundedRectangle(cornerRadius: 26)
                            .fill(LinearGradient(colors: [accent.opacity(0.9), accent.opacity(0.35)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                        Image(systemName: categoryIcon(station.category))
                            .font(.system(size: 76, weight: .light))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .frame(width: 220, height: 220)
                    .shadow(color: accent.opacity(0.4), radius: 30, y: 12)
                    .overlay(alignment: .bottom) {
                        WaveformView(color: .white, active: player.isPlaying)
                            .frame(width: 120)
                            .padding(.bottom, -30)
                    }

                    VStack(spacing: 8) {
                        Text(station.name)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(Theme.text)
                        Text(station.desc)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, 46)

                    // 直播 / 缓冲状态
                    HStack(spacing: 6) {
                        if player.isBuffering {
                            ProgressView().scaleEffect(0.7)
                            Text("连接中…").foregroundStyle(Theme.textSecondary)
                        } else if player.isPlaying {
                            Circle().fill(Color.red).frame(width: 7, height: 7)
                            Text("直播中").foregroundStyle(.red)
                        } else {
                            Text("已暂停").foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .font(.system(size: 12, weight: .medium))
                    .padding(.top, 14)

                    if let message = player.statusMessage {
                        Text(message)
                            .font(.system(size: 12))
                            .foregroundStyle(.orange)
                            .padding(.top, 6)
                    }

                    Spacer()

                    // 控制区
                    VStack(spacing: 18) {
                        HStack(spacing: 46) {
                            Button { player.stop() } label: {
                                Image(systemName: "stop.circle")
                                    .font(.system(size: 30))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            Button { player.toggle() } label: {
                                ZStack {
                                    Circle().fill(.white)
                                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 30, weight: .semibold))
                                        .foregroundStyle(Theme.background)
                                        .padding(.leading, player.isPlaying ? 0 : 3)
                                }
                            }
                            .frame(width: 76, height: 76)
                            .buttonStyle(.plain)
                            Button {
                                if let station { store.toggleFavorite(station) }
                            } label: {
                                Image(systemName: store.isFavorite(station) ? "star.fill" : "star")
                                    .font(.system(size: 28))
                                    .foregroundStyle(store.isFavorite(station) ? Color.yellow : Theme.textSecondary)
                            }
                        }
                        .buttonStyle(.plain)

                        HStack(spacing: 10) {
                            Image(systemName: "speaker.fill").foregroundStyle(Theme.textSecondary)
                            Slider(value: $player.volume, in: 0...1)
                                .tint(accent)
                            Image(systemName: "speaker.wave.3.fill").foregroundStyle(Theme.textSecondary)
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(.horizontal, 32)
                } else {
                    Text("未选择电台").foregroundStyle(Theme.textSecondary)
                }

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}

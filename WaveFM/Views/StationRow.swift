import SwiftUI

struct StationRow: View {
    let station: Station
    let isCurrent: Bool
    let isPlaying: Bool
    let isFavorite: Bool
    let onPlay: () -> Void
    let onFavorite: () -> Void

    private var accent: Color { Theme.color(hex: station.color) }

    var body: some View {
        HStack(spacing: 13) {
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(accent.opacity(isCurrent ? 0.28 : 0.14))
                Image(systemName: categoryIcon(station.category))
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(accent)
            }
            .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(station.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.text)
                    if isCurrent && isPlaying {
                        WaveformView(color: accent, active: true)
                            .frame(width: 18)
                    }
                }
                Text(station.desc)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Button(action: onFavorite) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.system(size: 16))
                    .foregroundStyle(isFavorite ? Color.yellow : Theme.textSecondary)
            }
            .buttonStyle(.plain)
            .frame(width: 30)

            Button(action: onPlay) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.18))
                    Image(systemName: isCurrent && isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(accent)
                        .padding(.leading, isCurrent && isPlaying ? 0 : 2)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 34, height: 34)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .background(isCurrent ? Theme.surfaceLight : Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

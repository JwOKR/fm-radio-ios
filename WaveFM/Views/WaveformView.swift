import SwiftUI

/// 声波动画，播放时跳动，暂停时静止
struct WaveformView: View {
    let color: Color
    let active: Bool
    @State private var phase: CGFloat = 0
    private let bars: [CGFloat] = [0.4, 0.7, 1.0, 0.6, 0.85, 0.5, 0.9, 0.35, 0.75, 0.55, 0.95, 0.45]

    var body: some View {
        HStack(spacing: 2.5) {
            ForEach(bars.indices, id: \.self) { i in
                Capsule()
                    .fill(color)
                    .frame(width: 3, height: barHeight(i))
            }
        }
        .frame(height: 22)
        .onAppear {
            if active {
                withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: true)) {
                    phase = 1
                }
            }
        }
        .onChange(of: active) { _, newValue in
            if newValue {
                withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: true)) {
                    phase = 1
                }
            } else {
                phase = 0
            }
        }
    }

    private func barHeight(_ i: Int) -> CGFloat {
        let base = bars[i] * 20
        let animated = active ? base * (0.45 + 0.55 * abs(sin(phase * .pi * 2 + CGFloat(i) * 0.7))) : base * 0.35
        return max(4, animated)
    }
}

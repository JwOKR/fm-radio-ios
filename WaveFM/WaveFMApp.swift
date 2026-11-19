import SwiftUI

@main
struct WaveFMApp: App {
    @StateObject private var store = StationStore()
    @StateObject private var player = AudioPlayer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(player)
                .task {
                    await MainActor.run { player.configure() }
                }
        }
    }
}

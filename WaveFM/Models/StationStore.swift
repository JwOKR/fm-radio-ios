import Foundation

final class StationStore: ObservableObject {
    @Published var stations: [Station] = []
    @Published var favoriteIDs: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(favoriteIDs), forKey: "wavefm.favorites")
        }
    }

    private static let favoritesKey = "wavefm.favorites"

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: Self.favoritesKey) ?? []
        favoriteIDs = Set(saved)
        stations = Self.loadBundledStations()
    }

    func isFavorite(_ station: Station) -> Bool {
        favoriteIDs.contains(station.id)
    }

    func toggleFavorite(_ station: Station) {
        if favoriteIDs.contains(station.id) {
            favoriteIDs.remove(station.id)
        } else {
            favoriteIDs.insert(station.id)
        }
    }

    private static func loadBundledStations() -> [Station] {
        guard let url = Bundle.main.url(forResource: "stations", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let list = try? JSONDecoder().decode([Station].self, from: data) else {
            return []
        }
        return list
    }
}

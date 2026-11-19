import Foundation

struct Station: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let desc: String
    let group: String
    let category: String
    let url: String
    let color: String
}

import Foundation
import SwiftUI

enum Theme {
    static let background = Color(red: 0.06, green: 0.07, blue: 0.12)
    static let surface = Color(red: 0.11, green: 0.12, blue: 0.18)
    static let surfaceLight = Color(red: 0.16, green: 0.17, blue: 0.24)
    static let primary = Color(red: 0.45, green: 0.45, blue: 1.0)
    static let text = Color.white
    static let textSecondary = Color.white.opacity(0.55)

    static func color(hex: String) -> Color {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        return Color(red: r, green: g, blue: b)
    }
}

let categoryOrder = ["全部", "新闻资讯", "音乐", "文化", "国际", "其他"]

func categoryIcon(_ category: String) -> String {
    switch category {
    case "新闻资讯": return "newspaper.fill"
    case "音乐": return "music.note"
    case "文化": return "book.fill"
    case "国际": return "globe.americas.fill"
    default: return "dot.radiowaves.left.and.right"
    }
}

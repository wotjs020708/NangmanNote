import Foundation

enum InputMode: String, Codable, Sendable, CaseIterable {
    case auto
    case manual
}

enum ProcessMethod: String, Codable, Sendable, CaseIterable {
    case washed
    case natural
    case honey
    case anaerobic
    case redHoney
    case other
}

enum RoastLevel: String, Codable, Sendable, CaseIterable {
    case light
    case mediumLight
    case medium
    case mediumDark
    case dark
}

enum NoteCategory: String, Codable, Sendable, CaseIterable {
    case fruit
    case floral
    case nut
    case chocolate
    case spice
    case sweet
    case earthy
    case other
}

enum FrontBackgroundType: Codable, Sendable, Equatable {
    case solid(hex: String)
    case gradient(from: String, to: String)
    case photo(path: String)
}

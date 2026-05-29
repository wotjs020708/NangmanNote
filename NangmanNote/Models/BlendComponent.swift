import Foundation
import SwiftData

@Model
final class BlendComponent {
    @Attribute(.unique) var id: UUID
    var country: String
    var region: String?
    var variety: String?
    var processRaw: String?
    var ratio: Int?

    var card: CoffeeCard?

    init(
        id: UUID = UUID(),
        country: String,
        region: String? = nil,
        variety: String? = nil,
        process: ProcessMethod? = nil,
        ratio: Int? = nil
    ) {
        self.id = id
        self.country = country
        self.region = region
        self.variety = variety
        self.processRaw = process?.rawValue
        self.ratio = ratio
    }

    var process: ProcessMethod? {
        get { processRaw.flatMap(ProcessMethod.init(rawValue:)) }
        set { processRaw = newValue?.rawValue }
    }

    /// "Ethiopia · Red Honey · 65%" 형태 한 줄 요약
    var summary: String {
        var parts: [String] = [country]
        if let variety { parts.append(variety) }
        if let process { parts.append(process.rawValue) }
        if let ratio { parts.append("\(ratio)%") }
        return parts.joined(separator: " · ")
    }
}

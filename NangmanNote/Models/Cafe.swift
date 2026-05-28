import Foundation
import SwiftData
import CoreLocation

@Model
final class Cafe {
    @Attribute(.unique) var id: UUID
    var name: String
    var latitude: Double?
    var longitude: Double?
    var address: String?

    @Relationship(inverse: \CoffeeCard.cafe) var cards: [CoffeeCard] = []

    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        address: String? = nil
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

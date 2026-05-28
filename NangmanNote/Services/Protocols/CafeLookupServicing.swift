import Foundation
import CoreLocation

protocol CafeLookupServicing: Sendable {
    func search(name: String, near: CLLocationCoordinate2D?) async throws -> [CafeCandidate]
}

struct CafeCandidate: Sendable, Identifiable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?
    let distance: CLLocationDistance?

    init(
        id: UUID = UUID(),
        name: String,
        coordinate: CLLocationCoordinate2D,
        address: String? = nil,
        distance: CLLocationDistance? = nil
    ) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.address = address
        self.distance = distance
    }
}

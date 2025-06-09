import Foundation
import CoreLocation

struct WalkRoute {
    let id = UUID()
    let waypoints: [CLLocationCoordinate2D]
    let estimatedDuration: TimeInterval
    let totalDistance: Double
    let startLocation: CLLocationCoordinate2D
}

import Foundation
import CoreLocation

struct WalkParameters {
    let duration: TimeInterval
    let startLocation: CLLocationCoordinate2D
    let walkingSpeed: Double // meters per second
    
    var estimatedDistance: Double {
        return duration * walkingSpeed
    }
}

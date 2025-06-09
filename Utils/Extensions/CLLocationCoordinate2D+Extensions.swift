import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    /// Calculate a new coordinate at a given distance and bearing from current coordinate
    func coordinate(atDistance distance: Double, bearing: Double) -> CLLocationCoordinate2D {
        let earthRadius = 6371000.0 // Earth radius in meters
        let lat1 = latitude * .pi / 180
        let lon1 = longitude * .pi / 180
        let bearingRad = bearing * .pi / 180
        
        let lat2 = asin(sin(lat1) * cos(distance / earthRadius) +
                       cos(lat1) * sin(distance / earthRadius) * cos(bearingRad))
        let lon2 = lon1 + atan2(sin(bearingRad) * sin(distance / earthRadius) * cos(lat1),
                               cos(distance / earthRadius) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(
            latitude: lat2 * 180 / .pi,
            longitude: lon2 * 180 / .pi
        )
    }
    
    /// Calculate distance between two coordinates in meters
    func distance(to coordinate: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: latitude, longitude: longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location1.distance(from: location2)
    }
}

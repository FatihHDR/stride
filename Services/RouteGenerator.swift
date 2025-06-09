import Foundation
import CoreLocation

class RouteGenerator {
    
    enum RouteGeneratorError: Error {
        case invalidParameters
        case routeGenerationFailed
        
        var localizedDescription: String {
            switch self {
            case .invalidParameters:
                return "Invalid walk parameters provided"
            case .routeGenerationFailed:
                return "Failed to generate walking route"
            }
        }
    }
    
    func generateRoute(parameters: WalkParameters) async throws -> WalkRoute {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        guard parameters.duration > 0 && parameters.estimatedDistance > 0 else {
            throw RouteGeneratorError.invalidParameters
        }
        
        let waypoints = generateRandomWaypoints(
            from: parameters.startLocation,
            distance: parameters.estimatedDistance
        )
        
        return WalkRoute(
            waypoints: waypoints,
            estimatedDuration: parameters.duration,
            totalDistance: parameters.estimatedDistance,
            startLocation: parameters.startLocation
        )
    }
    
    private func generateRandomWaypoints(from start: CLLocationCoordinate2D, distance: Double) -> [CLLocationCoordinate2D] {
        var waypoints = [start]
        var currentLocation = start
        let segmentDistance = 100.0 // meters per segment
        let segments = max(Int(distance / segmentDistance), 4) // minimum 4 segments
        
        for _ in 0..<segments {
            // Generate random bearing (0-360 degrees)
            let bearing = Double.random(in: 0...360)
            let newLocation = currentLocation.coordinate(
                atDistance: segmentDistance,
                bearing: bearing
            )
            waypoints.append(newLocation)
            currentLocation = newLocation
        }
        
        // Add return path to start (create a loop)
        waypoints.append(start)
        return waypoints
    }
}

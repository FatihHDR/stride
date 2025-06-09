import Foundation
import CoreLocation

// Demo data for showcasing Stride's capabilities
struct DemoData {
    
    // Sample locations for testing multi-location walks
    static let sampleLocations: [WalkLocation] = [
        WalkLocation(
            name: "Central Park",
            coordinate: CLLocationCoordinate2D(latitude: 40.785091, longitude: -73.968285),
            address: "New York, NY 10024",
            type: .search
        ),
        WalkLocation(
            name: "Times Square",
            coordinate: CLLocationCoordinate2D(latitude: 40.758896, longitude: -73.985130),
            address: "Times Square, Manhattan, NY 10036",
            type: .search
        ),
        WalkLocation(
            name: "Brooklyn Bridge",
            coordinate: CLLocationCoordinate2D(latitude: 40.706086, longitude: -73.996864),
            address: "Brooklyn Bridge, New York, NY 10038",
            type: .search
        ),
        WalkLocation(
            name: "High Line",
            coordinate: CLLocationCoordinate2D(latitude: 40.748817, longitude: -74.004015),
            address: "High Line, New York, NY 10014",
            type: .search
        )
    ]
    
    // Sample public walks for demonstration
    static let samplePublicWalks: [SharedWalk] = [
        SharedWalk(
            walk: MultiLocationWalk(
                name: "NYC Highlights Tour",
                locations: [sampleLocations[0], sampleLocations[1], sampleLocations[2]],
                routes: [],
                totalDistance: 8500.0,
                estimatedDuration: 6000.0,
                createdAt: Date().addingTimeInterval(-86400 * 7), // 1 week ago
                createdBy: "NYC Explorer",
                isPublic: true
            ),
            shareCode: "NYC12345",
            sharedAt: Date().addingTimeInterval(-86400 * 7),
            downloadCount: 234,
            rating: 4.7,
            reviews: [
                WalkReview(
                    userName: "WalkingFan",
                    rating: 5,
                    comment: "Amazing route! Perfect for tourists.",
                    createdAt: Date().addingTimeInterval(-86400 * 3)
                ),
                WalkReview(
                    userName: "LocalGuide",
                    rating: 4,
                    comment: "Great walk, but can be crowded during peak hours.",
                    createdAt: Date().addingTimeInterval(-86400 * 1)
                )
            ]
        ),
        SharedWalk(
            walk: MultiLocationWalk(
                name: "Hidden Gems Walking Tour",
                locations: [sampleLocations[3], sampleLocations[0]],
                routes: [],
                totalDistance: 3200.0,
                estimatedDuration: 2400.0,
                createdAt: Date().addingTimeInterval(-86400 * 3),
                createdBy: "Hidden NYC",
                isPublic: true
            ),
            shareCode: "HIDDEN99",
            sharedAt: Date().addingTimeInterval(-86400 * 3),
            downloadCount: 87,
            rating: 4.9,
            reviews: [
                WalkReview(
                    userName: "AdventureSeeker",
                    rating: 5,
                    comment: "Discovered places I never knew existed!",
                    createdAt: Date().addingTimeInterval(-86400 * 2)
                )
            ]
        ),
        SharedWalk(
            walk: MultiLocationWalk(
                name: "Morning Fitness Circuit",
                locations: Array(sampleLocations.prefix(2)),
                routes: [],
                totalDistance: 5000.0,
                estimatedDuration: 3600.0,
                createdAt: Date().addingTimeInterval(-86400 * 1),
                createdBy: "FitWalker",
                isPublic: true
            ),
            shareCode: "FIT2024X",
            sharedAt: Date().addingTimeInterval(-86400 * 1),
            downloadCount: 45,
            rating: 4.3,
            reviews: []
        )
    ]
    
    // Sample walk parameters for testing
    static let sampleWalkParameters: [WalkParameters] = [
        WalkParameters(
            duration: 900, // 15 minutes
            startLocation: CLLocationCoordinate2D(latitude: 40.7829, longitude: -73.9654),
            walkingSpeed: 1.4
        ),
        WalkParameters(
            duration: 1800, // 30 minutes
            startLocation: CLLocationCoordinate2D(latitude: 40.7829, longitude: -73.9654),
            walkingSpeed: 1.4
        ),
        WalkParameters(
            duration: 3600, // 60 minutes
            startLocation: CLLocationCoordinate2D(latitude: 40.7829, longitude: -73.9654),
            walkingSpeed: 1.4
        )
    ]
    
    // Helper method to generate sample routes
    static func generateSampleRoute(for parameters: WalkParameters) -> WalkRoute {
        let waypoints = generateSampleWaypoints(from: parameters.startLocation, distance: parameters.estimatedDistance)
        
        return WalkRoute(
            waypoints: waypoints,
            estimatedDuration: parameters.duration,
            totalDistance: parameters.estimatedDistance,
            startLocation: parameters.startLocation
        )
    }
    
    private static func generateSampleWaypoints(from start: CLLocationCoordinate2D, distance: Double) -> [CLLocationCoordinate2D] {
        var waypoints = [start]
        var currentLocation = start
        let segmentDistance = 100.0
        let segments = max(Int(distance / segmentDistance), 4)
        
        for i in 0..<segments {
            let bearing = Double(i * 45) // Vary direction for interesting shape
            let newLocation = currentLocation.coordinate(
                atDistance: segmentDistance,
                bearing: bearing
            )
            waypoints.append(newLocation)
            currentLocation = newLocation
        }
        
        // Return to start
        waypoints.append(start)
        return waypoints
    }
}

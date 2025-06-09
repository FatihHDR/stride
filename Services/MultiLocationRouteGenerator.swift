import Foundation
import CoreLocation
import MapKit

class MultiLocationRouteGenerator {
    
    enum MultiRouteError: Error, LocalizedError {
        case invalidLocations
        case routeGenerationFailed
        case tooManyLocations
        
        var errorDescription: String? {
            switch self {
            case .invalidLocations:
                return "Please provide at least 2 valid locations"
            case .routeGenerationFailed:
                return "Failed to generate routes between locations"
            case .tooManyLocations:
                return "Maximum 10 locations allowed"
            }
        }
    }
    
    struct RouteOptions {
        let transportType: MKDirectionsTransportType
        let routeType: RouteType
        let optimizeOrder: Bool
        
        enum RouteType {
            case direct // Direct routes between locations
            case loop // Create a loop returning to start
            case exploring // Add exploring segments between locations
        }
    }
    
    func generateMultiLocationWalk(
        name: String,
        locations: [WalkLocation],
        options: RouteOptions = RouteOptions(
            transportType: .walking,
            routeType: .direct,
            optimizeOrder: false
        ),
        createdBy: String,
        isPublic: Bool = false
    ) async throws -> MultiLocationWalk {
        
        guard locations.count >= 2 else {
            throw MultiRouteError.invalidLocations
        }
        
        guard locations.count <= 10 else {
            throw MultiRouteError.tooManyLocations
        }
        
        let orderedLocations = options.optimizeOrder ? 
            optimizeLocationOrder(locations) : locations
        
        var routes: [WalkRoute] = []
        var totalDistance: Double = 0
        var totalDuration: TimeInterval = 0
        
        // Generate routes between consecutive locations
        for i in 0..<(orderedLocations.count - 1) {
            let fromLocation = orderedLocations[i]
            let toLocation = orderedLocations[i + 1]
            
            let route = try await generateRoute(
                from: fromLocation.coordinate,
                to: toLocation.coordinate,
                transportType: options.transportType,
                routeType: options.routeType
            )
            
            routes.append(route)
            totalDistance += route.totalDistance
            totalDuration += route.estimatedDuration
        }
        
        // If loop route, add return to start
        if options.routeType == .loop && orderedLocations.count > 2 {
            let returnRoute = try await generateRoute(
                from: orderedLocations.last!.coordinate,
                to: orderedLocations.first!.coordinate,
                transportType: options.transportType,
                routeType: .direct
            )
            routes.append(returnRoute)
            totalDistance += returnRoute.totalDistance
            totalDuration += returnRoute.estimatedDuration
        }
        
        return MultiLocationWalk(
            name: name,
            locations: orderedLocations,
            routes: routes,
            totalDistance: totalDistance,
            estimatedDuration: totalDuration,
            createdAt: Date(),
            createdBy: createdBy,
            isPublic: isPublic
        )
    }
    
    private func generateRoute(
        from startCoordinate: CLLocationCoordinate2D,
        to endCoordinate: CLLocationCoordinate2D,
        transportType: MKDirectionsTransportType,
        routeType: RouteOptions.RouteType
    ) async throws -> WalkRoute {
        
        switch routeType {
        case .direct:
            return try await generateDirectRoute(
                from: startCoordinate,
                to: endCoordinate,
                transportType: transportType
            )
        case .exploring:
            return try await generateExploringRoute(
                from: startCoordinate,
                to: endCoordinate
            )
        case .loop:
            // For individual segments in loop, use direct routing
            return try await generateDirectRoute(
                from: startCoordinate,
                to: endCoordinate,
                transportType: transportType
            )
        }
    }
    
    private func generateDirectRoute(
        from startCoordinate: CLLocationCoordinate2D,
        to endCoordinate: CLLocationCoordinate2D,
        transportType: MKDirectionsTransportType
    ) async throws -> WalkRoute {
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endCoordinate))
        request.transportType = transportType
        
        let directions = MKDirections(request: request)
        
        do {
            let response = try await directions.calculate()
            guard let route = response.routes.first else {
                throw MultiRouteError.routeGenerationFailed
            }
            
            let waypoints = route.steps.map { $0.polyline.coordinate }
            
            return WalkRoute(
                waypoints: waypoints,
                estimatedDuration: route.expectedTravelTime,
                totalDistance: route.distance,
                startLocation: startCoordinate
            )
        } catch {
            // Fallback to simple straight line if MapKit fails
            return generateFallbackRoute(from: startCoordinate, to: endCoordinate)
        }
    }
    
    private func generateExploringRoute(
        from startCoordinate: CLLocationCoordinate2D,
        to endCoordinate: CLLocationCoordinate2D
    ) async throws -> WalkRoute {
        
        // Add some random exploration waypoints between start and end
        var waypoints = [startCoordinate]
        
        let midPoint = CLLocationCoordinate2D(
            latitude: (startCoordinate.latitude + endCoordinate.latitude) / 2,
            longitude: (startCoordinate.longitude + endCoordinate.longitude) / 2
        )
        
        // Add 2-3 exploring points around the midpoint
        let explorationRadius = 200.0 // meters
        for _ in 0..<Int.random(in: 2...3) {
            let randomBearing = Double.random(in: 0...360)
            let randomDistance = Double.random(in: 50...explorationRadius)
            let explorationPoint = midPoint.coordinate(
                atDistance: randomDistance,
                bearing: randomBearing
            )
            waypoints.append(explorationPoint)
        }
        
        waypoints.append(endCoordinate)
        
        let totalDistance = calculateTotalDistance(waypoints: waypoints)
        let estimatedDuration = totalDistance / Constants.averageWalkingSpeed
        
        return WalkRoute(
            waypoints: waypoints,
            estimatedDuration: estimatedDuration,
            totalDistance: totalDistance,
            startLocation: startCoordinate
        )
    }
    
    private func generateFallbackRoute(
        from startCoordinate: CLLocationCoordinate2D,
        to endCoordinate: CLLocationCoordinate2D
    ) -> WalkRoute {
        
        let waypoints = [startCoordinate, endCoordinate]
        let distance = startCoordinate.distance(to: endCoordinate)
        let duration = distance / Constants.averageWalkingSpeed
        
        return WalkRoute(
            waypoints: waypoints,
            estimatedDuration: duration,
            totalDistance: distance,
            startLocation: startCoordinate
        )
    }
    
    private func optimizeLocationOrder(_ locations: [WalkLocation]) -> [WalkLocation] {
        // Simple nearest neighbor optimization
        guard locations.count > 2 else { return locations }
        
        var optimized = [locations.first!]
        var remaining = Array(locations.dropFirst())
        
        while !remaining.isEmpty {
            let current = optimized.last!
            let nearest = remaining.min { location1, location2 in
                current.coordinate.distance(to: location1.coordinate) <
                current.coordinate.distance(to: location2.coordinate)
            }!
            
            optimized.append(nearest)
            remaining.removeAll { $0.id == nearest.id }
        }
        
        return optimized
    }
    
    private func calculateTotalDistance(waypoints: [CLLocationCoordinate2D]) -> Double {
        guard waypoints.count > 1 else { return 0 }
        
        var totalDistance: Double = 0
        for i in 0..<(waypoints.count - 1) {
            totalDistance += waypoints[i].distance(to: waypoints[i + 1])
        }
        return totalDistance
    }
}

// Extension to get coordinate from MKPolyline
extension MKPolyline {
    var coordinate: CLLocationCoordinate2D {
        let points = points()
        let coords = UnsafeBufferPointer(start: points, count: pointCount)
        return coords.first?.coordinate ?? CLLocationCoordinate2D()
    }
}

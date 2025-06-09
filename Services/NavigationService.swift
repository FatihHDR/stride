import Foundation
import CoreLocation
import Combine

class NavigationService: ObservableObject {
    @Published var isNavigating = false
    @Published var currentWaypoint = 0
    @Published var distanceToNextWaypoint: Double = 0
    @Published var totalDistanceWalked: Double = 0
    
    private var route: WalkRoute?
    private var lastLocation: CLLocation?
    private var cancellables = Set<AnyCancellable>()
    
    func startNavigation(route: WalkRoute, locationManager: LocationManager) {
        self.route = route
        self.isNavigating = true
        self.currentWaypoint = 0
        self.totalDistanceWalked = 0
        
        // Subscribe to location updates
        locationManager.$location
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.updateNavigation(with: location)
            }
            .store(in: &cancellables)
    }
    
    func stopNavigation() {
        isNavigating = false
        route = nil
        currentWaypoint = 0
        lastLocation = nil
        cancellables.removeAll()
    }
    
    private func updateNavigation(with location: CLLocation) {
        guard let route = route, isNavigating else { return }
        
        // Calculate distance walked since last update
        if let lastLocation = lastLocation {
            let distanceWalked = location.distance(from: lastLocation)
            totalDistanceWalked += distanceWalked
        }
        lastLocation = location
        
        // Calculate distance to next waypoint
        if currentWaypoint < route.waypoints.count {
            let nextWaypoint = route.waypoints[currentWaypoint]
            let waypointLocation = CLLocation(
                latitude: nextWaypoint.latitude,
                longitude: nextWaypoint.longitude
            )
            distanceToNextWaypoint = location.distance(from: waypointLocation)
            
            // Check if we've reached the waypoint (within 10 meters)
            if distanceToNextWaypoint < 10 {
                currentWaypoint += 1
                
                // Check if we've completed the route
                if currentWaypoint >= route.waypoints.count {
                    stopNavigation()
                }
            }
        }
    }
    
    var navigationProgress: Double {
        guard let route = route, route.waypoints.count > 0 else { return 0 }
        return Double(currentWaypoint) / Double(route.waypoints.count)
    }
    
    var isRouteComplete: Bool {
        guard let route = route else { return false }
        return currentWaypoint >= route.waypoints.count
    }
}

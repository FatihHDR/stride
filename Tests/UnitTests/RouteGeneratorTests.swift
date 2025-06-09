import XCTest
import CoreLocation
@testable import RandomWalkApp

class RouteGeneratorTests: XCTestCase {
    
    var routeGenerator: RouteGenerator!
    
    override func setUp() {
        super.setUp()
        routeGenerator = RouteGenerator()
    }
    
    override func tearDown() {
        routeGenerator = nil
        super.tearDown()
    }
    
    func testValidRouteGeneration() async throws {
        let parameters = WalkParameters(
            duration: 900, // 15 minutes
            startLocation: CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456), // Jakarta
            walkingSpeed: 1.4
        )
        
        let route = try await routeGenerator.generateRoute(parameters: parameters)
        
        XCTAssertEqual(route.estimatedDuration, parameters.duration)
        XCTAssertEqual(route.totalDistance, parameters.estimatedDistance)
        XCTAssertEqual(route.startLocation.latitude, parameters.startLocation.latitude, accuracy: 0.0001)
        XCTAssertEqual(route.startLocation.longitude, parameters.startLocation.longitude, accuracy: 0.0001)
        XCTAssertGreaterThan(route.waypoints.count, 4) // Should have multiple waypoints
        XCTAssertEqual(route.waypoints.first?.latitude, route.waypoints.last?.latitude, accuracy: 0.0001) // Should return to start
        XCTAssertEqual(route.waypoints.first?.longitude, route.waypoints.last?.longitude, accuracy: 0.0001)
    }
    
    func testInvalidParametersThrowsError() async {
        let invalidParameters = WalkParameters(
            duration: -100, // negative duration
            startLocation: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            walkingSpeed: 1.4
        )
        
        do {
            _ = try await routeGenerator.generateRoute(parameters: invalidParameters)
            XCTFail("Should have thrown an error for invalid parameters")
        } catch RouteGenerator.RouteGeneratorError.invalidParameters {
            // Expected error
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

import XCTest
import CoreLocation
@testable import RandomWalkApp

class CLLocationCoordinate2DExtensionsTests: XCTestCase {
    
    func testCoordinateAtDistance() {
        let startCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        // Test moving north (bearing 0°)
        let northCoordinate = startCoordinate.coordinate(atDistance: 1000, bearing: 0)
        XCTAssertGreaterThan(northCoordinate.latitude, startCoordinate.latitude, "Should move north")
        XCTAssertEqual(northCoordinate.longitude, startCoordinate.longitude, accuracy: 0.001, "Longitude should remain the same")
        
        // Test moving east (bearing 90°)
        let eastCoordinate = startCoordinate.coordinate(atDistance: 1000, bearing: 90)
        XCTAssertEqual(eastCoordinate.latitude, startCoordinate.latitude, accuracy: 0.001, "Latitude should remain the same")
        XCTAssertGreaterThan(eastCoordinate.longitude, startCoordinate.longitude, "Should move east")
        
        // Test moving south (bearing 180°)
        let southCoordinate = startCoordinate.coordinate(atDistance: 1000, bearing: 180)
        XCTAssertLessThan(southCoordinate.latitude, startCoordinate.latitude, "Should move south")
        XCTAssertEqual(southCoordinate.longitude, startCoordinate.longitude, accuracy: 0.001, "Longitude should remain the same")
        
        // Test moving west (bearing 270°)
        let westCoordinate = startCoordinate.coordinate(atDistance: 1000, bearing: 270)
        XCTAssertEqual(westCoordinate.latitude, startCoordinate.latitude, accuracy: 0.001, "Latitude should remain the same")
        XCTAssertLessThan(westCoordinate.longitude, startCoordinate.longitude, "Should move west")
    }
    
    func testDistanceBetweenCoordinates() {
        let coordinate1 = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let coordinate2 = CLLocationCoordinate2D(latitude: 0.009, longitude: 0) // Approximately 1km north
        
        let distance = coordinate1.distance(to: coordinate2)
        
        // Should be approximately 1000 meters (allow for some margin due to Earth's curvature)
        XCTAssertGreaterThan(distance, 900, "Distance should be at least 900m")
        XCTAssertLessThan(distance, 1100, "Distance should be at most 1100m")
    }
    
    func testZeroDistance() {
        let coordinate = CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456)
        let sameCoordinate = coordinate.coordinate(atDistance: 0, bearing: 45)
        
        XCTAssertEqual(coordinate.latitude, sameCoordinate.latitude, accuracy: 0.000001)
        XCTAssertEqual(coordinate.longitude, sameCoordinate.longitude, accuracy: 0.000001)
    }
    
    func testDistanceToSelf() {
        let coordinate = CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456)
        let distance = coordinate.distance(to: coordinate)
        
        XCTAssertEqual(distance, 0, accuracy: 0.1)
    }
}

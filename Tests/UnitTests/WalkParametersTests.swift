import XCTest
import CoreLocation
@testable import RandomWalkApp

class WalkParametersTests: XCTestCase {
    
    func testEstimatedDistance() {
        let params = WalkParameters(
            duration: 900, // 15 minutes in seconds
            startLocation: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            walkingSpeed: 1.4
        )
        
        XCTAssertEqual(params.estimatedDistance, 1260.0, accuracy: 0.1)
    }
    
    func testZeroDuration() {
        let params = WalkParameters(
            duration: 0,
            startLocation: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            walkingSpeed: 1.4
        )
        
        XCTAssertEqual(params.estimatedDistance, 0.0)
    }
    
    func testDifferentWalkingSpeeds() {
        let slowParams = WalkParameters(
            duration: 600, // 10 minutes
            startLocation: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            walkingSpeed: 1.0 // slow walker
        )
        
        let fastParams = WalkParameters(
            duration: 600, // 10 minutes
            startLocation: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            walkingSpeed: 2.0 // fast walker
        )
        
        XCTAssertEqual(slowParams.estimatedDistance, 600.0)
        XCTAssertEqual(fastParams.estimatedDistance, 1200.0)
    }
}

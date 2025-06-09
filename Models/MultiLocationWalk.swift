import Foundation
import CoreLocation

struct MultiLocationWalk {
    let id = UUID()
    let name: String
    let locations: [WalkLocation]
    let routes: [WalkRoute] // Routes between locations
    let totalDistance: Double
    let estimatedDuration: TimeInterval
    let createdAt: Date
    let createdBy: String
    let isPublic: Bool
    
    var totalRoutes: Int {
        return routes.count
    }
}

struct WalkLocation {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?
    let type: LocationType
    
    enum LocationType {
        case userInput
        case search
        case currentLocation
        case saved
    }
}

struct SharedWalk {
    let id = UUID()
    let walk: MultiLocationWalk
    let shareCode: String
    let sharedAt: Date
    let downloadCount: Int
    let rating: Double
    let reviews: [WalkReview]
}

struct WalkReview {
    let id = UUID()
    let userName: String
    let rating: Int // 1-5 stars
    let comment: String
    let createdAt: Date
}

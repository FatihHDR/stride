import Foundation

struct Constants {
    // Walking parameters
    static let averageWalkingSpeed: Double = 1.4 // m/s
    static let minWalkDuration: Double = 5 // minutes
    static let maxWalkDuration: Double = 120 // minutes
    
    // Route generation
    static let segmentDistance: Double = 100.0 // meters
    static let minSegments: Int = 4
    
    // Map settings
    static let defaultMapSpan: Double = 0.01
    static let routeFitMultiplier: Double = 1.3
}

struct AppStrings {
    static let appTitle = "Stride"
    static let generateWalk = "Generate Walk"
    static let waitingForLocation = "Waiting for location..."
    static let generatingRoute = "Generating route..."
    static let viewRoute = "View Route"
    static let startEnd = "Start/End"
    static let duration = "Duration"
    static let distance = "Distance"
    static let waypoints = "Waypoints"
    static let yourRoute = "Your Route"
    static let walkDuration = "Walk Duration"
}

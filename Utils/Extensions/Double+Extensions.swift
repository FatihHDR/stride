import Foundation

extension Double {
    /// Format distance in meters to a readable string
    func formatAsDistance() -> String {
        if self >= 1000 {
            return String(format: "%.1f km", self / 1000)
        } else {
            return String(format: "%.0f m", self)
        }
    }
    
    /// Format duration in seconds to a readable string
    func formatAsDuration() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) % 3600 / 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "%d sec", seconds)
        }
    }
    
    /// Convert meters per second to kilometers per hour
    func metersPerSecondToKmh() -> Double {
        return self * 3.6
    }
    
    /// Convert degrees to radians
    func toRadians() -> Double {
        return self * .pi / 180
    }
    
    /// Convert radians to degrees
    func toDegrees() -> Double {
        return self * 180 / .pi
    }
}

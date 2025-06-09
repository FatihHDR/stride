import Foundation
import CoreLocation
import MapKit
import Combine

class MultiLocationWalkViewModel: ObservableObject {
    @Published var locations: [WalkLocation] = []
    @Published var currentWalk: MultiLocationWalk?
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var walkName = ""
    @Published var isPublic = false
    @Published var routeType: MultiLocationRouteGenerator.RouteOptions.RouteType = .direct
    @Published var optimizeOrder = false
    
    private let routeGenerator = MultiLocationRouteGenerator()
    private let locationSearchService = LocationSearchService()
    private let sharingService = WalkSharingService()
    
    func addLocation(_ location: WalkLocation) {
        locations.append(location)
        errorMessage = nil
    }
    
    func removeLocation(at index: Int) {
        guard index < locations.count else { return }
        locations.remove(at: index)
    }
    
    func moveLocation(from source: IndexSet, to destination: Int) {
        locations.move(fromOffsets: source, toOffset: destination)
    }
    
    func addCurrentLocation(_ currentLocation: CLLocation) {
        let location = WalkLocation(
            name: "Current Location",
            coordinate: currentLocation.coordinate,
            address: nil,
            type: .currentLocation
        )
        addLocation(location)
    }
    
    func generateWalk(createdBy: String) async {
        guard locations.count >= 2 else {
            await MainActor.run {
                errorMessage = "Please add at least 2 locations"
            }
            return
        }
        
        guard !walkName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run {
                errorMessage = "Please enter a walk name"
            }
            return
        }
        
        await MainActor.run {
            isGenerating = true
            errorMessage = nil
        }
        
        do {
            let options = MultiLocationRouteGenerator.RouteOptions(
                transportType: .walking,
                routeType: routeType,
                optimizeOrder: optimizeOrder
            )
            
            let walk = try await routeGenerator.generateMultiLocationWalk(
                name: walkName,
                locations: locations,
                options: options,
                createdBy: createdBy,
                isPublic: isPublic
            )
            
            await MainActor.run {
                currentWalk = walk
                isGenerating = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isGenerating = false
            }
        }
    }
    
    func shareWalk(userName: String) async -> String? {
        guard let walk = currentWalk else { return nil }
        
        do {
            let shareURL = try await sharingService.shareWalk(walk, userName: userName)
            return shareURL
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return nil
        }
    }
    
    func clearWalk() {
        currentWalk = nil
        locations.removeAll()
        walkName = ""
        errorMessage = nil
        isPublic = false
        routeType = .direct
        optimizeOrder = false
    }
    
    func duplicateWalk() -> MultiLocationWalkViewModel {
        let newViewModel = MultiLocationWalkViewModel()
        newViewModel.locations = self.locations
        newViewModel.walkName = self.walkName + " (Copy)"
        newViewModel.isPublic = false
        newViewModel.routeType = self.routeType
        newViewModel.optimizeOrder = self.optimizeOrder
        return newViewModel
    }
}

// MARK: - Extensions
extension MultiLocationWalkViewModel {
    var totalEstimatedDistance: Double {
        guard locations.count >= 2 else { return 0 }
        
        var totalDistance: Double = 0
        for i in 0..<(locations.count - 1) {
            totalDistance += locations[i].coordinate.distance(to: locations[i + 1].coordinate)
        }
        
        if routeType == .loop && locations.count > 2 {
            totalDistance += locations.last!.coordinate.distance(to: locations.first!.coordinate)
        }
        
        return totalDistance
    }
    
    var totalEstimatedDuration: TimeInterval {
        return totalEstimatedDistance / Constants.averageWalkingSpeed
    }
    
    var canGenerateWalk: Bool {
        return locations.count >= 2 && 
               !walkName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !isGenerating
    }
}

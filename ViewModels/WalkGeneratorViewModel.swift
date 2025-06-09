import Foundation
import CoreLocation
import Combine

class WalkGeneratorViewModel: ObservableObject {
    @Published var currentRoute: WalkRoute?
    @Published var isGenerating = false
    @Published var errorMessage: String?
    
    private let routeGenerator = RouteGenerator()
    
    func generateWalk(parameters: WalkParameters) {
        isGenerating = true
        errorMessage = nil
        
        Task {
            do {
                let route = try await routeGenerator.generateRoute(parameters: parameters)
                await MainActor.run {
                    self.currentRoute = route
                    self.isGenerating = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isGenerating = false
                }
            }
        }
    }
    
    func clearRoute() {
        currentRoute = nil
        errorMessage = nil
    }
}

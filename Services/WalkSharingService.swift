import Foundation
import Combine

class WalkSharingService: ObservableObject {
    @Published var publicWalks: [SharedWalk] = []
    @Published var mySharedWalks: [SharedWalk] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let shareBaseURL = "https://stride.app/walk/"
    
    // MARK: - Share Walk
    func shareWalk(_ walk: MultiLocationWalk, userName: String) async throws -> String {
        isLoading = true
        defer { isLoading = false }
        
        // Generate unique share code
        let shareCode = generateShareCode()
        
        let sharedWalk = SharedWalk(
            walk: walk,
            shareCode: shareCode,
            sharedAt: Date(),
            downloadCount: 0,
            rating: 0.0,
            reviews: []
        )
        
        // In a real app, this would be an API call
        await saveSharedWalk(sharedWalk)
        
        return shareBaseURL + shareCode
    }
    
    // MARK: - Load Walk from Share Code
    func loadWalk(shareCode: String) async throws -> MultiLocationWalk {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In a real app, this would fetch from server
        guard let sharedWalk = getSharedWalk(by: shareCode) else {
            throw SharingError.walkNotFound
        }
        
        // Increment download count
        await incrementDownloadCount(for: shareCode)
        
        return sharedWalk.walk
    }
    
    // MARK: - Public Walks
    func loadPublicWalks() async {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In a real app, this would fetch from server
        await MainActor.run {
            self.publicWalks = loadSamplePublicWalks()
        }
    }
    
    // MARK: - Reviews
    func addReview(to shareCode: String, review: WalkReview) async throws {
        // In a real app, this would be an API call
        // For now, we'll just simulate success
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    // MARK: - Private Methods
    private func generateShareCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).map { _ in characters.randomElement()! })
    }
    
    private func saveSharedWalk(_ sharedWalk: SharedWalk) async {
        // In a real app, this would save to server
        // For demo, save to UserDefaults
        await MainActor.run {
            var savedWalks = mySharedWalks
            savedWalks.append(sharedWalk)
            mySharedWalks = savedWalks
            
            // Also add to public walks if it's public
            if sharedWalk.walk.isPublic {
                publicWalks.append(sharedWalk)
            }
        }
    }
    
    private func getSharedWalk(by shareCode: String) -> SharedWalk? {
        return publicWalks.first { $0.shareCode == shareCode } ??
               mySharedWalks.first { $0.shareCode == shareCode }
    }
    
    private func incrementDownloadCount(for shareCode: String) async {
        // In a real app, this would update the server
        await MainActor.run {
            if let index = publicWalks.firstIndex(where: { $0.shareCode == shareCode }) {
                var walk = publicWalks[index]
                // Note: This is a simplified approach. In real implementation, 
                // SharedWalk should have mutable properties or use a different pattern
            }
        }
    }
      private func loadSamplePublicWalks() -> [SharedWalk] {
        // Use sample data for demonstration
        return DemoData.samplePublicWalks
    }
}

enum SharingError: Error, LocalizedError {
    case walkNotFound
    case networkError
    case invalidShareCode
    
    var errorDescription: String? {
        switch self {
        case .walkNotFound:
            return "Walk not found. Please check the share code."
        case .networkError:
            return "Network error. Please try again."
        case .invalidShareCode:
            return "Invalid share code format."
        }
    }
}

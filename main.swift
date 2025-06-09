import SwiftUI

@main
struct StrideApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LocationManager())
                .environmentObject(WalkGeneratorViewModel())
                .environmentObject(MultiLocationWalkViewModel())
                .environmentObject(WalkSharingService())
        }
    }
}
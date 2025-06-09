import SwiftUI

@main
struct RandomWalkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LocationManager())
                .environmentObject(WalkGeneratorViewModel())
        }
    }
}
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        TabView {
            NavigationView {
                WalkSetupView()
            }
            .tabItem {
                Image(systemName: "figure.walk")
                Text("Random Walk")
            }
            
            NavigationView {
                MultiLocationWalkSetupView()
            }
            .tabItem {
                Image(systemName: "map")
                Text("Multi-Location")
            }
            
            NavigationView {
                PublicWalksView()
            }
            .tabItem {
                Image(systemName: "globe")
                Text("Discover")
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
        .environmentObject(WalkGeneratorViewModel())
}

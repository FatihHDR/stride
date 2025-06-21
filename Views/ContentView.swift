import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        TabView {
            NavigationView {
                WalkSetupView()
            }
            .tabItem {
                Image(systemName: "figure.walk.circle")
                Text("Walk")
            }
            
            NavigationView {
                MultiLocationWalkSetupView()
            }
            .tabItem {
                Image(systemName: "map.circle")
                Text("Routes")
            }
            
            NavigationView {
                PublicWalksView()
            }
            .tabItem {
                Image(systemName: "globe.americas")
                Text("Explore")
            }
        }
        .accentColor(.primary)
        .onAppear {
            setupTabBarAppearance()
            locationManager.requestLocation()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.shadowColor = UIColor.separator.withAlphaComponent(0.3)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
        .environmentObject(WalkGeneratorViewModel())
}

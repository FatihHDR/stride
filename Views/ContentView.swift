import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        NavigationView {
            WalkSetupView()
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

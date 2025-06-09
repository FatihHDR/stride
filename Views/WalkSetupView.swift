import SwiftUI
import CoreLocation

struct WalkSetupView: View {
    @State private var selectedDuration: Double = 15 // minutes
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var walkGenerator: WalkGeneratorViewModel
      var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "figure.walk.diamond")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    Text("Random Walk Generator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Discover new paths in your area")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Time Picker
                TimePickerView(duration: $selectedDuration)
                
                // Generate Button
                Button {
                    generateWalk()
                } label: {
                    HStack {
                        if walkGenerator.isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "location.fill")
                        }
                        
                        Text(walkGenerator.isGenerating ? "Generating..." : "Generate Walk")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(canGenerateWalk ? Color.blue : Color.gray)
                    )
                    .foregroundColor(.white)
                }
                .disabled(!canGenerateWalk)
                
                // Status Messages
                if locationManager.location == nil {
                    HStack {
                        Image(systemName: "location.slash")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading) {
                            Text("Location Required")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Please enable location services to generate routes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Error Message
                if let errorMessage = walkGenerator.errorMessage {
                    ErrorView(errorMessage) {
                        walkGenerator.clearRoute()
                        generateWalk()
                    }
                }
                
                // Route Result
                if let route = walkGenerator.currentRoute {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Route Generated!")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        NavigationLink(destination: MapView(route: route)) {
                            HStack {
                                Image(systemName: "map")
                                Text("View Route on Map")
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationTitle("Random Walk")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var canGenerateWalk: Bool {
        locationManager.location != nil && !walkGenerator.isGenerating
    }
    
    private func generateWalk() {
        guard let location = locationManager.location else { return }
        
        let parameters = WalkParameters(
            duration: selectedDuration * 60, // convert to seconds
            startLocation: location.coordinate,
            walkingSpeed: 1.4 // average walking speed m/s
        )
        
        walkGenerator.generateWalk(parameters: parameters)
    }
}

#Preview {
    NavigationView {
        WalkSetupView()
    }
    .environmentObject(LocationManager())
    .environmentObject(WalkGeneratorViewModel())
}

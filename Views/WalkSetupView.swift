import SwiftUI
import CoreLocation

struct WalkSetupView: View {
    @State private var selectedDuration: Double = 15 // minutes
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var walkGenerator: WalkGeneratorViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 32) {
                    // Modern Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.1), .blue.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "figure.walk")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.blue)
                            )
                        
                        VStack(spacing: 8) {
                            Text("Random Walk")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Discover new paths around you")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Clean Time Picker Section
                    VStack(spacing: 20) {
                        HStack {
                            Text("Duration")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(Int(selectedDuration)) min")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.1))
                                )
                        }
                        
                        Slider(value: $selectedDuration, in: 5...120, step: 5)
                            .accentColor(.blue)
                            .padding(.horizontal, 4)
                        
                        HStack {
                            Text("5 min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("120 min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6).opacity(0.3))
                    )
                    
                    // Modern Generate Button
                    Button {
                        generateWalk()
                    } label: {
                        HStack(spacing: 12) {
                            if walkGenerator.isGenerating {
                                ProgressView()
                                    .scaleEffect(0.9)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 20))
                            }
                            
                            Text(walkGenerator.isGenerating ? "Generating Route..." : "Start Walking")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    canGenerateWalk ? 
                                    LinearGradient(
                                        colors: [.blue, .blue.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) : 
                                    LinearGradient(
                                        colors: [.gray.opacity(0.6), .gray.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .foregroundColor(.white)
                        .shadow(
                            color: canGenerateWalk ? .blue.opacity(0.3) : .clear,
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    }
                    .disabled(!canGenerateWalk)
                    .scaleEffect(canGenerateWalk ? 1.0 : 0.95)
                    .animation(.easeInOut(duration: 0.2), value: canGenerateWalk)
                    
                    // Location Status Card
                    LocationStatusCard()
                    
                    // Error Display
                    if let errorMessage = walkGenerator.errorMessage {
                        ErrorCard(message: errorMessage) {
                            walkGenerator.clearRoute()
                        }
                    }
                    
                    // Route Result Card
                    if let route = walkGenerator.currentRoute {
                        RouteResultCard(route: route)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .background(Color(.systemGroupedBackground))
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

// MARK: - Supporting Views

struct LocationStatusCard: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(locationManager.location != nil ? Color.green : Color.orange)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(locationManager.location != nil ? "Location Ready" : "Getting Location...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                if let location = locationManager.location {
                    Text("Accuracy: ±\(Int(location.horizontalAccuracy))m")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if locationManager.location == nil {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

struct ErrorCard: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.system(size: 16))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Unable to Generate Route")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Button("Retry") {
                onRetry()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.blue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct RouteResultCard: View {
    let route: WalkRoute
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.green)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Route Generated")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Ready to start your walk")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Route Stats
            HStack(spacing: 20) {
                StatItem(
                    icon: "ruler",
                    title: "Distance",
                    value: route.totalDistance.formatAsDistance()
                )
                
                StatItem(
                    icon: "clock",
                    title: "Duration",
                    value: route.estimatedDuration.formatAsDuration()
                )
                
                StatItem(
                    icon: "location",
                    title: "Waypoints",
                    value: "\(route.waypoints.count)"
                )
            }
            
            // View Route Button
            NavigationLink(destination: MapView(route: route)) {
                HStack(spacing: 8) {
                    Image(systemName: "map")
                        .font(.system(size: 16))
                    Text("View Route")
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                )
                .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationView {
        WalkSetupView()
    }
    .environmentObject(LocationManager())
    .environmentObject(WalkGeneratorViewModel())
}

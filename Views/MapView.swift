import SwiftUI
import MapKit

struct MapView: View {
    let route: WalkRoute
    @State private var region: MKCoordinateRegion
    @State private var showingRouteDetails = false
    
    init(route: WalkRoute) {
        self.route = route
        self._region = State(initialValue: MKCoordinateRegion(
            center: route.startLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ZStack {
            // Map
            Map(coordinateRegion: $region, annotationItems: [route]) { route in
                MapAnnotation(coordinate: route.startLocation) {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "figure.walk")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        Text("Start/End")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.7))
                            )
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .onAppear {
                setRegionToFitRoute()
            }
            
            // Floating Control Panel
            VStack {
                Spacer()
                
                RouteInfoPanel(route: route, showingDetails: $showingRouteDetails)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            
            // Navigation Controls
            VStack {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        // Recenter Button
                        Button {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                setRegionToFitRoute()
                            }
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Route Type Toggle
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingRouteDetails.toggle()
                            }
                        } label: {
                            Image(systemName: showingRouteDetails ? "info.circle.fill" : "info.circle")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 60)
                .padding(.trailing, 20)
                
                Spacer()
            }
        }
        .navigationTitle("Your Route")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func setRegionToFitRoute() {
        let coordinates = route.waypoints
        guard !coordinates.isEmpty else { return }
        
        let minLat = coordinates.map { $0.latitude }.min() ?? 0
        let maxLat = coordinates.map { $0.latitude }.max() ?? 0
        let minLon = coordinates.map { $0.longitude }.min() ?? 0
        let maxLon = coordinates.map { $0.longitude }.max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.3, 0.005),
            longitudeDelta: max((maxLon - minLon) * 1.3, 0.005)
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
}

// MARK: - Supporting Views

struct RouteInfoPanel: View {
    let route: WalkRoute
    @Binding var showingDetails: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Stats
            HStack(spacing: 20) {
                RouteStatItem(
                    icon: "clock.fill",
                    title: "Duration",
                    value: route.estimatedDuration.formatAsDuration(),
                    color: .blue
                )
                
                RouteStatItem(
                    icon: "ruler.fill",
                    title: "Distance",
                    value: route.totalDistance.formatAsDistance(),
                    color: .green
                )
                
                RouteStatItem(
                    icon: "location.fill",
                    title: "Waypoints",
                    value: "\(route.waypoints.count)",
                    color: .orange
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Detailed Info (Expandable)
            if showingDetails {
                Divider()
                    .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Route Details")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    VStack(spacing: 8) {
                        DetailRow(label: "Start Location", value: "Lat: \(String(format: "%.4f", route.startLocation.latitude)), Lng: \(String(format: "%.4f", route.startLocation.longitude))")
                        DetailRow(label: "Route Type", value: "Circular Walk")
                        DetailRow(label: "Estimated Calories", value: "\(Int((route.totalDistance / 1000) * 50)) cal")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .animation(.easeInOut(duration: 0.3), value: showingDetails)
    }
}

struct RouteStatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

extension WalkRoute: Identifiable {}

#Preview {
    let sampleRoute = WalkRoute(
        waypoints: [
            CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
            CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294),
            CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        ],
        estimatedDuration: 1800,
        totalDistance: 2500,
        startLocation: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    )
    
    NavigationView {
        MapView(route: sampleRoute)
    }
}

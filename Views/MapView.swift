import SwiftUI
import MapKit

struct MapView: View {
    let route: WalkRoute
    @State private var region: MKCoordinateRegion
    
    init(route: WalkRoute) {
        self.route = route
        self._region = State(initialValue: MKCoordinateRegion(
            center: route.startLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, annotationItems: [route]) { route in
                MapAnnotation(coordinate: route.startLocation) {
                    VStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.blue)
                            .font(.title2)
                        Text("Start/End")
                            .font(.caption)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(4)
                    }
                }
            }
            .onAppear {
                setRegionToFitRoute()
            }
              VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                    Text("Duration:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(route.estimatedDuration.formatAsDuration())
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Image(systemName: "ruler.fill")
                        .foregroundColor(.green)
                    Text("Distance:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(route.totalDistance.formatAsDistance())
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.orange)
                    Text("Waypoints:")
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(route.waypoints.count)")
                        .fontWeight(.semibold)
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start Location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.4f", route.startLocation.latitude)), \(String(format: "%.4f", route.startLocation.longitude))")
                            .font(.caption)
                            .fontFamily(.monospaced)
                    }
                    Spacer()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding()
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
            latitudeDelta: (maxLat - minLat) * 1.3,
            longitudeDelta: (maxLon - minLon) * 1.3
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
}

extension WalkRoute: Identifiable {}

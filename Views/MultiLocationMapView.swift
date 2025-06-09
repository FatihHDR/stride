import SwiftUI
import MapKit

struct MultiLocationMapView: View {
    let walk: MultiLocationWalk
    @State private var region: MKCoordinateRegion
    @State private var selectedRoute = 0
    
    init(walk: MultiLocationWalk) {
        self.walk = walk
        
        // Calculate initial region to fit all locations
        let coordinates = walk.locations.map { $0.coordinate }
        let center = Self.calculateCenter(from: coordinates)
        let span = Self.calculateSpan(from: coordinates)
        
        self._region = State(initialValue: MKCoordinateRegion(
            center: center,
            span: span
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Map
            Map(coordinateRegion: $region, annotationItems: walk.locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    LocationAnnotationView(
                        location: location,
                        index: walk.locations.firstIndex { $0.id == location.id } ?? 0,
                        isFirst: walk.locations.first?.id == location.id,
                        isLast: walk.locations.last?.id == location.id
                    )
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Info Panel
            VStack(spacing: 16) {
                // Walk Info Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(walk.name)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Created by \(walk.createdBy)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(walk.totalDistance.formatAsDistance())
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Text(walk.estimatedDuration.formatAsDuration())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Route Selector
                if walk.routes.count > 1 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Route Segments")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(walk.routes.enumerated()), id: \.offset) { index, route in
                                    RouteSegmentView(
                                        route: route,
                                        index: index,
                                        fromLocation: getLocationName(at: index),
                                        toLocation: getLocationName(at: index + 1),
                                        isSelected: selectedRoute == index
                                    ) {
                                        selectedRoute = index
                                        focusOnRoute(route)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Locations List
                VStack(alignment: .leading, spacing: 8) {
                    Text("Locations")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(Array(walk.locations.enumerated()), id: \.element.id) { index, location in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(locationColor(for: index).opacity(0.2))
                                    .frame(width: 24, height: 24)
                                
                                if index == 0 {
                                    Image(systemName: "location.fill")
                                        .font(.caption)
                                        .foregroundColor(locationColor(for: index))
                                } else if index == walk.locations.count - 1 {
                                    Image(systemName: "flag.fill")
                                        .font(.caption)
                                        .foregroundColor(locationColor(for: index))
                                } else {
                                    Text("\(index + 1)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(locationColor(for: index))
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(location.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                if let address = location.address {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                focusOnLocation(location)
                            } label: {
                                Image(systemName: "location.circle")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
            )
        }
        .navigationTitle("Route Map")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getLocationName(at index: Int) -> String {
        guard index < walk.locations.count else { return "End" }
        return walk.locations[index].name
    }
    
    private func locationColor(for index: Int) -> Color {
        if index == 0 { return .green }
        if index == walk.locations.count - 1 { return .red }
        return .blue
    }
    
    private func focusOnLocation(_ location: WalkLocation) {
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        }
    }
    
    private func focusOnRoute(_ route: WalkRoute) {
        let coordinates = route.waypoints
        let center = Self.calculateCenter(from: coordinates)
        let span = Self.calculateSpan(from: coordinates)
        
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(center: center, span: span)
        }
    }
    
    // MARK: - Static Helper Methods
    static func calculateCenter(from coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        guard !coordinates.isEmpty else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
        let totalLat = coordinates.reduce(0) { $0 + $1.latitude }
        let totalLon = coordinates.reduce(0) { $0 + $1.longitude }
        
        return CLLocationCoordinate2D(
            latitude: totalLat / Double(coordinates.count),
            longitude: totalLon / Double(coordinates.count)
        )
    }
    
    static func calculateSpan(from coordinates: [CLLocationCoordinate2D]) -> MKCoordinateSpan {
        guard coordinates.count > 1 else {
            return MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        }
        
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        let minLat = latitudes.min() ?? 0
        let maxLat = latitudes.max() ?? 0
        let minLon = longitudes.min() ?? 0
        let maxLon = longitudes.max() ?? 0
        
        let latDelta = (maxLat - minLat) * 1.5 // Add padding
        let lonDelta = (maxLon - minLon) * 1.5
        
        return MKCoordinateSpan(
            latitudeDelta: max(latDelta, 0.01),
            longitudeDelta: max(lonDelta, 0.01)
        )
    }
}

struct LocationAnnotationView: View {
    let location: WalkLocation
    let index: Int
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(annotationColor.opacity(0.8))
                    .frame(width: 30, height: 30)
                
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 30, height: 30)
                
                if isFirst {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                } else if isLast {
                    Image(systemName: "flag.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                } else {
                    Text("\(index + 1)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            Text(location.name)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.9))
                )
                .foregroundColor(.primary)
        }
    }
    
    private var annotationColor: Color {
        if isFirst { return .green }
        if isLast { return .red }
        return .blue
    }
}

struct RouteSegmentView: View {
    let route: WalkRoute
    let index: Int
    let fromLocation: String
    let toLocation: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Segment \(index + 1)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text("\(fromLocation) → \(toLocation)")
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .lineLimit(1)
                
                HStack {
                    Text(route.totalDistance.formatAsDistance())
                        .font(.caption2)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(route.estimatedDuration.formatAsDuration())
                        .font(.caption2)
                }
                .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let sampleWalk = MultiLocationWalk(
        name: "NYC Walking Tour",
        locations: [
            WalkLocation(name: "Central Park", coordinate: CLLocationCoordinate2D(latitude: 40.785091, longitude: -73.968285), address: "New York, NY", type: .search),
            WalkLocation(name: "Times Square", coordinate: CLLocationCoordinate2D(latitude: 40.758896, longitude: -73.985130), address: "Manhattan, NY", type: .search),
            WalkLocation(name: "High Line", coordinate: CLLocationCoordinate2D(latitude: 40.748817, longitude: -74.004015), address: "New York, NY", type: .search)
        ],
        routes: [],
        totalDistance: 5000,
        estimatedDuration: 3600,
        createdAt: Date(),
        createdBy: "Demo User",
        isPublic: true
    )
    
    NavigationView {
        MultiLocationMapView(walk: sampleWalk)
    }
}

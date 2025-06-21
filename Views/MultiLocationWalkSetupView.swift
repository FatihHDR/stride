import SwiftUI
import CoreLocation

struct MultiLocationWalkSetupView: View {
    @EnvironmentObject var viewModel: MultiLocationWalkViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var sharingService: WalkSharingService
    @StateObject private var locationSearch = LocationSearchService()
    
    @State private var searchText = ""
    @State private var showingShareSheet = false
    @State private var shareURL: String = ""
    @State private var userName = "Anonymous"
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    // Modern Header
                    headerSection
                    
                    // Walk Information Card
                    walkInfoCard
                    
                    // Location Search Card
                    locationSearchCard
                    
                    // Locations List
                    if !viewModel.locations.isEmpty {
                        locationsCard
                    }
                    
                    // Route Options
                    routeOptionsCard
                    
                    // Generate Button
                    generateButton
                    
                    // Route Result
                    if let walk = viewModel.currentWalk {
                        RouteSuccessCard(walk: walk, onShare: shareWalk)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingShareSheet) {
            ShareSheetView(url: shareURL)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.green.opacity(0.1), .green.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "map.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.green)
                )
            
            VStack(spacing: 8) {
                Text("Multi-Location Walk")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Plan a route visiting multiple places")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Walk Info Card
    private var walkInfoCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Walk Details")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("Name")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 80, alignment: .leading)
                    
                    TextField("Enter walk name", text: $viewModel.walkName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack {
                    Text("Creator")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 80, alignment: .leading)
                    
                    TextField("Your name", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack {
                    Toggle("Make Public", isOn: $viewModel.isPublic)
                        .font(.system(size: 15, weight: .medium))
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Location Search Card
    private var locationSearchCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Add Locations")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                
                Button("Current Location") {
                    if let location = locationManager.location {
                        viewModel.addCurrentLocation(location)
                    }
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.1))
                )
            }
            
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                
                TextField("Search for places, addresses...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: searchText) { _ in
                        locationSearch.searchLocations(query: searchText)
                    }
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                        locationSearch.clearResults()
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            
            // Search Results
            if !locationSearch.searchResults.isEmpty {
                VStack(spacing: 8) {
                    ForEach(locationSearch.searchResults.prefix(5), id: \.self) { result in
                        LocationSearchResultRow(result: result) { location in
                            viewModel.addLocation(location)
                            searchText = ""
                            locationSearch.clearResults()
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Locations Card
    private var locationsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Route (\(viewModel.locations.count) stops)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if viewModel.locations.count >= 2 {
                    Text("≈ \(viewModel.totalEstimatedDistance.formatAsDistance())")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
            
            LazyVStack(spacing: 8) {
                ForEach(Array(viewModel.locations.enumerated()), id: \.element.id) { index, location in
                    ModernLocationRow(
                        location: location,
                        index: index,
                        isFirst: index == 0,
                        isLast: index == viewModel.locations.count - 1,
                        onDelete: {
                            viewModel.removeLocation(at: index)
                        }
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Route Options Card
    private var routeOptionsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Route Options")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Route Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Route Type")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Picker("Route Type", selection: $viewModel.routeType) {
                        Text("Direct Routes").tag(MultiLocationRouteGenerator.RouteOptions.RouteType.direct)
                        Text("Loop Route").tag(MultiLocationRouteGenerator.RouteOptions.RouteType.loop)
                        Text("Exploring Route").tag(MultiLocationRouteGenerator.RouteOptions.RouteType.exploring)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Optimize Toggle
                HStack {
                    Toggle("Optimize Route Order", isOn: $viewModel.optimizeOrder)
                        .font(.system(size: 15, weight: .medium))
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Generate Button
    private var generateButton: some View {
        Button {
            Task {
                await viewModel.generateWalk(createdBy: userName)
            }
        } label: {
            HStack(spacing: 12) {
                if viewModel.isGenerating {
                    ProgressView()
                        .scaleEffect(0.9)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 20))
                }
                
                Text(viewModel.isGenerating ? "Generating Routes..." : "Generate Multi-Location Walk")
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        viewModel.canGenerateWalk ? 
                        LinearGradient(
                            colors: [.green, .green.opacity(0.8)],
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
                color: viewModel.canGenerateWalk ? .green.opacity(0.3) : .clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .disabled(!viewModel.canGenerateWalk)
        .scaleEffect(viewModel.canGenerateWalk ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: viewModel.canGenerateWalk)
    }
    
    // MARK: - Helper Methods
    private func shareWalk() {
        Task {
            if let url = await viewModel.shareWalk(userName: userName) {
                shareURL = url
                showingShareSheet = true
            }
        }
    }
}

// MARK: - Supporting Views

struct LocationSearchResultRow: View {
    let result: MKMapItem
    let onSelect: (WalkLocation) -> Void
    
    var body: some View {
        Button {
            let location = WalkLocation(
                name: result.name ?? "Unknown Location",
                coordinate: result.placemark.coordinate,
                address: result.placemark.title,
                type: .search
            )
            onSelect(location)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.name ?? "Unknown Location")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if let address = result.placemark.title {
                        Text(address)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 16))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernLocationRow: View {
    let location: WalkLocation
    let index: Int
    let isFirst: Bool
    let isLast: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Index Circle
            Circle()
                .fill(indexColor)
                .frame(width: 32, height: 32)
                .overlay(
                    Text("\(index + 1)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )
            
            // Location Info
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let address = location.address {
                    Text(address)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Type Badge
            Text(location.type.displayName)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.1))
                )
            
            // Delete Button
            Button {
                onDelete()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 18))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.3))
        )
    }
    
    private var indexColor: Color {
        if isFirst { return .green }
        if isLast { return .red }
        return .blue
    }
}

struct RouteSuccessCard: View {
    let walk: MultiLocationWalk
    let onShare: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Success Header
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
                    Text("Multi-Location Walk Ready!")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("\(walk.locations.count) locations connected")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Stats Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                StatCard(icon: "ruler", title: "Distance", value: walk.totalDistance.formatAsDistance())
                StatCard(icon: "clock", title: "Duration", value: walk.estimatedDuration.formatAsDuration())
                StatCard(icon: "arrow.triangle.turn.up.right.diamond", title: "Routes", value: "\(walk.totalRoutes)")
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                NavigationLink(destination: MultiLocationMapView(walk: walk)) {
                    HStack(spacing: 8) {
                        Image(systemName: "map")
                        Text("View Map")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                    )
                    .foregroundColor(.green)
                }
                
                Button(action: onShare) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
                    .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct StatCard: View {
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
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Extensions

extension WalkLocation.LocationType {
    var displayName: String {
        switch self {
        case .currentLocation: return "Current"
        case .search: return "Search"
        case .userInput: return "Manual"
        case .saved: return "Saved"
        }
    }
}

#Preview {
    MultiLocationWalkSetupView()
        .environmentObject(MultiLocationWalkViewModel())
        .environmentObject(LocationManager())
        .environmentObject(WalkSharingService())
}

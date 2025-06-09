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
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        walkInfoSection
                        locationSearchSection
                        locationsListSection
                        routeOptionsSection
                        generateButtonSection
                        
                        if let walk = viewModel.currentWalk {
                            routeResultSection(walk: walk)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Multi-Location Walk")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        viewModel.clearWalk()
                    }
                    .disabled(viewModel.locations.isEmpty)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheetView(url: shareURL)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "map.fill")
                .font(.system(size: 32))
                .foregroundColor(.blue)
            
            Text("Create Multi-Location Walk")
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var walkInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Walk Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Name:")
                        .fontWeight(.medium)
                    TextField("Enter walk name", text: $viewModel.walkName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack {
                    Text("Username:")
                        .fontWeight(.medium)
                    TextField("Your name", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Toggle("Make Public", isOn: $viewModel.isPublic)
                    .toggleStyle(SwitchToggleStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2)
        )
    }
    
    private var locationSearchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Locations")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                TextField("Search for a location...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        performSearch()
                    }
                
                Button("Search") {
                    performSearch()
                }
                .buttonStyle(.bordered)
                .disabled(searchText.isEmpty)
            }
            
            HStack {
                Button("Add Current Location") {
                    if let location = locationManager.location {
                        viewModel.addCurrentLocation(location)
                    }
                }
                .buttonStyle(.bordered)
                .disabled(locationManager.location == nil)
                
                Spacer()
            }
            
            if locationSearch.isSearching {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Searching...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !locationSearch.searchResults.isEmpty {
                LazyVStack(spacing: 8) {
                    ForEach(locationSearch.searchResults, id: \.id) { location in
                        LocationSearchResultView(location: location) {
                            viewModel.addLocation(location)
                            locationSearch.searchResults = []
                            searchText = ""
                        }
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2)
        )
    }
    
    private var locationsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Locations (\(viewModel.locations.count))")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if viewModel.locations.count >= 2 {
                    Text("≈ \(viewModel.totalEstimatedDistance.formatAsDistance())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if viewModel.locations.isEmpty {
                Text("Add at least 2 locations to create a walk")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                ForEach(Array(viewModel.locations.enumerated()), id: \.element.id) { index, location in
                    LocationRowView(
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2)
        )
    }
    
    private var routeOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Route Options")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                Picker("Route Type", selection: $viewModel.routeType) {
                    Text("Direct Routes").tag(MultiLocationRouteGenerator.RouteOptions.RouteType.direct)
                    Text("Loop Route").tag(MultiLocationRouteGenerator.RouteOptions.RouteType.loop)
                    Text("Exploring Route").tag(MultiLocationRouteGenerator.RouteOptions.RouteType.exploring)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Toggle("Optimize Order", isOn: $viewModel.optimizeOrder)
                    .toggleStyle(SwitchToggleStyle())
                
                Text("Optimize order will arrange locations for the shortest total distance")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2)
        )
    }
    
    private var generateButtonSection: some View {
        Button {
            Task {
                await viewModel.generateWalk(createdBy: userName)
            }
        } label: {
            HStack {
                if viewModel.isGenerating {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "map")
                }
                
                Text(viewModel.isGenerating ? "Generating..." : "Generate Walk")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(viewModel.canGenerateWalk ? Color.blue : Color.gray)
            )
            .foregroundColor(.white)
        }
        .disabled(!viewModel.canGenerateWalk)
        
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.caption)
                .foregroundColor(.red)
                .padding(.top, 4)
        }
    }
    
    private func routeResultSection(walk: MultiLocationWalk) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Walk Generated!")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Total Distance:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(walk.totalDistance.formatAsDistance())
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Estimated Duration:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(walk.estimatedDuration.formatAsDuration())
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Total Routes:")
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(walk.totalRoutes)")
                        .fontWeight(.semibold)
                }
            }
            
            HStack(spacing: 12) {
                NavigationLink(destination: MultiLocationMapView(walk: walk)) {
                    HStack {
                        Image(systemName: "map")
                        Text("View Map")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
                
                Button {
                    Task {
                        if let url = await viewModel.shareWalk(userName: userName) {
                            shareURL = url
                            showingShareSheet = true
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2)
        )
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let region = locationManager.location.map { location in
            MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 10000,
                longitudinalMeters: 10000
            )
        }
        
        locationSearch.searchLocations(query: searchText, region: region)
    }
}

#Preview {
    MultiLocationWalkSetupView()
        .environmentObject(MultiLocationWalkViewModel())
        .environmentObject(LocationManager())
        .environmentObject(WalkSharingService())
}

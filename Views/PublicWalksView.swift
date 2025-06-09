import SwiftUI

struct PublicWalksView: View {
    @EnvironmentObject var sharingService: WalkSharingService
    @EnvironmentObject var multiLocationViewModel: MultiLocationWalkViewModel
    @State private var searchText = ""
    @State private var showingShareCodeAlert = false
    @State private var shareCodeInput = ""
    @State private var selectedWalk: SharedWalk?
    @State private var showingWalkDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Load Section
                VStack(spacing: 16) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search public walks...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Load from share code
                    Button("Load Walk from Share Code") {
                        showingShareCodeAlert = true
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Public Walks List
                if sharingService.isLoading {
                    Spacer()
                    ProgressView("Loading public walks...")
                    Spacer()
                } else if filteredWalks.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "figure.walk.circle")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        
                        Text("No Public Walks Found")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Be the first to share a walk with the community!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    List(filteredWalks, id: \.id) { sharedWalk in
                        PublicWalkRowView(sharedWalk: sharedWalk) {
                            selectedWalk = sharedWalk
                            showingWalkDetail = true
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Public Walks")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await sharingService.loadPublicWalks()
            }
            .onAppear {
                Task {
                    await sharingService.loadPublicWalks()
                }
            }
            .alert("Enter Share Code", isPresented: $showingShareCodeAlert) {
                TextField("Share code", text: $shareCodeInput)
                    .textInputAutocapitalization(.characters)
                
                Button("Load") {
                    loadWalkFromShareCode()
                }
                .disabled(shareCodeInput.isEmpty)
                
                Button("Cancel", role: .cancel) {
                    shareCodeInput = ""
                }
            } message: {
                Text("Enter the 8-character share code to load a walk")
            }
            .sheet(isPresented: $showingWalkDetail) {
                if let walk = selectedWalk {
                    PublicWalkDetailView(sharedWalk: walk)
                }
            }
        }
    }
    
    private var filteredWalks: [SharedWalk] {
        if searchText.isEmpty {
            return sharingService.publicWalks
        } else {
            return sharingService.publicWalks.filter { walk in
                walk.walk.name.localizedCaseInsensitiveContains(searchText) ||
                walk.walk.createdBy.localizedCaseInsensitiveContains(searchText) ||
                walk.walk.locations.contains { location in
                    location.name.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }
    
    private func loadWalkFromShareCode() {
        guard !shareCodeInput.isEmpty else { return }
        
        Task {
            do {
                let walk = try await sharingService.loadWalk(shareCode: shareCodeInput)
                
                await MainActor.run {
                    // Load the walk into our multi-location view model
                    multiLocationViewModel.clearWalk()
                    multiLocationViewModel.walkName = walk.name + " (Imported)"
                    
                    for location in walk.locations {
                        multiLocationViewModel.addLocation(location)
                    }
                    
                    shareCodeInput = ""
                }
            } catch {
                await MainActor.run {
                    sharingService.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct PublicWalkRowView: View {
    let sharedWalk: SharedWalk
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sharedWalk.walk.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("by \(sharedWalk.walk.createdBy)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(String(format: "%.1f", sharedWalk.rating))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        
                        Text("\(sharedWalk.downloadCount) downloads")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Label(sharedWalk.walk.totalDistance.formatAsDistance(), systemImage: "ruler")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(sharedWalk.walk.estimatedDuration.formatAsDuration(), systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(sharedWalk.walk.locations.count) stops", systemImage: "location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(sharedWalk.shareCode)
                        .font(.caption)
                        .fontFamily(.monospaced)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
                
                if !sharedWalk.walk.locations.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(sharedWalk.walk.locations.prefix(5).enumerated()), id: \.element.id) { index, location in
                                Text(location.name)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(6)
                            }
                            
                            if sharedWalk.walk.locations.count > 5 {
                                Text("+\(sharedWalk.walk.locations.count - 5) more")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray5))
                                    .foregroundColor(.secondary)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct PublicWalkDetailView: View {
    let sharedWalk: SharedWalk
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var multiLocationViewModel: MultiLocationWalkViewModel
    @State private var showingImportAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Walk Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(sharedWalk.walk.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Created by \(sharedWalk.walk.createdBy)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Shared on \(sharedWalk.sharedAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Walk Stats
                    HStack(spacing: 20) {
                        VStack {
                            Text(sharedWalk.walk.totalDistance.formatAsDistance())
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            Text("Distance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text(sharedWalk.walk.estimatedDuration.formatAsDuration())
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                            Text("Duration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(sharedWalk.walk.locations.count)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            Text("Locations")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Rating and Downloads
                    HStack {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", sharedWalk.rating))
                                .fontWeight(.medium)
                            Text("(\(sharedWalk.reviews.count) reviews)")
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(sharedWalk.downloadCount) downloads")
                            .foregroundColor(.secondary)
                    }
                    
                    // Locations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Locations")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ForEach(Array(sharedWalk.walk.locations.enumerated()), id: \.element.id) { index, location in
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 24, height: 24)
                                    
                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(location.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    if let address = location.address {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        NavigationLink(destination: MultiLocationMapView(walk: sharedWalk.walk)) {
                            HStack {
                                Image(systemName: "map")
                                Text("View on Map")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button {
                            showingImportAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Import Walk")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Walk Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Import Walk", isPresented: $showingImportAlert) {
                Button("Import") {
                    importWalk()
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will replace your current walk setup. Continue?")
            }
        }
    }
    
    private func importWalk() {
        multiLocationViewModel.clearWalk()
        multiLocationViewModel.walkName = sharedWalk.walk.name + " (Imported)"
        
        for location in sharedWalk.walk.locations {
            multiLocationViewModel.addLocation(location)
        }
    }
}

#Preview {
    PublicWalksView()
        .environmentObject(WalkSharingService())
        .environmentObject(MultiLocationWalkViewModel())
}

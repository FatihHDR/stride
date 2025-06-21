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
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Modern Header
                headerSection
                
                // Search and Actions
                searchSection
                
                // Content
                if sharingService.isLoading {
                    LoadingSection()
                } else if filteredWalks.isEmpty {
                    EmptyStateSection()
                } else {
                    WalksList()
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .background(Color(.systemGroupedBackground))
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
                PublicWalkDetailView(sharedWalk: walk, multiLocationViewModel: multiLocationViewModel)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.1), .purple.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.purple)
                )
            
            VStack(spacing: 8) {
                Text("Explore Walks")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Discover amazing walks from the community")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(spacing: 16) {
            // Search Bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                
                TextField("Search walks, places, creators...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            
            // Share Code Button
            Button {
                showingShareCodeAlert = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16))
                    Text("Load from Share Code")
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.1))
                )
                .foregroundColor(.purple)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Content Sections
    @ViewBuilder
    private func LoadingSection() -> some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Discovering amazing walks...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func EmptyStateSection() -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "figure.walk.motion")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                )
            
            VStack(spacing: 8) {
                Text("No Walks Found")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(searchText.isEmpty ? "Check back later for new walks" : "Try a different search term")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Refresh") {
                Task {
                    await sharingService.loadPublicWalks()
                }
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    @ViewBuilder
    private func WalksList() -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredWalks, id: \.id) { walk in
                    ModernWalkCard(walk: walk) {
                        selectedWalk = walk
                        showingWalkDetail = true
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Computed Properties
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
    
    // MARK: - Helper Methods
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

// MARK: - Supporting Views

struct ModernWalkCard: View {
    let walk: SharedWalk
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(walk.walk.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Text("by \(walk.walk.createdBy)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 12))
                            Text(String(format: "%.1f", walk.rating))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Text("\(walk.downloadCount) downloads")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Stats
                HStack(spacing: 16) {
                    StatBadge(
                        icon: "ruler",
                        value: walk.walk.totalDistance.formatAsDistance(),
                        color: .blue
                    )
                    
                    StatBadge(
                        icon: "clock",
                        value: walk.walk.estimatedDuration.formatAsDuration(),
                        color: .orange
                    )
                    
                    StatBadge(
                        icon: "location",
                        value: "\(walk.walk.locations.count) stops",
                        color: .green
                    )
                    
                    Spacer()
                    
                    // Share Code
                    Text(walk.shareCode)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.systemGray6))
                        )
                }
                
                // Locations Preview
                if !walk.walk.locations.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(walk.walk.locations.prefix(4).enumerated()), id: \.element.id) { index, location in
                                Text(location.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.blue.opacity(0.1))
                                    )
                            }
                            
                            if walk.walk.locations.count > 4 {
                                Text("+\(walk.walk.locations.count - 4) more")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(.systemGray6))
                                    )
                            }
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

struct PublicWalkDetailView: View {
    let sharedWalk: SharedWalk
    let multiLocationViewModel: MultiLocationWalkViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingImportAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text(sharedWalk.walk.name)
                            .font(.system(size: 24, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 16) {
                            StatBadge(icon: "ruler", value: sharedWalk.walk.totalDistance.formatAsDistance(), color: .blue)
                            StatBadge(icon: "clock", value: sharedWalk.walk.estimatedDuration.formatAsDuration(), color: .orange)
                            StatBadge(icon: "location", value: "\(sharedWalk.walk.locations.count) stops", color: .green)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", sharedWalk.rating))
                                .font(.system(size: 16, weight: .semibold))
                            Text("(\(sharedWalk.downloadCount) downloads)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Locations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Route Locations")
                            .font(.system(size: 18, weight: .semibold))
                        
                        ForEach(Array(sharedWalk.walk.locations.enumerated()), id: \.element.id) { index, location in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(index == 0 ? .green : index == sharedWalk.walk.locations.count - 1 ? .red : .blue)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text("\(index + 1)")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(location.name)
                                        .font(.system(size: 15, weight: .medium))
                                    
                                    if let address = location.address {
                                        Text(address)
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6).opacity(0.5))
                            )
                        }
                    }
                    
                    // Import Button
                    Button {
                        showingImportAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import This Walk")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                        .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(20)
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

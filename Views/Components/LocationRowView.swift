import SwiftUI

struct LocationSearchResultView: View {
    let location: WalkLocation
    let onAdd: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let address = location.address {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text("\(String(format: "%.4f", location.coordinate.latitude)), \(String(format: "%.4f", location.coordinate.longitude))")
                    .font(.caption)
                    .fontFamily(.monospaced)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Add") {
                onAdd()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

struct LocationRowView: View {
    let location: WalkLocation
    let index: Int
    let isFirst: Bool
    let isLast: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            // Order indicator
            ZStack {
                Circle()
                    .fill(locationTypeColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                if isFirst {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(locationTypeColor)
                } else if isLast {
                    Image(systemName: "flag.fill")
                        .font(.caption)
                        .foregroundColor(locationTypeColor)
                } else {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(locationTypeColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(location.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(locationTypeText)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(locationTypeColor.opacity(0.1))
                        .foregroundColor(locationTypeColor)
                        .cornerRadius(4)
                }
                
                if let address = location.address {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Button {
                onDelete()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
    
    private var locationTypeColor: Color {
        switch location.type {
        case .currentLocation:
            return .blue
        case .search:
            return .green
        case .userInput:
            return .orange
        case .saved:
            return .purple
        }
    }
    
    private var locationTypeText: String {
        switch location.type {
        case .currentLocation:
            return "Current"
        case .search:
            return "Search"
        case .userInput:
            return "Manual"
        case .saved:
            return "Saved"
        }
    }
}

#Preview {
    VStack {
        LocationSearchResultView(
            location: WalkLocation(
                name: "Central Park",
                coordinate: CLLocationCoordinate2D(latitude: 40.785091, longitude: -73.968285),
                address: "New York, NY, USA",
                type: .search
            )
        ) {
            print("Added location")
        }
        
        LocationRowView(
            location: WalkLocation(
                name: "Times Square",
                coordinate: CLLocationCoordinate2D(latitude: 40.758896, longitude: -73.985130),
                address: "Manhattan, NY, USA",
                type: .search
            ),
            index: 0,
            isFirst: true,
            isLast: false
        ) {
            print("Delete location")
        }
    }
    .padding()
}

import SwiftUI

struct ShareSheetView: View {
    let url: String
    @Environment(\.dismiss) private var dismiss
    @State private var showingActivityView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    Text("Share Your Walk")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Share this walk with friends or the Stride community")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Share URL
                VStack(alignment: .leading, spacing: 8) {
                    Text("Share Link")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text(url)
                            .font(.caption)
                            .fontFamily(.monospaced)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .lineLimit(1)
                        
                        Button("Copy") {
                            UIPasteboard.general.string = url
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                
                // Share Options
                VStack(spacing: 16) {
                    Button {
                        showingActivityView = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share via...")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button {
                        // Copy to clipboard
                        UIPasteboard.general.string = url
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.clipboard")
                            Text("Copy Link")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Share Walk")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingActivityView) {
            ActivityViewController(activityItems: [url])
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    ShareSheetView(url: "https://stride.app/walk/ABC123XY")
}

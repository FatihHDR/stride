import SwiftUI

struct TimePickerView: View {
    @Binding var selectedDuration: Double
    let range: ClosedRange<Double>
    let step: Double
    
    init(duration: Binding<Double>, 
         range: ClosedRange<Double> = 5...60, 
         step: Double = 5) {
        self._selectedDuration = duration
        self.range = range
        self.step = step
    }
    
    var body: some View {
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
            
            VStack(spacing: 12) {
                Slider(value: $selectedDuration, in: range, step: step)
                    .accentColor(.blue)
                    .padding(.horizontal, 4)
                
                HStack {
                    Text("\(Int(range.lowerBound)) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(range.upperBound)) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)
            }
            
            // Duration suggestions
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(durationSuggestions, id: \.self) { suggestion in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedDuration = suggestion
                        }
                    } label: {
                        Text("\(Int(suggestion))m")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedDuration == suggestion ? .white : .blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedDuration == suggestion ? Color.blue : Color.blue.opacity(0.1))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.3))
        )
    }
    
    private var durationSuggestions: [Double] {
        [15, 30, 45, 60]
    }
}

#Preview {
    VStack {
        TimePickerView(duration: .constant(30))
        Spacer()
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

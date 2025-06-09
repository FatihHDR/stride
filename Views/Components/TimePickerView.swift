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
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text("Walk Duration")
                    .font(.headline)
                Spacer()
                Text("\(Int(selectedDuration)) min")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            Slider(value: $selectedDuration, in: range, step: step) {
                Text("Duration")
            } minimumValueLabel: {
                Text("\(Int(range.lowerBound))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } maximumValueLabel: {
                Text("\(Int(range.upperBound))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .accentColor(.blue)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Estimated Distance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", estimatedDistance)) km")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Estimated Steps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(estimatedSteps))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private var estimatedDistance: Double {
        let distanceInMeters = selectedDuration * 60 * Constants.averageWalkingSpeed
        return distanceInMeters / 1000 // Convert to kilometers
    }
    
    private var estimatedSteps: Double {
        let distanceInMeters = selectedDuration * 60 * Constants.averageWalkingSpeed
        return distanceInMeters * 1.3 // Approximate steps per meter
    }
}

#Preview {
    TimePickerView(duration: .constant(15))
        .padding()
}

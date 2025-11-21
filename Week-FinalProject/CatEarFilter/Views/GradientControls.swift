import SwiftUI

struct GradientControls: View {
    @Binding var config: EarConfiguration
    @State private var selectedStopIndex: Int?
    
    var body: some View {
        VStack(spacing: 16) {
            Toggle("Use Gradient", isOn: $config.useGradient)
                .foregroundColor(.white)
            
            if config.useGradient {
                // Gradient angle
                SliderControl(
                    label: "Gradient Angle",
                    value: $config.gradientAngle,
                    range: 0...Float.pi * 2,
                    step: 0.01
                )
                
                // Gradient preview
                GradientPreview(stops: config.gradientStops, angle: config.gradientAngle)
                    .frame(height: 60)
                    .cornerRadius(8)
                
                // Gradient stops list
                VStack(spacing: 8) {
                    ForEach(Array(config.gradientStops.enumerated()), id: \.element.id) { index, stop in
                        GradientStopRow(
                            stop: stop,
                            index: index,
                            isSelected: selectedStopIndex == index,
                            onSelect: {
                                selectedStopIndex = index
                            },
                            onDelete: {
                                if config.gradientStops.count > 2 {
                                    config.gradientStops.remove(at: index)
                                    if selectedStopIndex == index {
                                        selectedStopIndex = nil
                                    }
                                }
                            }
                        )
                    }
                }
                
                // Add stop button
                Button(action: addGradientStop) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Color Stop")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Edit selected stop
                if let selectedIndex = selectedStopIndex,
                   selectedIndex < config.gradientStops.count {
                    VStack(spacing: 12) {
                        Text("Edit Stop \(selectedIndex + 1)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        ColorPicker("Color", selection: Binding(
                            get: { config.gradientStops[selectedIndex].color.color },
                            set: { config.gradientStops[selectedIndex].color = CodableColor(color: $0) }
                        ))
                        .foregroundColor(.white)
                        
                        SliderControl(
                            label: "Position",
                            value: $config.gradientStops[selectedIndex].position,
                            range: 0...1,
                            step: 0.01
                        )
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                
                // Reset button
                Button("Reset to Defaults") {
                    resetGradient()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private func addGradientStop() {
        let newPosition: Float = config.gradientStops.isEmpty ? 0.5 :
            (config.gradientStops.map { $0.position }.max() ?? 0.5)
        let newStop = GradientStop(
            color: CodableColor(color: .white),
            position: min(newPosition + 0.1, 1.0)
        )
        config.gradientStops.append(newStop)
        config.gradientStops.sort { $0.position < $1.position }
    }
    
    private func resetGradient() {
        config.gradientStops = [
            GradientStop(color: CodableColor(color: .gray), position: 0.0),
            GradientStop(color: CodableColor(color: .white), position: 1.0)
        ]
        config.gradientAngle = 0.0
        selectedStopIndex = nil
    }
}

struct GradientStopRow: View {
    let stop: GradientStop
    let index: Int
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onSelect) {
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(stop.color.color)
                        .frame(width: 30, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isSelected ? Color.white : Color.white.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                        )
                    
                    Text("Stop \(index + 1)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(Int(stop.position * 100))%")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

struct GradientPreview: View {
    let stops: [GradientStop]
    let angle: Float
    
    var body: some View {
        if stops.count >= 2 {
            let gradient = LinearGradient(
                stops: stops.sorted { $0.position < $1.position }.map { stop in
                    Gradient.Stop(color: stop.color.color, location: CGFloat(stop.position))
                },
                startPoint: startPoint,
                endPoint: endPoint
            )
            
            Rectangle()
                .fill(gradient)
        } else {
            Rectangle()
                .fill(Color.gray)
        }
    }
    
    private var startPoint: UnitPoint {
        let radians = CGFloat(angle)
        let x = 0.5 - 0.5 * cos(radians)
        let y = 0.5 - 0.5 * sin(radians)
        return UnitPoint(x: x, y: y)
    }
    
    private var endPoint: UnitPoint {
        let radians = CGFloat(angle)
        let x = 0.5 + 0.5 * cos(radians)
        let y = 0.5 + 0.5 * sin(radians)
        return UnitPoint(x: x, y: y)
    }
}

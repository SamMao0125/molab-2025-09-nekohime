import SwiftUI

struct CustomizationSheet: View {
    @Binding var config: EarConfiguration
    @Binding var isPresented: Bool
    let onSavePreset: () -> Void
    
    @State private var expandedSections: Set<CustomizationSection> = [.position]
    @State private var showSaveDialog = false
    @State private var presetName = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 0) {
                // Handle bar
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                
                // Header
                HStack {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Customize")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Save Preset") {
                        onSavePreset()
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                // Scrollable content
                ScrollView {
                    VStack(spacing: 0) {
                        CollapsibleSection(
                            title: "Position",
                            isExpanded: expandedSections.contains(.position)
                        ) {
                            toggleSection(.position)
                        } content: {
                            PositionControls(config: $config)
                        }
                        
                        CollapsibleSection(
                            title: "Transform",
                            isExpanded: expandedSections.contains(.transform)
                        ) {
                            toggleSection(.transform)
                        } content: {
                            TransformControls(config: $config)
                        }
                        
                        CollapsibleSection(
                            title: "Colors",
                            isExpanded: expandedSections.contains(.colors)
                        ) {
                            toggleSection(.colors)
                        } content: {
                            ColorControls(config: $config)
                        }
                        
                        CollapsibleSection(
                            title: "Gradient",
                            isExpanded: expandedSections.contains(.gradient)
                        ) {
                            toggleSection(.gradient)
                        } content: {
                            GradientControls(config: $config)
                        }
                        
                        CollapsibleSection(
                            title: "Shadow",
                            isExpanded: expandedSections.contains(.shadow)
                        ) {
                            toggleSection(.shadow)
                        } content: {
                            ShadowControls(config: $config)
                        }
                        
                        CollapsibleSection(
                            title: "Outline",
                            isExpanded: expandedSections.contains(.outline)
                        ) {
                            toggleSection(.outline)
                        } content: {
                            OutlineControls(config: $config)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
            .background(Color.black)
            .cornerRadius(20, corners: [.topLeft, .topRight])
        }
        .ignoresSafeArea()
    }
    
    private func toggleSection(_ section: CustomizationSection) {
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
    }
}

enum CustomizationSection: Hashable {
    case position, transform, colors, gradient, shadow, outline
}

struct CollapsibleSection<Content: View>: View {
    let title: String
    let isExpanded: Bool
    let onToggle: () -> Void
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                }
                .padding()
                .background(Color.white.opacity(0.05))
            }
            
            if isExpanded {
                content
                    .padding()
                    .background(Color.black)
            }
        }
    }
}

// Position controls with X/Y sliders
struct PositionControls: View {
    @Binding var config: EarConfiguration
    
    var body: some View {
        VStack(spacing: 16) {
            SliderControl(
                label: "X Position",
                value: $config.xPosition,
                range: -0.1...0.1,
                step: 0.001
            )
            
            SliderControl(
                label: "Y Position",
                value: $config.yPosition,
                range: -0.1...0.1,
                step: 0.001
            )
            
            SliderControl(
                label: "Z Position",
                value: $config.zPosition,
                range: -0.05...0.05,
                step: 0.001
            )
        }
    }
}

// Transform controls with size and rotation
struct TransformControls: View {
    @Binding var config: EarConfiguration
    
    var body: some View {
        VStack(spacing: 16) {
            SliderControl(
                label: "Size",
                value: $config.size,
                range: 0.5...2.0,
                step: 0.01
            )
            
            Toggle("Sync Rotation", isOn: $config.syncRotation)
                .foregroundColor(.white)
            
            SliderControl(
                label: "Left Rotation",
                value: $config.leftRotation,
                range: -Float.pi...Float.pi,
                step: 0.01
            )
            
            if !config.syncRotation {
                SliderControl(
                    label: "Right Rotation",
                    value: $config.rightRotation,
                    range: -Float.pi...Float.pi,
                    step: 0.01
                )
            }
            
            HStack(spacing: 12) {
                Button("Mirror") {
                    config.rightRotation = -config.leftRotation
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                
                Button("Reset") {
                    resetTransform()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private func resetTransform() {
        config.size = 1.0
        config.leftRotation = 0.0
        config.rightRotation = 0.0
    }
}

// Reusable slider control
struct SliderControl: View {
    let label: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    let step: Float
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text(String(format: "%.3f", value))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .monospacedDigit()
            }
            
            Slider(value: $value, in: range, step: step)
                .tint(.white)
        }
    }
}

// Corner radius extension for specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

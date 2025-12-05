import SwiftUI

struct CustomizationSheet: View {
    @Binding var config: EarConfiguration
    @Binding var isPresented: Bool
    let onSavePreset: () -> Void
    
    @State private var expandedSections: Set<CustomizationSection> = [.position]
    @State private var showSaveDialog = false
    @State private var presetName = ""
    
    // Drag state
    @State private var dragOffset: CGFloat = 0
    @State private var currentHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    
    // Height constraints
    private let minHeight: CGFloat = UIScreen.main.bounds.height * 0.3
    private let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.85
    private let defaultHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 0) {
                // Draggable handle bar
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newHeight = currentHeight - value.translation.height
                                dragOffset = value.translation.height
                                
                                if newHeight >= minHeight && newHeight <= maxHeight {
                                    currentHeight = newHeight
                                }
                            }
                            .onEnded { _ in
                                dragOffset = 0
                            }
                    )
                
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
                            title: "Distance",
                            isExpanded: expandedSections.contains(.distance)
                        ) {
                            toggleSection(.distance)
                        } content: {
                            DistanceControls(config: $config)
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
                    .padding(.bottom, 100)
                }
            }
            .frame(height: currentHeight)
            .background(Color.black)
            .cornerRadius(20, corners: [.topLeft, .topRight])
        }
        .ignoresSafeArea()
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentHeight)
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
    case position, distance, transform, colors, gradient, shadow, outline
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

struct DistanceControls: View {
    @Binding var config: EarConfiguration
    
    var body: some View {
        VStack(spacing: 16) {
            SliderControl(
                label: "Ear Spacing",
                value: $config.distance,
                range: 0.04...0.15,
                step: 0.001
            )
            
            HStack(spacing: 12) {
                Button("Narrow") {
                    config.distance = 0.06
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                
                Button("Normal") {
                    config.distance = 0.08
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                
                Button("Wide") {
                    config.distance = 0.11
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

struct TransformControls: View {
    @Binding var config: EarConfiguration
    
    var body: some View {
        VStack(spacing: 16) {
            Toggle("Lock Proportions", isOn: $config.lockScale)
                .foregroundColor(.white)
                .onChange(of: config.lockScale) { oldValue, newValue in
                    if newValue {
                        config.scaleWidth = config.size
                        config.scaleHeight = config.size
                    } else {
                        config.scaleWidth = config.size
                        config.scaleHeight = config.size
                    }
                }
            
            if config.lockScale {
                SliderControl(
                    label: "Size",
                    value: $config.size,
                    range: 0.5...2.0,
                    step: 0.01
                )
                .onChange(of: config.size) { oldValue, newValue in
                    config.scaleWidth = newValue
                    config.scaleHeight = newValue
                }
            } else {
                SliderControl(
                    label: "Width",
                    value: $config.scaleWidth,
                    range: 0.5...2.0,
                    step: 0.01
                )
                
                SliderControl(
                    label: "Height",
                    value: $config.scaleHeight,
                    range: 0.5...2.0,
                    step: 0.01
                )
            }
            
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
        config.scaleWidth = 1.0
        config.scaleHeight = 1.0
        config.lockScale = true
        config.leftRotation = 0.0
        config.rightRotation = 0.0
    }
}

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

import SwiftUI

struct ShadowControls: View {
    @Binding var config: EarConfiguration
    
    var body: some View {
        VStack(spacing: 16) {
            SliderControl(
                label: "Shadow Opacity",
                value: $config.shadowOpacity,
                range: 0...1,
                step: 0.01
            )
            
            SliderControl(
                label: "Shadow Blur",
                value: $config.shadowBlur,
                range: 0...0.05,
                step: 0.001
            )
            
            SliderControl(
                label: "Shadow Offset X",
                value: $config.shadowOffsetX,
                range: -0.05...0.05,
                step: 0.001
            )
            
            SliderControl(
                label: "Shadow Offset Y",
                value: $config.shadowOffsetY,
                range: -0.05...0.05,
                step: 0.001
            )
            
            Button("Reset Shadow") {
                config.shadowOpacity = 0.5
                config.shadowBlur = 0.01
                config.shadowOffsetX = 0.0
                config.shadowOffsetY = -0.01
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct OutlineControls: View {
    @Binding var config: EarConfiguration
    @State private var showColorPicker = false
    
    var body: some View {
        VStack(spacing: 16) {
            Toggle("Enable Outline", isOn: $config.hasOutline)
                .foregroundColor(.white)
            
            if config.hasOutline {
                // Outline color
                ColorPickerRow(
                    label: "Outline Color",
                    color: config.outlineColor.color,
                    isPickerShowing: $showColorPicker
                )
                
                if showColorPicker {
                    ColorPicker("Outline Color", selection: Binding(
                        get: { config.outlineColor.color },
                        set: { config.outlineColor = CodableColor(color: $0) }
                    ))
                    .foregroundColor(.white)
                }
                
                SliderControl(
                    label: "Outline Width",
                    value: $config.outlineWidth,
                    range: 0.001...0.05,
                    step: 0.001
                )
            }
        }
    }
}

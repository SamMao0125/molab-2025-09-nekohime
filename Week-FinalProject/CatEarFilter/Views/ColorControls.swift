import SwiftUI

struct ColorControls: View {
    @Binding var config: EarConfiguration
    @State private var showOuterColorPicker = false
    @State private var showInnerColorPicker = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Outer color
            ColorPickerRow(
                label: "Outer Color",
                color: config.outerColor.color,
                isPickerShowing: $showOuterColorPicker
            )
            
            if showOuterColorPicker {
                AdvancedColorPicker(
                    selectedColor: Binding(
                        get: { config.outerColor.color },
                        set: { config.outerColor = CodableColor(color: $0) }
                    )
                )
            }
            
            // Inner color
            ColorPickerRow(
                label: "Inner Color",
                color: config.innerColor.color,
                isPickerShowing: $showInnerColorPicker
            )
            
            if showInnerColorPicker {
                AdvancedColorPicker(
                    selectedColor: Binding(
                        get: { config.innerColor.color },
                        set: { config.innerColor = CodableColor(color: $0) }
                    )
                )
            }
        }
    }
}

struct ColorPickerRow: View {
    let label: String
    let color: Color
    @Binding var isPickerShowing: Bool
    
    var body: some View {
        Button(action: {
            isPickerShowing.toggle()
        }) {
            HStack {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }
}

struct AdvancedColorPicker: View {
    @Binding var selectedColor: Color
    @State private var hue: Double = 0.0
    @State private var saturation: Double = 1.0
    @State private var brightness: Double = 1.0
    @State private var hexInput: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // HSB Sliders
            VStack(spacing: 12) {
                ColorSlider(label: "Hue", value: $hue, range: 0...1) { value in
                    updateColor()
                }
                
                ColorSlider(label: "Saturation", value: $saturation, range: 0...1) { value in
                    updateColor()
                }
                
                ColorSlider(label: "Brightness", value: $brightness, range: 0...1) { value in
                    updateColor()
                }
            }
            
            // Hex input
            HStack {
                Text("Hex")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                TextField("", text: $hexInput)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .onChange(of: hexInput) { oldValue, newValue in
                        if let color = Color(hex: newValue) {
                            selectedColor = color
                            extractHSB()
                        }
                    }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .onAppear {
            extractHSB()
            updateHexInput()
        }
    }
    
    private func updateColor() {
        selectedColor = Color(hue: hue, saturation: saturation, brightness: brightness)
        updateHexInput()
    }
    
    private func extractHSB() {
        let uiColor = UIColor(selectedColor)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        hue = Double(h)
        saturation = Double(s)
        brightness = Double(b)
    }
    
    private func updateHexInput() {
        hexInput = selectedColor.toHex()
    }
}

struct ColorSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let onChange: (Double) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                Text(String(format: "%.2f", value))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .monospacedDigit()
            }
            
            Slider(value: $value, in: range)
                .tint(.white)
                .onChange(of: value) { oldValue, newValue in
                    onChange(newValue)
                }
        }
    }
}

// Color extension for hex support
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        guard Scanner(string: hex).scanHexInt64(&int) else { return nil }
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format: "%06X", rgb)
    }
}

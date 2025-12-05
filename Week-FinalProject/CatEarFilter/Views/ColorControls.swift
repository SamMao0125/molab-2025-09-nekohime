import SwiftUI

struct ColorControls: View {
    @Binding var config: EarConfiguration
    
    var body: some View {
        VStack(spacing: 20) {
            // Outer Ear Color Picker
            VStack(alignment: .leading, spacing: 12) {
                Text("Outer Ear Color")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                ColorPicker("", selection: Binding(
                    get: { config.outerColor.color },
                    set: { config.outerColor = CodableColor(color: $0) }
                ))
                .labelsHidden()
                .frame(height: 40)
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Inner Ear Color Picker
            VStack(alignment: .leading, spacing: 12) {
                Text("Inner Ear Color")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                ColorPicker("", selection: Binding(
                    get: { config.innerColor.color },
                    set: { config.innerColor = CodableColor(color: $0) }
                ))
                .labelsHidden()
                .frame(height: 40)
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Quick Color Presets
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Presets")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ColorPresetButton(
                            outerColor: .gray,
                            innerColor: Color(white: 0.8),
                            label: "Classic"
                        ) {
                            config.outerColor = CodableColor(color: .gray)
                            config.innerColor = CodableColor(color: Color(white: 0.8))
                        }
                        
                        ColorPresetButton(
                            outerColor: Color(red: 1.0, green: 0.75, blue: 0.8),
                            innerColor: Color(red: 1.0, green: 0.4, blue: 0.6),
                            label: "Pink"
                        ) {
                            config.outerColor = CodableColor(color: Color(red: 1.0, green: 0.75, blue: 0.8))
                            config.innerColor = CodableColor(color: Color(red: 1.0, green: 0.4, blue: 0.6))
                        }
                        
                        ColorPresetButton(
                            outerColor: .black,
                            innerColor: Color(white: 0.3),
                            label: "Black"
                        ) {
                            config.outerColor = CodableColor(color: .black)
                            config.innerColor = CodableColor(color: Color(white: 0.3))
                        }
                        
                        ColorPresetButton(
                            outerColor: .white,
                            innerColor: Color(red: 1.0, green: 0.8, blue: 0.9),
                            label: "White"
                        ) {
                            config.outerColor = CodableColor(color: .white)
                            config.innerColor = CodableColor(color: Color(red: 1.0, green: 0.8, blue: 0.9))
                        }
                        
                        ColorPresetButton(
                            outerColor: Color(red: 1.0, green: 0.6, blue: 0.3),
                            innerColor: Color(red: 1.0, green: 0.8, blue: 0.6),
                            label: "Ginger"
                        ) {
                            config.outerColor = CodableColor(color: Color(red: 1.0, green: 0.6, blue: 0.3))
                            config.innerColor = CodableColor(color: Color(red: 1.0, green: 0.8, blue: 0.6))
                        }
                        
                        ColorPresetButton(
                            outerColor: Color(red: 0.4, green: 0.26, blue: 0.13),
                            innerColor: Color(red: 0.8, green: 0.6, blue: 0.4),
                            label: "Brown"
                        ) {
                            config.outerColor = CodableColor(color: Color(red: 0.4, green: 0.26, blue: 0.13))
                            config.innerColor = CodableColor(color: Color(red: 0.8, green: 0.6, blue: 0.4))
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}

struct ColorPresetButton: View {
    let outerColor: Color
    let innerColor: Color
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(outerColor)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .fill(innerColor)
                        .frame(width: 25, height: 25)
                }
                
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 70)
        }
    }
}

// This is needed by OutlineControls in ShadowControls.swift
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

import SwiftUI

// MARK: - ColorSectionView
struct ColorSectionView: View {
    @Binding var outerEarColor: Color
    @Binding var innerEarColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Colors")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                VStack {
                    Text("Outer Color")
                        .font(.caption)
                        .foregroundColor(.white)
                    ColorPicker("", selection: $outerEarColor)
                        .labelsHidden()
                        .scaleEffect(1.3)
                }
                
                Spacer()
                
                VStack {
                    Text("Inner Color")
                        .font(.caption)
                        .foregroundColor(.white)
                    ColorPicker("", selection: $innerEarColor)
                        .labelsHidden()
                        .scaleEffect(1.3)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - SizeShapeSectionView
struct SizeShapeSectionView: View {
    @Binding var earHeight: Double
    @Binding var earWidth: Double
    @Binding var earThickness: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Size & Shape")
                .font(.headline)
                .foregroundColor(.white)
            
            // Height Slider
            VStack(alignment: .leading, spacing: 4) {
                Text("Height: \(String(format: "%.3f", earHeight))")
                    .font(.caption)
                    .foregroundColor(.white)
                Slider(value: $earHeight, in: 0.03...0.12, step: 0.005)
                    .accentColor(.blue)
            }
            
            // Width Slider
            VStack(alignment: .leading, spacing: 4) {
                Text("Width: \(String(format: "%.3f", earWidth))")
                    .font(.caption)
                    .foregroundColor(.white)
                Slider(value: $earWidth, in: 0.01...0.05, step: 0.002)
                    .accentColor(.blue)
            }
            
            // Thickness Slider
            VStack(alignment: .leading, spacing: 4) {
                Text("Thickness: \(String(format: "%.3f", earThickness))")
                    .font(.caption)
                    .foregroundColor(.white)
                Slider(value: $earThickness, in: 0.002...0.015, step: 0.001)
                    .accentColor(.blue)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - RotationSectionView
struct RotationSectionView: View {
    @Binding var rotationX: Double
    @Binding var rotationY: Double
    @Binding var rotationZ: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rotation & Angle")
                .font(.headline)
                .foregroundColor(.white)
            
            // X Rotation (Pitch - forward/backward)
            VStack(alignment: .leading, spacing: 4) {
                Text("Tilt Forward/Back: \(String(format: "%.0f°", rotationX))")
                    .font(.caption)
                    .foregroundColor(.white)
                Slider(value: $rotationX, in: -45...45, step: 5)
                    .accentColor(.green)
            }
            
            // Y Rotation (Yaw - left/right)
            VStack(alignment: .leading, spacing: 4) {
                Text("Rotate In/Out: \(String(format: "%.0f°", rotationY))")
                    .font(.caption)
                    .foregroundColor(.white)
                Slider(value: $rotationY, in: -45...45, step: 5)
                    .accentColor(.green)
            }
            
            // Z Rotation (Roll - outward tilt)
            VStack(alignment: .leading, spacing: 4) {
                Text("Outward Tilt: \(String(format: "%.0f°", rotationZ))")
                    .font(.caption)
                    .foregroundColor(.white)
                Slider(value: $rotationZ, in: 0...60, step: 5)
                    .accentColor(.green)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - WhiskerSectionView
struct WhiskerSectionView: View {
    @Binding var whiskerColor: Color
    @Binding var whiskerLength: Double
    @Binding var whiskerThickness: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Whiskers")
                .font(.headline)
                .foregroundColor(.white)
            
            // Color Picker
            VStack(alignment: .leading, spacing: 4) {
                Text("Color")
                    .font(.caption)
                    .foregroundColor(.white)
                ColorPicker("", selection: $whiskerColor)
                    .labelsHidden()
                    .scaleEffect(1.3)
            }
            
            // Length Slider
            VStack(alignment: .leading, spacing: 4) {
                Text("Length: \(String(format: "%.3f", whiskerLength))")
                    .font(.caption)
                    .foregroundColor(.white)
                Slider(value: $whiskerLength, in: 0.01...0.06, step: 0.005)
                    .accentColor(.orange)
            }
            
            // Thickness Slider
            VStack(alignment: .leading, spacing: 4) {
                Text("Thickness: \(String(format: "%.4f", whiskerThickness))")
                    .font(.caption)
                    .foregroundColor(.white)
                Slider(value: $whiskerThickness, in: 0.0005...0.002, step: 0.0001)
                    .accentColor(.orange)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

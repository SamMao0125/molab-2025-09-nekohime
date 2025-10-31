import SwiftUI

// MARK: - CustomizationPanelView
struct CustomizationPanelView: View {
    @Binding var showCustomization: Bool
    @Binding var outerEarColor: Color
    @Binding var innerEarColor: Color
    @Binding var earHeight: Double
    @Binding var earWidth: Double
    @Binding var earThickness: Double
    @Binding var rotationX: Double
    @Binding var rotationY: Double
    @Binding var rotationZ: Double
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Toggle button
            Button(action: {
                withAnimation {
                    showCustomization.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text(showCustomization ? "Hide Controls" : "Customize Ears")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(25)
            }
            
            if showCustomization {
                ScrollView {
                    VStack(spacing: 20) {
                        ColorSectionView(
                            outerEarColor: $outerEarColor,
                            innerEarColor: $innerEarColor
                        )
                        
                        SizeShapeSectionView(
                            earHeight: $earHeight,
                            earWidth: $earWidth,
                            earThickness: $earThickness
                        )
                        
                        RotationSectionView(
                            rotationX: $rotationX,
                            rotationY: $rotationY,
                            rotationZ: $rotationZ
                        )
                        
                        // Reset Button
                        Button(action: onReset) {
                            Text("Reset to Defaults")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.6))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 400)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.7))
        )
        .padding(.horizontal)
        .padding(.bottom, 40)
    }
}

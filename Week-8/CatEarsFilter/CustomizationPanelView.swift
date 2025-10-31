import SwiftUI

// MARK: - CustomizationPanelView
struct CustomizationPanelView: View {
    let viewModel: CatEarsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Toggle button
            Button(action: {
                withAnimation {
                    viewModel.showCustomization.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text(viewModel.showCustomization ? "Hide Controls" : "Customize Ears")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(25)
            }
            
            if viewModel.showCustomization {
                ScrollView {
                    VStack(spacing: 20) {
                        ColorSectionView(
                            outerEarColor: Binding(
                                get: { viewModel.outerEarColor },
                                set: { viewModel.outerEarColor = $0 }
                            ),
                            innerEarColor: Binding(
                                get: { viewModel.innerEarColor },
                                set: { viewModel.innerEarColor = $0 }
                            )
                        )
                        
                        SizeShapeSectionView(
                            earHeight: Binding(
                                get: { viewModel.earHeight },
                                set: { viewModel.earHeight = $0 }
                            ),
                            earWidth: Binding(
                                get: { viewModel.earWidth },
                                set: { viewModel.earWidth = $0 }
                            ),
                            earThickness: Binding(
                                get: { viewModel.earThickness },
                                set: { viewModel.earThickness = $0 }
                            )
                        )
                        
                        RotationSectionView(
                            rotationX: Binding(
                                get: { viewModel.rotationX },
                                set: { viewModel.rotationX = $0 }
                            ),
                            rotationY: Binding(
                                get: { viewModel.rotationY },
                                set: { viewModel.rotationY = $0 }
                            ),
                            rotationZ: Binding(
                                get: { viewModel.rotationZ },
                                set: { viewModel.rotationZ = $0 }
                            )
                        )
                        
                        WhiskerSectionView(
                            whiskerColor: Binding(
                                get: { viewModel.whiskerColor },
                                set: { viewModel.whiskerColor = $0 }
                            ),
                            whiskerLength: Binding(
                                get: { viewModel.whiskerLength },
                                set: { viewModel.whiskerLength = $0 }
                            ),
                            whiskerThickness: Binding(
                                get: { viewModel.whiskerThickness },
                                set: { viewModel.whiskerThickness = $0 }
                            )
                        )
                        
                        // Reset Button
                        Button(action: viewModel.resetToDefaults) {
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

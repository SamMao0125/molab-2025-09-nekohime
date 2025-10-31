import SwiftUI

struct ContentView: View {
    @State private var outerEarColor: Color = .systemPink
    @State private var innerEarColor: Color = .pink
    @State private var earHeight: Double = 0.06
    @State private var earWidth: Double = 0.025
    @State private var earThickness: Double = 0.005
    @State private var rotationX: Double = 0.0  // Pitch (forward/backward tilt)
    @State private var rotationY: Double = 0.0  // Yaw (left/right rotation)
    @State private var rotationZ: Double = 30.0 // Roll (outward tilt) - default 30 degrees
    @State private var showingAlert = false
    @State private var showCustomization = false
    @State private var isRecording = false
    @State private var alertMessage = ""
    @State private var showSuccessAlert = false
    
    var body: some View {
        ZStack {
            // AR View for face tracking
            ARFaceTrackingView(
                outerEarColor: $outerEarColor,
                innerEarColor: $innerEarColor,
                earHeight: $earHeight,
                earWidth: $earWidth,
                earThickness: $earThickness,
                rotationX: $rotationX,
                rotationY: $rotationY,
                rotationZ: $rotationZ
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Camera controls at the top
                HStack {
                    Spacer()
                    
                    // Photo button
                    Button(action: {
                        capturePhoto()
                    }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.blue.opacity(0.8)))
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 20)
                    
                    // Video button
                    Button(action: {
                        toggleRecording()
                    }) {
                        Image(systemName: isRecording ? "stop.circle.fill" : "video.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(isRecording ? Color.red.opacity(0.8) : Color.blue.opacity(0.8)))
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Customization panel
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
                                // Color Section
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
                                
                                // Size Section
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
                                
                                // Rotation Section
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
                                
                                // Reset Button
                                Button(action: resetToDefaults) {
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
        .alert("Device Not Supported", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Face tracking requires a device with TrueDepth camera (iPhone X or later)")
        }
        .alert(alertMessage, isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            setupAlertNotifications()
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    private func setupAlertNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ShowAlert"),
            object: nil,
            queue: .main
        ) { notification in
            if let message = notification.userInfo?["message"] as? String {
                alertMessage = message
                showSuccessAlert = true
            }
        }
    }
    
    
    private func capturePhoto() {
        // This will be handled by the coordinator through a notification
        NotificationCenter.default.post(name: NSNotification.Name("CapturePhoto"), object: nil)
    }
    
    private func toggleRecording() {
        if isRecording {
            // Stop recording
            NotificationCenter.default.post(name: NSNotification.Name("StopRecording"), object: nil)
            isRecording = false
        } else {
            // Start recording
            NotificationCenter.default.post(name: NSNotification.Name("StartRecording"), object: nil)
            isRecording = true
        }
    }
    
    private func resetToDefaults() {
        withAnimation {
            outerEarColor = .systemPink
            innerEarColor = .pink
            earHeight = 0.06
            earWidth = 0.025
            earThickness = 0.005
            rotationX = 0.0
            rotationY = 0.0
            rotationZ = 30.0
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

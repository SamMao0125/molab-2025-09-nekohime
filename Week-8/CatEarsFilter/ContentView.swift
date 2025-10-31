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
                CameraControlsView(
                    isRecording: $isRecording,
                    onPhotoCapture: capturePhoto,
                    onToggleRecording: toggleRecording
                )
                
                Spacer()
                
                CustomizationPanelView(
                    showCustomization: $showCustomization,
                    outerEarColor: $outerEarColor,
                    innerEarColor: $innerEarColor,
                    earHeight: $earHeight,
                    earWidth: $earWidth,
                    earThickness: $earThickness,
                    rotationX: $rotationX,
                    rotationY: $rotationY,
                    rotationZ: $rotationZ,
                    onReset: resetToDefaults
                )
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

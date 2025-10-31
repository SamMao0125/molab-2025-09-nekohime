import SwiftUI

// MARK: - View Model
@Observable
class CatEarsViewModel {
    var outerEarColor: Color = .systemPink
    var innerEarColor: Color = .pink
    var earHeight: Double = 0.06
    var earWidth: Double = 0.025
    var earThickness: Double = 0.005
    var rotationX: Double = 0.0  // Pitch (forward/backward tilt)
    var rotationY: Double = 0.0  // Yaw (left/right rotation)
    var rotationZ: Double = 30.0 // Roll (outward tilt) - default 30 degrees
    var whiskerColor: Color = .gray
    var whiskerLength: Double = 0.04
    var whiskerThickness: Double = 0.0015
    var showingAlert = false
    var showCustomization = false
    var isRecording = false
    var alertMessage = ""
    var showSuccessAlert = false
    
    func capturePhoto() {
        // This will be handled by the coordinator through a notification
        NotificationCenter.default.post(name: NSNotification.Name("CapturePhoto"), object: nil)
    }
    
    func toggleRecording() {
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
    
    func resetToDefaults() {
        withAnimation {
            outerEarColor = .systemPink
            innerEarColor = .pink
            earHeight = 0.06
            earWidth = 0.025
            earThickness = 0.005
            rotationX = 0.0
            rotationY = 0.0
            rotationZ = 30.0
            whiskerColor = .gray
            whiskerLength = 0.04
            whiskerThickness = 0.0015
        }
    }
    
    func setupAlertNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ShowAlert"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            if let message = notification.userInfo?["message"] as? String {
                self.alertMessage = message
                self.showSuccessAlert = true
            }
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @State private var viewModel = CatEarsViewModel()
    
    var body: some View {
        ZStack {
            // AR View for face tracking
            ARFaceTrackingView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                CameraControlsView(
                    isRecording: $viewModel.isRecording,
                    onPhotoCapture: viewModel.capturePhoto,
                    onToggleRecording: viewModel.toggleRecording
                )
                
                Spacer()
                
                CustomizationPanelView(viewModel: viewModel)
            }
        }
        .alert("Device Not Supported", isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Face tracking requires a device with TrueDepth camera (iPhone X or later)")
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.showSuccessAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            viewModel.setupAlertNotifications()
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

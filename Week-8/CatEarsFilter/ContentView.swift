import SwiftUI

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

import SwiftUI
import AVFoundation

struct SimpleCameraTest: View {
    var body: some View {
        ZStack {
            CameraPreview()
            
            VStack {
                Text("Simple Camera Test")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                
                Text("If you see yourself, camera works!")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("❌ No camera found")
            return view
        }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("❌ Cannot create input")
            return view
        }
        
        captureSession.addInput(input)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        
        print("🟢 Camera preview started")
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

import SwiftUI
import AVFoundation
import ARKit

struct CameraView: View {
    @State private var permissionManager = PermissionManager()
    @State private var faceTracker = SimpleFaceTracker()
    @State private var currentConfig = EarConfiguration()
    
    @State private var showCustomization = false
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if permissionManager.cameraAuthorized {
                    // Simple camera preview
                    SimpleCameraPreview()
                        .ignoresSafeArea()
                    
                    // AR tracking overlay (invisible, just for tracking)
                    ARTrackingOverlay(faceTracker: faceTracker)
                        .ignoresSafeArea()
                    
                    // Left ear - follows face
                    Circle()
                        .fill(currentConfig.outerColor.color)
                        .frame(width: 60 * CGFloat(currentConfig.size), height: 60 * CGFloat(currentConfig.size))
                        .position(calculateEarPosition(
                            faceCenter: faceTracker.facePosition,
                            screenSize: geometry.size,
                            isLeft: true
                        ))
                    
                    // Right ear - follows face
                    Circle()
                        .fill(currentConfig.outerColor.color)
                        .frame(width: 60 * CGFloat(currentConfig.size), height: 60 * CGFloat(currentConfig.size))
                        .position(calculateEarPosition(
                            faceCenter: faceTracker.facePosition,
                            screenSize: geometry.size,
                            isLeft: false
                        ))
                    
                    // UI Controls
                    VStack {
                        HStack {
                            Text(faceTracker.isFaceDetected ? "Face tracking active! 🎯" : "Move into view...")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(12)
                            
                            Spacer()
                        }
                        .padding()
                        
                        Spacer()
                        
                        HStack(spacing: 40) {
                            Button(action: {
                                showCustomization.toggle()
                            }) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                captureAndSavePhoto(geometry: geometry)
                            }) {
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 60, height: 60)
                                    )
                            }
                            
                            Button(action: {
                                // Reset or quality toggle
                            }) {
                                Image(systemName: "wand.and.stars")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.bottom, 30)
                    }
                } else {
                    ProgressView()
                        .tint(.white)
                }
                
                if showCustomization {
                    CustomizationSheet(
                        config: $currentConfig,
                        isPresented: $showCustomization,
                        onSavePreset: {}
                    )
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .toast(message: toastMessage, isShowing: $showToast)
        .onAppear {
            permissionManager.checkCameraPermission()
        }
    }
    
    private func calculateEarPosition(faceCenter: CGPoint, screenSize: CGSize, isLeft: Bool) -> CGPoint {
        let earOffset: CGFloat = 80 // Distance from face center to ear
        let earHeight: CGFloat = -100 // Above face center
        
        if isLeft {
            return CGPoint(
                x: faceCenter.x - earOffset,
                y: faceCenter.y + earHeight
            )
        } else {
            return CGPoint(
                x: faceCenter.x + earOffset,
                y: faceCenter.y + earHeight
            )
        }
    }
    
    private func captureAndSavePhoto(geometry: GeometryProxy) {
        // Render the current view as an image
        let renderer = ImageRenderer(content:
            ZStack {
                SimpleCameraPreview()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                Circle()
                    .fill(currentConfig.outerColor.color)
                    .frame(width: 60 * CGFloat(currentConfig.size), height: 60 * CGFloat(currentConfig.size))
                    .position(calculateEarPosition(
                        faceCenter: faceTracker.facePosition,
                        screenSize: geometry.size,
                        isLeft: true
                    ))
                
                Circle()
                    .fill(currentConfig.outerColor.color)
                    .frame(width: 60 * CGFloat(currentConfig.size), height: 60 * CGFloat(currentConfig.size))
                    .position(calculateEarPosition(
                        faceCenter: faceTracker.facePosition,
                        screenSize: geometry.size,
                        isLeft: false
                    ))
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        )
        
        renderer.scale = 3.0 // High resolution
        
        if let image = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            toastMessage = "Saved to Photos! 📸"
            showToast = true
        }
    }
}

// Simple camera preview that works
struct SimpleCameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let captureSession = AVCaptureSession()
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return view
        }
        
        guard let input = try? AVCaptureDeviceInput(device: camera) else {
            return view
        }
        
        captureSession.addInput(input)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// AR face tracker - invisible overlay
struct ARTrackingOverlay: UIViewRepresentable {
    let faceTracker: SimpleFaceTracker
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        arView.isHidden = false
        arView.scene = SCNScene()
        
        // Make it transparent
        arView.backgroundColor = .clear
        arView.scene.background.contents = UIColor.clear
        
        let configuration = ARFaceTrackingConfiguration()
        arView.session.run(configuration)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(faceTracker: faceTracker)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        let faceTracker: SimpleFaceTracker
        
        init(faceTracker: SimpleFaceTracker) {
            self.faceTracker = faceTracker
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            
            // Convert 3D face position to 2D screen position
            let scnView = renderer as! ARSCNView
            let facePosition = faceAnchor.transform.columns.3
            let projectedPoint = scnView.projectPoint(SCNVector3(facePosition.x, facePosition.y, facePosition.z))
            
            DispatchQueue.main.async {
                self.faceTracker.facePosition = CGPoint(
                    x: CGFloat(projectedPoint.x),
                    y: CGFloat(projectedPoint.y)
                )
                self.faceTracker.isFaceDetected = true
            }
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
            if anchor is ARFaceAnchor {
                DispatchQueue.main.async {
                    self.faceTracker.isFaceDetected = false
                }
            }
        }
    }
}

// Face tracking state
@Observable
class SimpleFaceTracker {
    var facePosition: CGPoint = CGPoint(x: 200, y: 400)
    var isFaceDetected: Bool = false
}

#Preview {
    CameraView()
}

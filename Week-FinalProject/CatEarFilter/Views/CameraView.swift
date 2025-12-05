import SwiftUI
import AVFoundation
import ARKit
import SceneKit

struct CameraView: View {
    @State private var permissionManager = PermissionManager()
    @State private var faceTracker = ARFaceTrackerWith3DEars()
    @State private var currentConfig = EarConfiguration()
    
    @State private var showCustomization = false
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if permissionManager.cameraAuthorized {
                    // AR view with 3D ears
                    AR3DEarsView(faceTracker: faceTracker, earConfig: $currentConfig)
                        .ignoresSafeArea()
                    
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
                                captureScreenshot(geometry: geometry)
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
                                currentConfig = EarConfiguration()
                            }) {
                                Image(systemName: "arrow.counterclockwise")
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
    
    private func captureScreenshot(geometry: GeometryProxy) {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        guard let window = window else { return }
        
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let image = renderer.image { context in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        toastMessage = "Saved to Photos! 📸"
        showToast = true
    }
}

// AR view with 3D ears
struct AR3DEarsView: UIViewRepresentable {
    let faceTracker: ARFaceTrackerWith3DEars
    @Binding var earConfig: EarConfiguration
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        arView.scene = SCNScene()
        arView.automaticallyUpdatesLighting = true
        
        let configuration = ARFaceTrackingConfiguration()
        arView.session.run(configuration)
        
        faceTracker.arView = arView
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        faceTracker.updateEarConfiguration(earConfig)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(faceTracker: faceTracker)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        let faceTracker: ARFaceTrackerWith3DEars
        
        init(faceTracker: ARFaceTrackerWith3DEars) {
            self.faceTracker = faceTracker
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard anchor is ARFaceAnchor else { return }
            
            DispatchQueue.main.async {
                self.faceTracker.setupEars(on: node)
                self.faceTracker.isFaceDetected = true
            }
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard anchor is ARFaceAnchor else { return }
            
            DispatchQueue.main.async {
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

// Face tracker that creates 3D ears
@Observable
class ARFaceTrackerWith3DEars {
    var arView: ARSCNView?
    var isFaceDetected: Bool = false
    
    private var leftEarNode: SCNNode?
    private var rightEarNode: SCNNode?
    private var currentConfig: EarConfiguration?
    
    func setupEars(on faceNode: SCNNode) {
        leftEarNode?.removeFromParentNode()
        rightEarNode?.removeFromParentNode()
        
        let config = currentConfig ?? EarConfiguration()
        let leftEar = create3DEar(config: config)
        let rightEar = create3DEar(config: config)
        
        // Use distance property for ear spacing
        leftEar.position = SCNVector3(-config.distance, 0.15, 0.0)
        rightEar.position = SCNVector3(config.distance, 0.15, 0.0)
        
        faceNode.addChildNode(leftEar)
        faceNode.addChildNode(rightEar)
        
        leftEarNode = leftEar
        rightEarNode = rightEar
    }
    
    private func create3DEar(config: EarConfiguration) -> SCNNode {
        let earNode = SCNNode()
        
        // Create outer ear
        let outerEar = createOuterEarGeometry()
        let outerMaterial = SCNMaterial()
        outerMaterial.diffuse.contents = UIColor(config.outerColor.color)
        outerMaterial.lightingModel = .physicallyBased
        outerMaterial.metalness.contents = 0.1
        outerMaterial.roughness.contents = 0.6
        outerEar.materials = [outerMaterial]
        
        let outerNode = SCNNode(geometry: outerEar)
        earNode.addChildNode(outerNode)
        
        // Create inner ear
        let innerEar = createInnerEarGeometry()
        let innerMaterial = SCNMaterial()
        innerMaterial.diffuse.contents = UIColor(config.innerColor.color)
        innerMaterial.lightingModel = .physicallyBased
        innerMaterial.metalness.contents = 0.0
        innerMaterial.roughness.contents = 0.8
        innerEar.materials = [innerMaterial]
        
        let innerNode = SCNNode(geometry: innerEar)
        innerNode.position = SCNVector3(0, -0.005, 0.002)
        earNode.addChildNode(innerNode)
        
        // Use individual width/height if unlocked
        if config.lockScale {
            earNode.scale = SCNVector3(config.size, config.size, config.size)
        } else {
            earNode.scale = SCNVector3(config.scaleWidth, config.scaleHeight, config.size)
        }
        earNode.eulerAngles.z = config.leftRotation
        
        return earNode
    }
    
    private func createOuterEarGeometry() -> SCNGeometry {
        // Front profile
        let frontPoints: [CGPoint] = [
            CGPoint(x: -0.020, y: 0.000),
            CGPoint(x: -0.022, y: 0.015),
            CGPoint(x: -0.018, y: 0.035),
            CGPoint(x: -0.010, y: 0.048),
            CGPoint(x: 0.000, y: 0.055),
            CGPoint(x: 0.010, y: 0.048),
            CGPoint(x: 0.018, y: 0.035),
            CGPoint(x: 0.025, y: 0.015),
            CGPoint(x: 0.020, y: 0.000)
        ]
        
        // Middle profile - bulgier
        let midPoints: [CGPoint] = [
            CGPoint(x: -0.024, y: 0.002),
            CGPoint(x: -0.028, y: 0.018),
            CGPoint(x: -0.022, y: 0.038),
            CGPoint(x: -0.012, y: 0.050),
            CGPoint(x: 0.000, y: 0.057),
            CGPoint(x: 0.012, y: 0.050),
            CGPoint(x: 0.022, y: 0.038),
            CGPoint(x: 0.028, y: 0.018),
            CGPoint(x: 0.024, y: 0.002)
        ]
        
        // Back profile - tapered
        let backPoints: [CGPoint] = [
            CGPoint(x: -0.016, y: 0.004),
            CGPoint(x: -0.018, y: 0.016),
            CGPoint(x: -0.014, y: 0.032),
            CGPoint(x: -0.008, y: 0.042),
            CGPoint(x: 0.000, y: 0.048),
            CGPoint(x: 0.008, y: 0.042),
            CGPoint(x: 0.014, y: 0.032),
            CGPoint(x: 0.018, y: 0.016),
            CGPoint(x: 0.016, y: 0.004)
        ]
        
        var vertices: [SCNVector3] = []
        
        for point in frontPoints {
            vertices.append(SCNVector3(point.x, point.y, 0.0))
        }
        for point in midPoints {
            vertices.append(SCNVector3(point.x, point.y, 0.005))
        }
        for point in backPoints {
            vertices.append(SCNVector3(point.x, point.y, 0.010))
        }
        
        var indices: [Int32] = []
        let pointsPerSection = frontPoints.count
        
        // Connect front to middle
        for i in 0..<(pointsPerSection - 1) {
            let i0 = Int32(i)
            let i1 = Int32(i + 1)
            let i2 = Int32(i + pointsPerSection)
            let i3 = Int32(i + pointsPerSection + 1)
            
            indices.append(contentsOf: [i0, i2, i1])
            indices.append(contentsOf: [i1, i2, i3])
        }
        
        // Connect middle to back
        for i in 0..<(pointsPerSection - 1) {
            let i0 = Int32(i + pointsPerSection)
            let i1 = Int32(i + pointsPerSection + 1)
            let i2 = Int32(i + pointsPerSection * 2)
            let i3 = Int32(i + pointsPerSection * 2 + 1)
            
            indices.append(contentsOf: [i0, i2, i1])
            indices.append(contentsOf: [i1, i2, i3])
        }
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        
        return geometry
    }
    
    private func createInnerEarGeometry() -> SCNGeometry {
        // Front profile
        let frontPoints: [CGPoint] = [
            CGPoint(x: -0.010, y: 0.010),
            CGPoint(x: -0.012, y: 0.020),
            CGPoint(x: -0.009, y: 0.032),
            CGPoint(x: -0.004, y: 0.040),
            CGPoint(x: 0.000, y: 0.044),
            CGPoint(x: 0.004, y: 0.040),
            CGPoint(x: 0.009, y: 0.032),
            CGPoint(x: 0.012, y: 0.020),
            CGPoint(x: 0.010, y: 0.010)
        ]
        
        // Middle profile
        let midPoints: [CGPoint] = [
            CGPoint(x: -0.012, y: 0.012),
            CGPoint(x: -0.014, y: 0.022),
            CGPoint(x: -0.011, y: 0.034),
            CGPoint(x: -0.005, y: 0.042),
            CGPoint(x: 0.000, y: 0.046),
            CGPoint(x: 0.005, y: 0.042),
            CGPoint(x: 0.011, y: 0.034),
            CGPoint(x: 0.014, y: 0.022),
            CGPoint(x: 0.012, y: 0.012)
        ]
        
        // Back profile
        let backPoints: [CGPoint] = [
            CGPoint(x: -0.008, y: 0.014),
            CGPoint(x: -0.009, y: 0.022),
            CGPoint(x: -0.007, y: 0.032),
            CGPoint(x: -0.003, y: 0.038),
            CGPoint(x: 0.000, y: 0.040),
            CGPoint(x: 0.003, y: 0.038),
            CGPoint(x: 0.007, y: 0.032),
            CGPoint(x: 0.009, y: 0.022),
            CGPoint(x: 0.008, y: 0.014)
        ]
        
        var vertices: [SCNVector3] = []
        
        for point in frontPoints {
            vertices.append(SCNVector3(point.x, point.y, 0.0))
        }
        for point in midPoints {
            vertices.append(SCNVector3(point.x, point.y, 0.003))
        }
        for point in backPoints {
            vertices.append(SCNVector3(point.x, point.y, 0.006))
        }
        
        var indices: [Int32] = []
        let pointsPerSection = frontPoints.count
        
        for i in 0..<(pointsPerSection - 1) {
            let i0 = Int32(i)
            let i1 = Int32(i + 1)
            let i2 = Int32(i + pointsPerSection)
            let i3 = Int32(i + pointsPerSection + 1)
            
            indices.append(contentsOf: [i0, i2, i1])
            indices.append(contentsOf: [i1, i2, i3])
        }
        
        for i in 0..<(pointsPerSection - 1) {
            let i0 = Int32(i + pointsPerSection)
            let i1 = Int32(i + pointsPerSection + 1)
            let i2 = Int32(i + pointsPerSection * 2)
            let i3 = Int32(i + pointsPerSection * 2 + 1)
            
            indices.append(contentsOf: [i0, i2, i1])
            indices.append(contentsOf: [i1, i2, i3])
        }
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        
        return geometry
    }
    
    func updateEarConfiguration(_ config: EarConfiguration) {
        self.currentConfig = config
        
        if let leftEar = leftEarNode, let rightEar = rightEarNode {
            updateEarNode(leftEar, config: config, isLeft: true)
            updateEarNode(rightEar, config: config, isLeft: false)
        }
    }
    
    private func updateEarNode(_ node: SCNNode, config: EarConfiguration, isLeft: Bool) {
        // Use individual width/height if unlocked, otherwise use uniform size
        if config.lockScale {
            node.scale = SCNVector3(config.size, config.size, config.size)
        } else {
            node.scale = SCNVector3(config.scaleWidth, config.scaleHeight, config.size)
        }
        let rotation = config.syncRotation ? config.leftRotation : (isLeft ? config.leftRotation : config.rightRotation)
        node.eulerAngles.z = rotation
        
        // Use distance for ear spacing
        let baseX: Float = isLeft ? -config.distance : config.distance
        node.position = SCNVector3(
            baseX + config.xPosition,
            0.15 + config.yPosition,
            config.zPosition
        )
        
        // Update colors
        if let outerNode = node.childNodes.first, let geometry = outerNode.geometry {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(config.outerColor.color)
            material.lightingModel = .physicallyBased
            material.metalness.contents = 0.1
            material.roughness.contents = 0.6
            geometry.materials = [material]
        }
        
        if node.childNodes.count > 1, let innerNode = node.childNodes[1] as SCNNode?, let geometry = innerNode.geometry {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(config.innerColor.color)
            material.lightingModel = .physicallyBased
            material.metalness.contents = 0.0
            material.roughness.contents = 0.8
            geometry.materials = [material]
        }
    }
}

#Preview {
    CameraView()
}

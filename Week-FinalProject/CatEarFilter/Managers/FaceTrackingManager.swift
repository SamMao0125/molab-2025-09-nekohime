import ARKit
import RealityKit
import SwiftUI

@Observable
class FaceTrackingManager: NSObject, ARSessionDelegate {
    var arView: ARView?
    var faceAnchor: ARFaceAnchor?
    var leftEarEntity: ModelEntity?
    var rightEarEntity: ModelEntity?
    var currentConfig: EarConfiguration?
    var onPhotoCapture: ((UIImage) -> Void)?
    
    private var anchorEntity: AnchorEntity?
    
    func setupARView(_ arView: ARView, earConfig: EarConfiguration) {
        self.arView = arView
        self.currentConfig = earConfig
        
        // Make ARView show camera feed
        arView.environment.background = .cameraFeed()
        arView.renderOptions = [.disableDepthOfField, .disableMotionBlur]
        
        print("🟢 Setting up ARView")
        
        // Configure AR session for face tracking
        guard ARFaceTrackingConfiguration.isSupported else {
            print("❌ Face tracking not supported")
            return
        }
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = false
        configuration.maximumNumberOfTrackedFaces = 1
        
        arView.session.delegate = self
        arView.session.run(configuration)
        
        print("🟢 AR session started")
        
        // Setup initial ears
        setupEars()
    }
    
    private func setupEars() {
        guard let arView = arView,
              let config = currentConfig else {
            print("❌ No arView or config")
            return
        }
        
        print("🟢 Setting up ears")
        
        // Create anchor entity for face
        let anchor = AnchorEntity()
        anchorEntity = anchor
        
        // Create ears - back to the spheres that we KNOW work
        leftEarEntity = createWorkingSphere(config: config, isLeft: true)
        rightEarEntity = createWorkingSphere(config: config, isLeft: false)
        
        if let leftEar = leftEarEntity {
            anchor.addChild(leftEar)
            print("🟢 Added left ear")
        }
        if let rightEar = rightEarEntity {
            anchor.addChild(rightEar)
            print("🟢 Added right ear")
        }
        
        arView.scene.addAnchor(anchor)
        print("🟢 Added anchor to scene")
    }
    
    private func createWorkingSphere(config: EarConfiguration, isLeft: Bool) -> ModelEntity {
        // Use the EXACT same code that worked before with red/blue spheres
        let mesh = MeshResource.generateSphere(radius: 0.02)
        var material = UnlitMaterial(color: UIColor(config.outerColor.color))
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        // Position
        let xOffset: Float = isLeft ? -0.08 : 0.08
        entity.position = SIMD3(x: xOffset, y: 0.15, z: 0.0)
        
        print("🟢 Created sphere at position \(entity.position)")
        
        return entity
    }
    
    func updateEarConfiguration(_ config: EarConfiguration) {
        self.currentConfig = config
        
        // Update existing ears
        if let leftEar = leftEarEntity {
            updateEarEntity(leftEar, config: config, isLeft: true)
        }
        if let rightEar = rightEarEntity {
            updateEarEntity(rightEar, config: config, isLeft: false)
        }
    }
    
    private func updateEarEntity(_ entity: ModelEntity, config: EarConfiguration, isLeft: Bool) {
        // Update position
        let baseXOffset: Float = isLeft ? -0.08 : 0.08
        let xPos = baseXOffset + config.xPosition
        let yPos: Float = 0.15 + config.yPosition
        let zPos: Float = 0.0 + config.zPosition
        
        entity.position = SIMD3(x: xPos, y: yPos, z: zPos)
        
        // Update rotation
        let rotation = config.syncRotation ? config.leftRotation : (isLeft ? config.leftRotation : config.rightRotation)
        entity.orientation = simd_quatf(angle: rotation, axis: SIMD3(x: 0, y: 0, z: 1))
        
        // Update scale
        entity.scale = SIMD3(repeating: config.size)
        
        // Update color
        var material = UnlitMaterial(color: UIColor(config.outerColor.color))
        entity.model?.materials = [material]
    }
    
    // ARSessionDelegate
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        self.faceAnchor = faceAnchor
        
        // Update anchor position to follow face
        if let anchorEntity = anchorEntity {
            anchorEntity.transform.matrix = faceAnchor.transform
        }
    }
    
    func capturePhoto() {
        guard let arView = arView else { return }
        
        arView.snapshot(saveToHDR: false) { [weak self] image in
            if let image = image {
                self?.onPhotoCapture?(image)
            }
        }
    }
}

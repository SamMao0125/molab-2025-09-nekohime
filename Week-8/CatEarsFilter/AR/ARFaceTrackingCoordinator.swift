import ARKit
import SceneKit

// MARK: - ARFaceTrackingCoordinator
class ARFaceTrackingCoordinator: NSObject, ARSCNViewDelegate {
    var leftEarNode: SCNNode?
    var rightEarNode: SCNNode?
    var whiskerNodes: [SCNNode] = []
    var currentOuterColor: UIColor = .systemPink
    var currentInnerColor: UIColor = UIColor.systemPink.withAlphaComponent(0.6)
    var currentHeight: CGFloat = 0.06
    var currentWidth: CGFloat = 0.025
    var currentThickness: CGFloat = 0.005
    var currentRotationX: CGFloat = 0.0
    var currentRotationY: CGFloat = 0.0
    var currentRotationZ: CGFloat = 30.0
    var currentWhiskerColor: UIColor = .gray
    var currentWhiskerLength: CGFloat = 0.04
    var currentWhiskerThickness: CGFloat = 0.0015
    
    // Track original whisker rotations and indices for animation
    private var whiskerBaseRotations: [SCNNode: SCNVector3] = [:]
    private var whiskerIndices: [SCNNode: Int] = [:]
    private var animationStartTime: TimeInterval = 0
    
    weak var sceneView: ARSCNView? {
        didSet {
            // Set sceneView reference in capture manager when it's set
            captureManager.sceneView = sceneView
        }
    }
    private let captureManager = ARCaptureManager()
    
    // Called when a face anchor is added
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        // Create and add cat ears
        addCatEars(to: node, faceAnchor: faceAnchor)
        
        // Create and add whiskers
        addWhiskers(to: node, faceAnchor: faceAnchor)
    }
    
    // Called when face anchor updates
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        // Update ear positions if needed
        updateEarPositions(node: node, faceAnchor: faceAnchor)
    }
    
    // Called every frame - use this to animate whiskers
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Initialize start time if needed
        if animationStartTime == 0 {
            animationStartTime = time
        }
        
        // Update whisker animations
        updateWhiskerAnimations(currentTime: time - animationStartTime)
    }
    
    private func addCatEars(to node: SCNNode, faceAnchor: ARFaceAnchor) {
        // Create left ear
        leftEarNode = createCatEar()
        if let leftEar = leftEarNode {
            // Position on left side of head
            leftEar.position = SCNVector3(-0.08, 0.12, 0.02)
            // Apply rotations: X same, Y mirrored, Z mirrored for symmetry
            leftEar.eulerAngles = SCNVector3(
                degreesToRadians(currentRotationX),           // X: pitch (same for both)
                degreesToRadians(currentRotationY),           // Y: yaw (mirrored)
                degreesToRadians(currentRotationZ)            // Z: roll (mirrored)
            )
            node.addChildNode(leftEar)
        }
        
        // Create right ear
        rightEarNode = createCatEar()
        if let rightEar = rightEarNode {
            // Position on right side of head
            rightEar.position = SCNVector3(0.08, 0.12, 0.02)
            // Apply rotations: X same, Y mirrored, Z mirrored for symmetry
            rightEar.eulerAngles = SCNVector3(
                degreesToRadians(currentRotationX),           // X: pitch (same for both)
                -degreesToRadians(currentRotationY),          // Y: yaw (mirrored)
                -degreesToRadians(currentRotationZ)           // Z: roll (mirrored)
            )
            node.addChildNode(rightEar)
        }
    }
    
    // Helper function to convert degrees to radians
    private func degreesToRadians(_ degrees: CGFloat) -> Float {
        return Float(degrees * .pi / 180.0)
    }
    
    private func createCatEar() -> SCNNode {
        // Create a cone for the ear shape using current parameters
        let earGeometry = SCNCone(
            topRadius: currentThickness,
            bottomRadius: currentWidth,
            height: currentHeight
        )
        
        // Apply material with current outer color
        let material = SCNMaterial()
        material.diffuse.contents = currentOuterColor
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.3
        earGeometry.materials = [material]
        
        let earNode = SCNNode(geometry: earGeometry)
        
        // Add inner ear (pink/lighter part) - scaled proportionally
        let innerEar = SCNCone(
            topRadius: currentThickness * 0.6,
            bottomRadius: currentWidth * 0.6,
            height: currentHeight * 0.67
        )
        let innerMaterial = SCNMaterial()
        innerMaterial.diffuse.contents = currentInnerColor
        innerMaterial.lightingModel = .physicallyBased
        innerEar.materials = [innerMaterial]
        
        let innerEarNode = SCNNode(geometry: innerEar)
        innerEarNode.position = SCNVector3(0, 0, Float(currentWidth * 0.4))
        earNode.addChildNode(innerEarNode)
        
        return earNode
    }
    
    private func addWhiskers(to node: SCNNode, faceAnchor: ARFaceAnchor) {
        // Clear existing whiskers
        whiskerNodes.forEach { $0.removeFromParentNode() }
        whiskerNodes.removeAll()
        
        createWhiskersOnNode(node)
    }
    
    private func createWhiskersOnNode(_ node: SCNNode) {
        // Create 3 whiskers on each side (6 total)
        var globalIndex = 0
        
        // Left side whiskers - positioned on left cheek area
        for i in 0..<3 {
            let whisker = createWhisker()
            // Position on left cheek, vertically spaced around mouth/nose area
            let verticalOffset = CGFloat(i - 1) * 0.012 // -0.012, 0, 0.012
            // X: left side (-), Y: mouth/nose level (0.0-0.05), Z: slightly forward on cheek
            whisker.position = SCNVector3(-0.055, 0.0 + Float(verticalOffset), 0.03)
            // Rotate to point outward horizontally (cylinder extends along Y by default, rotate around Z to point in -X)
            whisker.eulerAngles = SCNVector3(0, 0, degreesToRadians(-90))
            node.addChildNode(whisker)
            whiskerNodes.append(whisker)
            // Add jiggle animation with slight variation per whisker
            animateWhiskerJiggle(whisker, index: globalIndex, isLeft: true)
            globalIndex += 1
        }
        
        // Right side whiskers - positioned on right cheek area
        for i in 0..<3 {
            let whisker = createWhisker()
            // Position on right cheek, vertically spaced around mouth/nose area
            let verticalOffset = CGFloat(i - 1) * 0.012 // -0.012, 0, 0.012
            // X: right side (+), Y: mouth/nose level (0.0-0.05), Z: slightly forward on cheek
            whisker.position = SCNVector3(0.055, 0.0 + Float(verticalOffset), 0.03)
            // Rotate to point outward horizontally (cylinder extends along Y by default, rotate around Z to point in +X)
            whisker.eulerAngles = SCNVector3(0, 0, degreesToRadians(90))
            node.addChildNode(whisker)
            whiskerNodes.append(whisker)
            // Add jiggle animation with slight variation per whisker
            animateWhiskerJiggle(whisker, index: globalIndex, isLeft: false)
            globalIndex += 1
        }
    }
    
    private func animateWhiskerJiggle(_ whisker: SCNNode, index: Int, isLeft: Bool) {
        // Store the base rotation and index so we can add jiggle to it
        whiskerBaseRotations[whisker] = whisker.eulerAngles
        whiskerIndices[whisker] = index
    }
    
    private func updateWhiskerAnimations(currentTime: TimeInterval) {
        for whisker in whiskerNodes {
            guard let baseRotation = whiskerBaseRotations[whisker],
                  let index = whiskerIndices[whisker] else { continue }
            
            // Base amplitude (in degrees) - subtle rotation for gentle jiggle
            let baseAmplitude: Float = 3.0
            
            // Vary amplitude slightly per whisker for more natural movement
            let amplitudeVariation: Float = Float(index) * 0.4
            let amplitudeDegrees = baseAmplitude + amplitudeVariation
            let amplitudeRadians = Float(degreesToRadians(CGFloat(amplitudeDegrees)))
            
            // Vary timing slightly per whisker (1.0-1.4 seconds) for organic feel
            let baseDuration: Double = 1.0 + Double(index) * 0.15
            let phaseOffset: Double = Double(index) * 0.2 // Stagger the animation start
            
            // Calculate normalized time for sine wave
            let normalizedTime = (currentTime / baseDuration) + phaseOffset
            let sineValue = sin(normalizedTime * Double.pi * 2.0)
            let cosineValue = cos(normalizedTime * Double.pi * 2.0)
            
            // Calculate rotation offsets
            let yRotation = amplitudeRadians * 0.7 * Float(sineValue) // Vertical wobble (Y axis)
            let zRotation = amplitudeRadians * 0.5 * Float(cosineValue) // Horizontal wobble (Z axis, offset by 90°)
            
            // Apply jiggle while preserving base rotation
            whisker.eulerAngles = SCNVector3(
                baseRotation.x,
                baseRotation.y + yRotation,
                baseRotation.z + zRotation
            )
        }
    }
    
    private func createWhisker() -> SCNNode {
        // Create a cylinder for the whisker
        let whiskerGeometry = SCNCylinder(
            radius: currentWhiskerThickness,
            height: currentWhiskerLength
        )
        
        // Apply material
        let material = SCNMaterial()
        material.diffuse.contents = currentWhiskerColor
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.8 // Whiskers are slightly glossy
        material.metalness.contents = 0.1
        whiskerGeometry.materials = [material]
        
        let whiskerNode = SCNNode(geometry: whiskerGeometry)
        return whiskerNode
    }
    
    private func updateEarPositions(node: SCNNode, faceAnchor: ARFaceAnchor) {
        // Ears remain relative to the face anchor, so they automatically follow the face
        // This method can be used for more advanced animations based on blend shapes
    }
    
    func updateEarParameters(outerColor: UIColor, innerColor: UIColor, height: CGFloat, width: CGFloat, thickness: CGFloat, rotX: CGFloat, rotY: CGFloat, rotZ: CGFloat, whiskerColor: UIColor, whiskerLength: CGFloat, whiskerThickness: CGFloat) {
        // Check if parameters have changed
        let parametersChanged =
            height != currentHeight ||
            width != currentWidth ||
            thickness != currentThickness ||
            rotX != currentRotationX ||
            rotY != currentRotationY ||
            rotZ != currentRotationZ
        
        let colorsChanged =
            outerColor != currentOuterColor ||
            innerColor != currentInnerColor
        
        // Check if whisker parameters have changed
        let whiskerParamsChanged =
            whiskerLength != currentWhiskerLength ||
            whiskerThickness != currentWhiskerThickness
        
        let whiskerColorChanged =
            whiskerColor != currentWhiskerColor
        
        // Update stored values
        currentOuterColor = outerColor
        currentInnerColor = innerColor
        currentHeight = height
        currentWidth = width
        currentThickness = thickness
        currentRotationX = rotX
        currentRotationY = rotY
        currentRotationZ = rotZ
        currentWhiskerColor = whiskerColor
        currentWhiskerLength = whiskerLength
        currentWhiskerThickness = whiskerThickness
        
        // If dimensions or rotations changed, recreate the ears
        if parametersChanged {
            recreateEars()
        } else if colorsChanged {
            // Just update colors without recreating geometry
            updateEarColors()
        }
        
        // If whisker dimensions changed, recreate whiskers
        if whiskerParamsChanged {
            recreateWhiskers()
        } else if whiskerColorChanged {
            // Just update whisker colors
            updateWhiskerColors()
        }
    }
    
    private func recreateEars() {
        guard let parent = leftEarNode?.parent else { return }
        
        // Remove old ears
        leftEarNode?.removeFromParentNode()
        rightEarNode?.removeFromParentNode()
        
        // Create new left ear
        leftEarNode = createCatEar()
        if let leftEar = leftEarNode {
            leftEar.position = SCNVector3(-0.08, 0.12, 0.02)
            leftEar.eulerAngles = SCNVector3(
                degreesToRadians(currentRotationX),
                degreesToRadians(currentRotationY),
                degreesToRadians(currentRotationZ)
            )
            parent.addChildNode(leftEar)
        }
        
        // Create new right ear
        rightEarNode = createCatEar()
        if let rightEar = rightEarNode {
            rightEar.position = SCNVector3(0.08, 0.12, 0.02)
            rightEar.eulerAngles = SCNVector3(
                degreesToRadians(currentRotationX),
                -degreesToRadians(currentRotationY),
                -degreesToRadians(currentRotationZ)
            )
            parent.addChildNode(rightEar)
        }
    }
    
    private func updateEarColors() {
        // Update outer ear colors
        if let leftEar = leftEarNode?.geometry as? SCNCone {
            leftEar.materials.first?.diffuse.contents = currentOuterColor
        }
        
        if let rightEar = rightEarNode?.geometry as? SCNCone {
            rightEar.materials.first?.diffuse.contents = currentOuterColor
        }
        
        // Update inner ear colors
        if let leftInner = leftEarNode?.childNodes.first?.geometry as? SCNCone {
            leftInner.materials.first?.diffuse.contents = currentInnerColor
        }
        
        if let rightInner = rightEarNode?.childNodes.first?.geometry as? SCNCone {
            rightInner.materials.first?.diffuse.contents = currentInnerColor
        }
    }
    
    private func recreateWhiskers() {
        // Use the same parent as the ears (they should be on the same face node)
        guard let parent = leftEarNode?.parent else { return }
        
        // Remove old whiskers
        whiskerNodes.forEach { 
            whiskerBaseRotations.removeValue(forKey: $0)
            whiskerIndices.removeValue(forKey: $0)
            $0.removeFromParentNode() 
        }
        whiskerNodes.removeAll()
        
        // Create new whiskers
        createWhiskersOnNode(parent)
    }
    
    private func updateWhiskerColors() {
        // Update all whisker colors
        whiskerNodes.forEach { whiskerNode in
            if let geometry = whiskerNode.geometry as? SCNCylinder {
                geometry.materials.first?.diffuse.contents = currentWhiskerColor
            }
        }
    }
}

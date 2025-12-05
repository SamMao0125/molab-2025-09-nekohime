import SwiftUI
import SceneKit

struct SceneKitEarView: UIViewRepresentable {
    let config: EarConfiguration
    let position: CGPoint
    let isLeft: Bool
    let imageSize: CGSize
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.scene = SCNScene()
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = false
        
        // Create camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 0.3)
        scnView.scene?.rootNode.addChildNode(cameraNode)
        
        // Create ear
        let earNode = create3DEar(config: config)
        scnView.scene?.rootNode.addChildNode(earNode)
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Remove old ear
        uiView.scene?.rootNode.childNodes.forEach { node in
            if node.camera == nil {
                node.removeFromParentNode()
            }
        }
        
        // Add updated ear
        let earNode = create3DEar(config: config)
        uiView.scene?.rootNode.addChildNode(earNode)
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
        
        // Apply config - scale
        if config.lockScale {
            earNode.scale = SCNVector3(config.size, config.size, config.size)
        } else {
            earNode.scale = SCNVector3(config.scaleWidth, config.scaleHeight, config.size)
        }
        
        // Apply rotation
        let rotation = config.syncRotation ? config.leftRotation : (isLeft ? config.leftRotation : config.rightRotation)
        earNode.eulerAngles.z = rotation
        
        return earNode
    }
    
    private func createOuterEarGeometry() -> SCNGeometry {
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
        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
    
    private func createInnerEarGeometry() -> SCNGeometry {
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
        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
}

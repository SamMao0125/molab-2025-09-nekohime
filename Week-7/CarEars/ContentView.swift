import SwiftUI
import RealityKit
import ARKit
import Photos

@main
struct CatEarsApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        ARSessionView()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARSessionView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARViewController {
        return ARViewController()
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {}
}

enum AppMode {
    case scanning
    case distorted
    case saved
}

class ARViewController: UIViewController, ARSessionDelegate {
    var arView: ARView!
    var meshAnchors: [UUID: ARMeshAnchor] = [:]
    var meshEntities: [UUID: ModelEntity] = [:]
    
    var mode: AppMode = .scanning
    var capturedMeshData: (vertices: [SIMD3<Float>], faces: [UInt32])?
    
    var sceneView: ARSCNView?
    var objectNode: SCNNode?
    var currentRotation: SCNVector4 = SCNVector4(0, 1, 0, 0)
    
    var statusLabel: UILabel!
    var applyButton: UIButton!
    var saveButton: UIButton!
    var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView = ARView(frame: view.bounds)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.environment.background = .cameraFeed()
        view.addSubview(arView)
        
        let config = ARWorldTrackingConfiguration()
        config.sceneReconstruction = .meshWithClassification
        config.planeDetection = [.horizontal, .vertical]
        arView.session.delegate = self
        arView.session.run(config)
        
        setupUI()
    }
    
    func setupUI() {
        statusLabel = UILabel()
        statusLabel.textColor = .white
        statusLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        statusLabel.textAlignment = .center
        statusLabel.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        statusLabel.layer.cornerRadius = 14
        statusLabel.clipsToBounds = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        applyButton = UIButton(type: .system)
        applyButton.setTitle("APPLY CAT EARS", for: .normal)
        applyButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        applyButton.backgroundColor = .systemIndigo
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.layer.cornerRadius = 28
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        applyButton.alpha = 0
        view.addSubview(applyButton)
        
        saveButton = UIButton(type: .system)
        saveButton.setTitle("SAVE IMAGE", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        saveButton.backgroundColor = .systemGreen
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 28
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.alpha = 0
        view.addSubview(saveButton)
        
        backButton = UIButton(type: .system)
        backButton.setTitle("RESTART SCAN", for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        backButton.backgroundColor = .systemOrange
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.cornerRadius = 24
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.alpha = 0
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.widthAnchor.constraint(equalToConstant: 280),
            statusLabel.heightAnchor.constraint(equalToConstant: 56),
            
            applyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            applyButton.widthAnchor.constraint(equalToConstant: 260),
            applyButton.heightAnchor.constraint(equalToConstant: 56),
            
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            saveButton.widthAnchor.constraint(equalToConstant: 260),
            saveButton.heightAnchor.constraint(equalToConstant: 56),
            
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),
            backButton.widthAnchor.constraint(equalToConstant: 220),
            backButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        updateUI()
    }
    
    func updateUI() {
        let totalVerts = meshAnchors.values.reduce(0) { $0 + $1.geometry.vertices.count }
        let progress = min(100, Int((Float(totalVerts) / 2000.0) * 100))
        
        switch mode {
        case .scanning:
            statusLabel.text = "Scanning: \(progress)%"
            statusLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.85)
            
            let isReady = totalVerts > 2000
            UIView.animate(withDuration: 0.3) {
                self.applyButton.alpha = isReady ? 1.0 : 0.5
                self.saveButton.alpha = 0
                self.backButton.alpha = 0
            }
            applyButton.isEnabled = isReady
            
        case .distorted:
            statusLabel.text = "Cat Ears Applied"
            statusLabel.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.85)
            
            UIView.animate(withDuration: 0.3) {
                self.applyButton.alpha = 0
                self.saveButton.alpha = 1.0
                self.backButton.alpha = 0
            }
            
        case .saved:
            statusLabel.text = "Image Saved"
            statusLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.85)
            
            UIView.animate(withDuration: 0.3) {
                self.applyButton.alpha = 0
                self.saveButton.alpha = 0
                self.backButton.alpha = 1.0
            }
        }
    }
    
    @objc func applyButtonTapped() {
        captureAllMeshes()
        switchToDistortedView()
    }
    
    @objc func saveButtonTapped() {
        savePhoto()
        mode = .saved
        updateUI()
    }
    
    @objc func backButtonTapped() {
        resetToScanning()
    }
    
    func captureAllMeshes() {
        var allVertices: [SIMD3<Float>] = []
        var allFaces: [UInt32] = []
        
        for anchor in meshAnchors.values {
            let verts = extractVertices(from: anchor.geometry.vertices)
            let faces = extractFaces(from: anchor.geometry.faces)
            
            let offset = UInt32(allVertices.count)
            allVertices.append(contentsOf: verts.map {
                anchor.transform.transformPoint($0)
            })
            allFaces.append(contentsOf: faces.map { $0 + offset })
        }
        
        capturedMeshData = (allVertices, allFaces)
    }
    
    func switchToDistortedView() {
        guard let meshData = capturedMeshData else { return }
        
        arView.session.pause()
        arView.removeFromSuperview()
        
        sceneView = ARSCNView(frame: view.bounds)
        sceneView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView!.scene = SCNScene()
        sceneView!.scene.background.contents = UIColor.white
        sceneView!.allowsCameraControl = false
        sceneView!.autoenablesDefaultLighting = true
        sceneView!.backgroundColor = .white
        view.insertSubview(sceneView!, at: 0)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sceneView!.addGestureRecognizer(pan)
        
        var distortedVerts = meshData.vertices
        if let earPoints = findEarPoints(in: meshData.vertices) {
            distortVertices(&distortedVerts, earPoints: earPoints)
            let earIndices = getEarVertices(vertices: meshData.vertices, earPoints: earPoints)
            createDistortedNode(vertices: distortedVerts, faces: meshData.faces, earIndices: earIndices)
        } else {
            createDistortedNode(vertices: distortedVerts, faces: meshData.faces, earIndices: [])
        }
        
        mode = .distorted
        updateUI()
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let node = objectNode else { return }
        
        let translation = gesture.translation(in: sceneView)
        
        let rotationSpeed: Float = 0.005
        let xAngle = Float(translation.y) * rotationSpeed
        let yAngle = Float(translation.x) * rotationSpeed
        
        let xRotation = SCNMatrix4MakeRotation(xAngle, 1, 0, 0)
        let yRotation = SCNMatrix4MakeRotation(yAngle, 0, 1, 0)
        let combinedRotation = SCNMatrix4Mult(xRotation, yRotation)
        
        node.transform = SCNMatrix4Mult(combinedRotation, node.transform)
        
        gesture.setTranslation(.zero, in: sceneView)
    }
    
    func createDistortedNode(vertices: [SIMD3<Float>], faces: [UInt32], earIndices: Set<Int>) {
        let normals = calculateNormals(vertices: vertices, faces: faces)
        
        let vertexSource = SCNGeometrySource(vertices: vertices.map { SCNVector3($0.x, $0.y, $0.z) })
        let normalSource = SCNGeometrySource(normals: normals.map { SCNVector3($0.x, $0.y, $0.z) })
        
        var colors: [SCNVector3] = []
        for i in 0..<vertices.count {
            if earIndices.contains(i) {
                colors.append(SCNVector3(0.35, 0.35, 0.35))
            } else {
                colors.append(SCNVector3(0.92, 0.92, 0.92))
            }
        }
        
        let colorSource = SCNGeometrySource(data: Data(bytes: colors, count: colors.count * MemoryLayout<SCNVector3>.stride),
                                           semantic: .color,
                                           vectorCount: colors.count,
                                           usesFloatComponents: true,
                                           componentsPerVector: 3,
                                           bytesPerComponent: MemoryLayout<Float>.stride,
                                           dataOffset: 0,
                                           dataStride: MemoryLayout<SCNVector3>.stride)
        
        let indices = Data(bytes: faces, count: faces.count * MemoryLayout<UInt32>.stride)
        let element = SCNGeometryElement(data: indices, primitiveType: .triangles,
                                        primitiveCount: faces.count / 3,
                                        bytesPerIndex: MemoryLayout<UInt32>.stride)
        
        let geometry = SCNGeometry(sources: [vertexSource, normalSource, colorSource], elements: [element])
        
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.55
        material.metalness.contents = 0.15
        geometry.materials = [material]
        
        let node = SCNNode(geometry: geometry)
        
        let (minBound, maxBound) = node.boundingBox
        let center = SCNVector3(
            (minBound.x + maxBound.x) / 2,
            (minBound.y + maxBound.y) / 2,
            (minBound.z + maxBound.z) / 2
        )
        
        node.pivot = SCNMatrix4MakeTranslation(center.x, center.y, center.z)
        node.position = SCNVector3(0, 0, 0)
        
        let size = sqrt(
            pow(maxBound.x - minBound.x, 2) +
            pow(maxBound.y - minBound.y, 2) +
            pow(maxBound.z - minBound.z, 2)
        )
        
        if let scene = sceneView?.scene {
            scene.rootNode.addChildNode(node)
            
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            let cameraDistance = max(size * 1.5, 0.5)
            cameraNode.position = SCNVector3(0, 0, cameraDistance)
            cameraNode.look(at: SCNVector3(0, 0, 0))
            scene.rootNode.addChildNode(cameraNode)
            sceneView?.pointOfView = cameraNode
        }
        
        objectNode = node
    }
    
    func resetToScanning() {
        sceneView?.removeFromSuperview()
        sceneView = nil
        objectNode = nil
        
        view.insertSubview(arView, at: 0)
        
        meshAnchors.removeAll()
        for (_, entity) in meshEntities {
            entity.removeFromParent()
        }
        meshEntities.removeAll()
        capturedMeshData = nil
        
        let config = ARWorldTrackingConfiguration()
        config.sceneReconstruction = .meshWithClassification
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        mode = .scanning
        updateUI()
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let meshAnchor = anchor as? ARMeshAnchor {
                meshAnchors[meshAnchor.identifier] = meshAnchor
                updateMeshVisualization(for: meshAnchor)
                DispatchQueue.main.async {
                    self.updateUI()
                }
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let meshAnchor = anchor as? ARMeshAnchor {
                meshAnchors[meshAnchor.identifier] = meshAnchor
                updateMeshVisualization(for: meshAnchor)
                DispatchQueue.main.async {
                    self.updateUI()
                }
            }
        }
    }
    
    func updateMeshVisualization(for anchor: ARMeshAnchor) {
        guard mode == .scanning else { return }
        
        let geo = anchor.geometry
        let verts = extractVertices(from: geo.vertices)
        let faces = extractFaces(from: geo.faces)
        let normals = extractNormals(from: geo.normals)
        
        // Create the actual mesh surface
        var desc = MeshDescriptor()
        desc.positions = MeshBuffer(verts)
        desc.normals = MeshBuffer(normals)
        desc.primitives = .triangles(faces)
        
        guard let mesh = try? MeshResource.generate(from: [desc]) else { return }
        
        // Semi-transparent white material
        var mat = SimpleMaterial()
        mat.color = .init(tint: UIColor.white.withAlphaComponent(0.85), texture: nil)
        mat.roughness = .float(0.9)
        mat.metallic = .float(0.0)
        
        if let existing = meshEntities[anchor.identifier] {
            existing.model?.mesh = mesh
            existing.model?.materials = [mat]
            existing.transform = Transform(matrix: anchor.transform)
        } else {
            let entity = ModelEntity(mesh: mesh, materials: [mat])
            entity.transform = Transform(matrix: anchor.transform)
            
            let anchorEntity = AnchorEntity(world: anchor.transform)
            anchorEntity.addChild(entity)
            arView.scene.addAnchor(anchorEntity)
            
            meshEntities[anchor.identifier] = entity
        }
    }
    
    func extractNormals(from source: ARGeometrySource) -> [SIMD3<Float>] {
        var result: [SIMD3<Float>] = []
        let buffer = source.buffer.contents()
        
        for i in 0..<source.count {
            let offset = i * source.stride
            let x = buffer.load(fromByteOffset: offset, as: Float.self)
            let y = buffer.load(fromByteOffset: offset + 4, as: Float.self)
            let z = buffer.load(fromByteOffset: offset + 8, as: Float.self)
            result.append(SIMD3<Float>(x, y, z))
        }
        
        return result
    }
    
    func getEarVertices(vertices: [SIMD3<Float>], earPoints: (SIMD3<Float>, SIMD3<Float>)) -> Set<Int> {
        var indices = Set<Int>()
        let (ear1, ear2) = earPoints
        let radius: Float = 0.28
        
        for i in 0..<vertices.count {
            let v = vertices[i]
            if distance(v, ear1) < radius || distance(v, ear2) < radius {
                indices.insert(i)
            }
        }
        
        return indices
    }
    
    func calculateNormals(vertices: [SIMD3<Float>], faces: [UInt32]) -> [SIMD3<Float>] {
        var normals = [SIMD3<Float>](repeating: SIMD3<Float>(0, 1, 0), count: vertices.count)
        
        for i in stride(from: 0, to: faces.count, by: 3) {
            guard i + 2 < faces.count else { break }
            let i0 = Int(faces[i])
            let i1 = Int(faces[i + 1])
            let i2 = Int(faces[i + 2])
            
            guard i0 < vertices.count, i1 < vertices.count, i2 < vertices.count else { continue }
            
            let v0 = vertices[i0]
            let v1 = vertices[i1]
            let v2 = vertices[i2]
            
            let edge1 = v1 - v0
            let edge2 = v2 - v0
            let normal = cross(edge1, edge2)
            
            normals[i0] += normal
            normals[i1] += normal
            normals[i2] += normal
        }
        
        return normals.map { length($0) > 0 ? normalize($0) : SIMD3<Float>(0, 1, 0) }
    }
    
    func extractVertices(from source: ARGeometrySource) -> [SIMD3<Float>] {
        var result: [SIMD3<Float>] = []
        let buffer = source.buffer.contents()
        
        for i in 0..<source.count {
            let offset = i * source.stride
            let x = buffer.load(fromByteOffset: offset, as: Float.self)
            let y = buffer.load(fromByteOffset: offset + 4, as: Float.self)
            let z = buffer.load(fromByteOffset: offset + 8, as: Float.self)
            result.append(SIMD3<Float>(x, y, z))
        }
        
        return result
    }
    
    func extractFaces(from element: ARGeometryElement) -> [UInt32] {
        var result: [UInt32] = []
        let buffer = element.buffer.contents()
        
        for i in 0..<(element.count * element.indexCountPerPrimitive) {
            let idx = buffer.load(fromByteOffset: i * MemoryLayout<UInt32>.stride, as: UInt32.self)
            result.append(idx)
        }
        
        return result
    }
    
    func findEarPoints(in verts: [SIMD3<Float>]) -> (SIMD3<Float>, SIMD3<Float>)? {
        guard verts.count > 50 else { return nil }
        
        let topVerts = verts.sorted { $0.y > $1.y }.prefix(max(100, verts.count / 3))
        let topArray = Array(topVerts)
        
        var center = SIMD3<Float>(0, 0, 0)
        for v in topArray {
            center += v
        }
        center /= Float(topArray.count)
        
        let avgDist = topArray.reduce(0.0) { $0 + distance($1, center) } / Float(topArray.count)
        let targetDist = avgDist * 0.7
        
        var best: (SIMD3<Float>, SIMD3<Float>)?
        var maxSeparation: Float = 0
        
        for i in stride(from: 0, to: min(topArray.count, 100), by: 3) {
            for j in stride(from: i + 3, to: min(topArray.count, 100), by: 3) {
                let p1 = topArray[i]
                let p2 = topArray[j]
                
                let d1 = distance(p1, center)
                let d2 = distance(p2, center)
                
                if abs(d1 - targetDist) < targetDist * 0.5 && abs(d2 - targetDist) < targetDist * 0.5 {
                    let separation = distance(p1, p2)
                    if separation > maxSeparation && separation > avgDist * 0.4 {
                        maxSeparation = separation
                        best = (p1, p2)
                    }
                }
            }
        }
        
        return best
    }
    
    func distortVertices(_ verts: inout [SIMD3<Float>], earPoints: (SIMD3<Float>, SIMD3<Float>)) {
        let (ear1, ear2) = earPoints
        let radius: Float = 0.28
        let height: Float = 0.65
        
        for i in 0..<verts.count {
            let v = verts[i]
            
            let d1 = distance(v, ear1)
            if d1 < radius {
                let influence = pow(1.0 - (d1 / radius), 2.2)
                let dir = normalize(v - ear1)
                verts[i] += dir * height * influence
            }
            
            let d2 = distance(v, ear2)
            if d2 < radius {
                let influence = pow(1.0 - (d2 / radius), 2.2)
                let dir = normalize(v - ear2)
                verts[i] += dir * height * influence
            }
        }
    }
    
    func savePhoto() {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = image else { return }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: nil)
    }
}

extension simd_float4x4 {
    func transformPoint(_ point: SIMD3<Float>) -> SIMD3<Float> {
        let transformed = self * SIMD4<Float>(point.x, point.y, point.z, 1.0)
        return SIMD3<Float>(transformed.x, transformed.y, transformed.z)
    }
}

#Preview {
    ContentView()
}

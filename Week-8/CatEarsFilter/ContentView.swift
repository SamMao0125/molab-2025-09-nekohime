import SwiftUI
import ARKit
import SceneKit
import Photos
import AVFoundation

// MARK: - EarPreset Model
struct EarPreset: Codable, Identifiable {
    var id = UUID()
    var name: String
    var outerEarColorComponents: [Double]
    var innerEarColorComponents: [Double]
    var earHeight: Double
    var earWidth: Double
    var earThickness: Double
    var rotationX: Double
    var rotationY: Double
    var rotationZ: Double
    
    init(name: String, outerColor: Color, innerColor: Color, height: Double, width: Double, thickness: Double, rotX: Double, rotY: Double, rotZ: Double) {
        self.name = name
        self.outerEarColorComponents = outerColor.components
        self.innerEarColorComponents = innerColor.components
        self.earHeight = height
        self.earWidth = width
        self.earThickness = thickness
        self.rotationX = rotX
        self.rotationY = rotY
        self.rotationZ = rotZ
    }
    
    var outerColor: Color {
        Color(red: outerEarColorComponents[0], green: outerEarColorComponents[1], blue: outerEarColorComponents[2], opacity: outerEarColorComponents[3])
    }
    
    var innerColor: Color {
        Color(red: innerEarColorComponents[0], green: innerEarColorComponents[1], blue: innerEarColorComponents[2], opacity: innerEarColorComponents[3])
    }
}

// MARK: - Preset Manager
class PresetManager: ObservableObject {
    @Published var presets: [EarPreset] = []
    
    private let presetsKey = "savedEarPresets"
    
    init() {
        loadPresets()
    }
    
    func savePreset(_ preset: EarPreset) {
        presets.append(preset)
        saveToUserDefaults()
    }
    
    func deletePreset(at index: Int) {
        presets.remove(at: index)
        saveToUserDefaults()
    }
    
    func deletePreset(id: UUID) {
        presets.removeAll { $0.id == id }
        saveToUserDefaults()
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(encoded, forKey: presetsKey)
        }
    }
    
    private func loadPresets() {
        if let data = UserDefaults.standard.data(forKey: presetsKey),
           let decoded = try? JSONDecoder().decode([EarPreset].self, from: data) {
            presets = decoded
        }
    }
}

struct ContentView: View {
    @State private var outerEarColor: Color = .systemPink
    @State private var innerEarColor: Color = .pink
    @State private var earHeight: Double = 0.06
    @State private var earWidth: Double = 0.025
    @State private var earThickness: Double = 0.005
    @State private var rotationX: Double = 0.0
    @State private var rotationY: Double = 0.0
    @State private var rotationZ: Double = 30.0
    @State private var showingAlert = false
    @State private var showCustomization = false
    @State private var isRecording = false
    @State private var alertMessage = ""
    @State private var showSuccessAlert = false
    @State private var showFlash = false
    @State private var showPresetManager = false
    @State private var showSavePresetDialog = false
    @State private var newPresetName = ""
    
    @StateObject private var presetManager = PresetManager()
    
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
            
            // Flash overlay
            if showFlash {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }
            
            VStack {
                // Camera controls at the top
                HStack {
                    // Presets button
                    Button(action: {
                        showPresetManager = true
                    }) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.purple.opacity(0.8)))
                            .shadow(radius: 5)
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    // Photo button
                    Button(action: {
                        capturePhotoWithFlash()
                    }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.blue.opacity(0.8)))
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 20)
                    
                    // Video button
                    Button(action: {
                        toggleRecording()
                    }) {
                        Image(systemName: isRecording ? "stop.circle.fill" : "video.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(isRecording ? Color.red.opacity(0.8) : Color.blue.opacity(0.8)))
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Customization panel
                VStack(spacing: 16) {
                    // Toggle button
                    Button(action: {
                        withAnimation {
                            showCustomization.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                            Text(showCustomization ? "Hide Controls" : "Customize Ears")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(25)
                    }
                    
                    if showCustomization {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Save Preset Button
                                Button(action: {
                                    showSavePresetDialog = true
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.down")
                                        Text("Save Current as Preset")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.green.opacity(0.7))
                                    .cornerRadius(10)
                                }
                                
                                // Color Section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Colors")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    HStack {
                                        VStack {
                                            Text("Outer Color")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                            ColorPicker("", selection: $outerEarColor)
                                                .labelsHidden()
                                                .scaleEffect(1.3)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack {
                                            Text("Inner Color")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                            ColorPicker("", selection: $innerEarColor)
                                                .labelsHidden()
                                                .scaleEffect(1.3)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                
                                // Size Section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Size & Shape")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Height: \(String(format: "%.3f", earHeight))")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        Slider(value: $earHeight, in: 0.03...0.12, step: 0.005)
                                            .accentColor(.blue)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Width: \(String(format: "%.3f", earWidth))")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        Slider(value: $earWidth, in: 0.01...0.05, step: 0.002)
                                            .accentColor(.blue)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Thickness: \(String(format: "%.3f", earThickness))")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        Slider(value: $earThickness, in: 0.002...0.015, step: 0.001)
                                            .accentColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                
                                // Rotation Section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Rotation & Angle")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Tilt Forward/Back: \(String(format: "%.0f°", rotationX))")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        Slider(value: $rotationX, in: -45...45, step: 5)
                                            .accentColor(.green)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Rotate In/Out: \(String(format: "%.0f°", rotationY))")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        Slider(value: $rotationY, in: -45...45, step: 5)
                                            .accentColor(.green)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Outward Tilt: \(String(format: "%.0f°", rotationZ))")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        Slider(value: $rotationZ, in: 0...60, step: 5)
                                            .accentColor(.green)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                
                                // Reset Button
                                Button(action: resetToDefaults) {
                                    Text("Reset to Defaults")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.red.opacity(0.6))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 400)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.7))
                )
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showPresetManager) {
            PresetManagerView(
                presetManager: presetManager,
                onLoadPreset: loadPreset,
                onClose: { showPresetManager = false }
            )
        }
        .alert("Save Preset", isPresented: $showSavePresetDialog) {
            TextField("Preset Name", text: $newPresetName)
            Button("Cancel", role: .cancel) {
                newPresetName = ""
            }
            Button("Save") {
                saveCurrentPreset()
            }
        } message: {
            Text("Enter a name for this ear configuration")
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
    
    private func capturePhotoWithFlash() {
        // Show flash
        withAnimation(.easeInOut(duration: 0.1)) {
            showFlash = true
        }
        
        // Hide flash and capture photo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showFlash = false
            }
            capturePhoto()
        }
    }
    
    private func capturePhoto() {
        NotificationCenter.default.post(name: NSNotification.Name("CapturePhoto"), object: nil)
    }
    
    private func toggleRecording() {
        if isRecording {
            NotificationCenter.default.post(name: NSNotification.Name("StopRecording"), object: nil)
            isRecording = false
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("StartRecording"), object: nil)
            isRecording = true
        }
    }
    
    private func saveCurrentPreset() {
        guard !newPresetName.isEmpty else { return }
        
        let preset = EarPreset(
            name: newPresetName,
            outerColor: outerEarColor,
            innerColor: innerEarColor,
            height: earHeight,
            width: earWidth,
            thickness: earThickness,
            rotX: rotationX,
            rotY: rotationY,
            rotZ: rotationZ
        )
        
        presetManager.savePreset(preset)
        newPresetName = ""
        
        alertMessage = "Preset saved successfully!"
        showSuccessAlert = true
    }
    
    private func loadPreset(_ preset: EarPreset) {
        withAnimation {
            outerEarColor = preset.outerColor
            innerEarColor = preset.innerColor
            earHeight = preset.earHeight
            earWidth = preset.earWidth
            earThickness = preset.earThickness
            rotationX = preset.rotationX
            rotationY = preset.rotationY
            rotationZ = preset.rotationZ
        }
        
        showPresetManager = false
        alertMessage = "Preset '\(preset.name)' loaded!"
        showSuccessAlert = true
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

// MARK: - Preset Manager View
struct PresetManagerView: View {
    @ObservedObject var presetManager: PresetManager
    var onLoadPreset: (EarPreset) -> Void
    var onClose: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.9)
                    .edgesIgnoringSafeArea(.all)
                
                if presetManager.presets.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "star.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No saved presets")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Customize your ears and save them as presets!")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    List {
                        ForEach(presetManager.presets) { preset in
                            PresetRow(preset: preset, onLoad: {
                                onLoadPreset(preset)
                            })
                            .listRowBackground(Color.white.opacity(0.1))
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                presetManager.deletePreset(at: index)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Saved Presets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onClose()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Preset Row
struct PresetRow: View {
    let preset: EarPreset
    let onLoad: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(preset.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(preset.outerColor)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        Text("Outer")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(preset.innerColor)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        Text("Inner")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onLoad) {
                Text("Load")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - ARFaceTrackingView
struct ARFaceTrackingView: UIViewRepresentable {
    @Binding var outerEarColor: Color
    @Binding var innerEarColor: Color
    @Binding var earHeight: Double
    @Binding var earWidth: Double
    @Binding var earThickness: Double
    @Binding var rotationX: Double
    @Binding var rotationY: Double
    @Binding var rotationZ: Double
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        
        guard ARFaceTrackingConfiguration.isSupported else {
            return sceneView
        }
        
        sceneView.delegate = context.coordinator
        sceneView.automaticallyUpdatesLighting = true
        
        context.coordinator.sceneView = sceneView
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        context.coordinator.updateEarParameters(
            outerColor: uiColor(from: outerEarColor),
            innerColor: uiColor(from: innerEarColor),
            height: CGFloat(earHeight),
            width: CGFloat(earWidth),
            thickness: CGFloat(earThickness),
            rotX: CGFloat(rotationX),
            rotY: CGFloat(rotationY),
            rotZ: CGFloat(rotationZ)
        )
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func uiColor(from color: Color) -> UIColor {
        let components = UIColor(color).cgColor.components ?? [1, 0, 0, 1]
        return UIColor(
            red: components[0],
            green: components[1],
            blue: components[2],
            alpha: components[3]
        )
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, ARSCNViewDelegate {
        var leftEarNode: SCNNode?
        var rightEarNode: SCNNode?
        var currentOuterColor: UIColor = .systemPink
        var currentInnerColor: UIColor = UIColor.systemPink.withAlphaComponent(0.6)
        var currentHeight: CGFloat = 0.06
        var currentWidth: CGFloat = 0.025
        var currentThickness: CGFloat = 0.005
        var currentRotationX: CGFloat = 0.0
        var currentRotationY: CGFloat = 0.0
        var currentRotationZ: CGFloat = 30.0
        
        weak var sceneView: ARSCNView?
        private var videoWriter: AVAssetWriter?
        private var videoWriterInput: AVAssetWriterInput?
        private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
        private var isRecordingVideo = false
        private var videoStartTime: Date?
        private var lastFrameTime: Date?
        private var displayLink: CADisplayLink?
        private var videoURL: URL?
        private let targetFrameRate: Double = 30.0
        
        override init() {
            super.init()
            setupNotifications()
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
            displayLink?.invalidate()
        }
        
        private func setupNotifications() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleCapturePhoto),
                name: NSNotification.Name("CapturePhoto"),
                object: nil
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleStartRecording),
                name: NSNotification.Name("StartRecording"),
                object: nil
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleStopRecording),
                name: NSNotification.Name("StopRecording"),
                object: nil
            )
        }
        
        @objc private func handleCapturePhoto() {
            capturePhoto()
        }
        
        @objc private func handleStartRecording() {
            startRecording()
        }
        
        @objc private func handleStopRecording() {
            stopRecording()
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            addCatEars(to: node, faceAnchor: faceAnchor)
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            updateEarPositions(node: node, faceAnchor: faceAnchor)
        }
        
        private func addCatEars(to node: SCNNode, faceAnchor: ARFaceAnchor) {
            leftEarNode = createCatEar()
            if let leftEar = leftEarNode {
                leftEar.position = SCNVector3(-0.08, 0.12, 0.02)
                leftEar.eulerAngles = SCNVector3(
                    degreesToRadians(currentRotationX),
                    degreesToRadians(currentRotationY),
                    degreesToRadians(currentRotationZ)
                )
                node.addChildNode(leftEar)
            }
            
            rightEarNode = createCatEar()
            if let rightEar = rightEarNode {
                rightEar.position = SCNVector3(0.08, 0.12, 0.02)
                rightEar.eulerAngles = SCNVector3(
                    degreesToRadians(currentRotationX),
                    -degreesToRadians(currentRotationY),
                    -degreesToRadians(currentRotationZ)
                )
                node.addChildNode(rightEar)
            }
        }
        
        private func degreesToRadians(_ degrees: CGFloat) -> Float {
            return Float(degrees * .pi / 180.0)
        }
        
        private func createCatEar() -> SCNNode {
            let earGeometry = SCNCone(
                topRadius: currentThickness,
                bottomRadius: currentWidth,
                height: currentHeight
            )
            
            let material = SCNMaterial()
            material.diffuse.contents = currentOuterColor
            material.lightingModel = .physicallyBased
            material.roughness.contents = 0.3
            earGeometry.materials = [material]
            
            let earNode = SCNNode(geometry: earGeometry)
            
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
        
        private func updateEarPositions(node: SCNNode, faceAnchor: ARFaceAnchor) {
            // Ears follow face automatically
        }
        
        func updateEarParameters(outerColor: UIColor, innerColor: UIColor, height: CGFloat, width: CGFloat, thickness: CGFloat, rotX: CGFloat, rotY: CGFloat, rotZ: CGFloat) {
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
            
            currentOuterColor = outerColor
            currentInnerColor = innerColor
            currentHeight = height
            currentWidth = width
            currentThickness = thickness
            currentRotationX = rotX
            currentRotationY = rotY
            currentRotationZ = rotZ
            
            if parametersChanged {
                recreateEars()
            } else if colorsChanged {
                updateEarColors()
            }
        }
        
        private func recreateEars() {
            guard let parent = leftEarNode?.parent else { return }
            
            leftEarNode?.removeFromParentNode()
            rightEarNode?.removeFromParentNode()
            
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
            if let leftEar = leftEarNode?.geometry as? SCNCone {
                leftEar.materials.first?.diffuse.contents = currentOuterColor
            }
            
            if let rightEar = rightEarNode?.geometry as? SCNCone {
                rightEar.materials.first?.diffuse.contents = currentOuterColor
            }
            
            if let leftInner = leftEarNode?.childNodes.first?.geometry as? SCNCone {
                leftInner.materials.first?.diffuse.contents = currentInnerColor
            }
            
            if let rightInner = rightEarNode?.childNodes.first?.geometry as? SCNCone {
                rightInner.materials.first?.diffuse.contents = currentInnerColor
            }
        }
        
        // MARK: - Photo & Video Capture
        
        private func capturePhoto() {
            guard let sceneView = sceneView else { return }
            
            DispatchQueue.main.async {
                let image = sceneView.snapshot()
                
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized, .limited:
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAsset(from: image)
                            }) { success, error in
                                DispatchQueue.main.async {
                                    if success {
                                        self.showAlert(message: "Photo saved to your library")
                                    } else {
                                        self.showAlert(message: "Failed to save photo: \(error?.localizedDescription ?? "Unknown error")")
                                    }
                                }
                            }
                        case .denied, .restricted:
                            self.showAlert(message: "Please allow photo library access in Settings")
                        case .notDetermined:
                            self.showAlert(message: "Photo library permission not determined")
                        @unknown default:
                            self.showAlert(message: "Unknown authorization status")
                        }
                    }
                }
            }
        }
        
        private func startRecording() {
            guard let sceneView = sceneView else {
                showAlert(message: "Scene view not available")
                return
            }
            
            guard !isRecordingVideo else {
                showAlert(message: "Already recording")
                return
            }
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            videoURL = documentsPath.appendingPathComponent("temp_video_\(UUID().uuidString).mp4")
            
            guard let videoURL = videoURL else {
                showAlert(message: "Failed to create video file")
                return
            }
            
            try? FileManager.default.removeItem(at: videoURL)
            
            do {
                videoWriter = try AVAssetWriter(outputURL: videoURL, fileType: .mp4)
                
                let width = Int(sceneView.bounds.width)
                let height = Int(sceneView.bounds.height)
                
                let videoSettings: [String: Any] = [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: width,
                    AVVideoHeightKey: height
                ]
                
                videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
                videoWriterInput?.expectsMediaDataInRealTime = true
                
                let sourcePixelBufferAttributes: [String: Any] = [
                    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                    kCVPixelBufferWidthKey as String: width,
                    kCVPixelBufferHeightKey as String: height
                ]
                
                pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                    assetWriterInput: videoWriterInput!,
                    sourcePixelBufferAttributes: sourcePixelBufferAttributes
                )
                
                if let videoWriterInput = videoWriterInput,
                   videoWriter?.canAdd(videoWriterInput) == true {
                    videoWriter?.add(videoWriterInput)
                }
                
                videoWriter?.startWriting()
                videoWriter?.startSession(atSourceTime: .zero)
                
                isRecordingVideo = true
                videoStartTime = Date()
                lastFrameTime = nil
                
                setupDisplayLink()
                
            } catch {
                showAlert(message: "Failed to start recording: \(error.localizedDescription)")
                cleanupRecording()
            }
        }
        
        private func setupDisplayLink() {
            displayLink = CADisplayLink(target: self, selector: #selector(captureFrame))
            displayLink?.preferredFramesPerSecond = 0
            displayLink?.add(to: .main, forMode: .common)
        }
        
        @objc private func captureFrame() {
            guard isRecordingVideo,
                  let sceneView = sceneView,
                  let videoWriterInput = videoWriterInput,
                  let pixelBufferAdaptor = pixelBufferAdaptor,
                  videoWriterInput.isReadyForMoreMediaData,
                  let startTime = videoStartTime else {
                return
            }
            
            let now = Date()
            
            if let lastFrame = lastFrameTime {
                let timeSinceLastFrame = now.timeIntervalSince(lastFrame)
                let minimumFrameInterval = 1.0 / targetFrameRate
                
                if timeSinceLastFrame < minimumFrameInterval {
                    return
                }
            }
            
            let image = sceneView.snapshot()
            
            if let pixelBuffer = pixelBuffer(from: image) {
                let elapsedTime = now.timeIntervalSince(startTime)
                let frameTime = CMTime(seconds: elapsedTime, preferredTimescale: 600)
                
                pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: frameTime)
                lastFrameTime = now
            }
        }
        
        private func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {
            let width = Int(image.size.width)
            let height = Int(image.size.height)
            
            let attrs = [
                kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
                kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
            ] as CFDictionary
            
            var pixelBuffer: CVPixelBuffer?
            let status = CVPixelBufferCreate(
                kCFAllocatorDefault,
                width,
                height,
                kCVPixelFormatType_32ARGB,
                attrs,
                &pixelBuffer
            )
            
            guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
                return nil
            }
            
            CVPixelBufferLockBaseAddress(buffer, [])
            let pixelData = CVPixelBufferGetBaseAddress(buffer)
            
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            guard let context = CGContext(
                data: pixelData,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                space: rgbColorSpace,
                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
            ) else {
                CVPixelBufferUnlockBaseAddress(buffer, [])
                return nil
            }
            
            context.translateBy(x: 0, y: CGFloat(height))
            context.scaleBy(x: 1, y: -1)
            
            UIGraphicsPushContext(context)
            image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            UIGraphicsPopContext()
            
            CVPixelBufferUnlockBaseAddress(buffer, [])
            
            return buffer
        }
        
        private func stopRecording() {
            guard isRecordingVideo else {
                showAlert(message: "Not currently recording")
                return
            }
            
            isRecordingVideo = false
            displayLink?.invalidate()
            displayLink = nil
            
            videoWriterInput?.markAsFinished()
            
            videoWriter?.finishWriting { [weak self] in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if self.videoWriter?.status == .completed {
                        self.saveVideoToLibrary()
                    } else {
                        self.showAlert(message: "Failed to complete video recording")
                        self.cleanupRecording()
                    }
                }
            }
        }
        
        private func saveVideoToLibrary() {
            guard let videoURL = videoURL else {
                showAlert(message: "Video file not found")
                return
            }
            
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized, .limited:
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                        }) { success, error in
                            DispatchQueue.main.async {
                                if success {
                                    self.showAlert(message: "Video saved to your library")
                                } else {
                                    self.showAlert(message: "Failed to save video: \(error?.localizedDescription ?? "Unknown error")")
                                }
                                self.cleanupRecording()
                            }
                        }
                    case .denied, .restricted:
                        self.showAlert(message: "Please allow photo library access in Settings")
                        self.cleanupRecording()
                    case .notDetermined:
                        self.showAlert(message: "Photo library permission not determined")
                        self.cleanupRecording()
                    @unknown default:
                        self.showAlert(message: "Unknown authorization status")
                        self.cleanupRecording()
                    }
                }
            }
        }
        
        private func cleanupRecording() {
            videoWriter = nil
            videoWriterInput = nil
            pixelBufferAdaptor = nil
            
            if let videoURL = videoURL {
                try? FileManager.default.removeItem(at: videoURL)
                self.videoURL = nil
            }
        }
        
        private func showAlert(message: String) {
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowAlert"),
                object: nil,
                userInfo: ["message": message]
            )
        }
    }
}

// MARK: - Color Extension
extension Color {
    static var systemPink: Color {
        Color(UIColor.systemPink)
    }
    
    var components: [Double] {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [Double(red), Double(green), Double(blue), Double(alpha)]
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

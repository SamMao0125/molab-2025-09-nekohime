import ARKit
import SceneKit
import Photos
import AVFoundation
import UIKit

// MARK: - ARFaceTrackingCoordinator
class ARFaceTrackingCoordinator: NSObject, ARSCNViewDelegate {
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
    
    // Called when a face anchor is added
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        // Create and add cat ears
        addCatEars(to: node, faceAnchor: faceAnchor)
    }
    
    // Called when face anchor updates
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        // Update ear positions if needed
        updateEarPositions(node: node, faceAnchor: faceAnchor)
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
    
    private func updateEarPositions(node: SCNNode, faceAnchor: ARFaceAnchor) {
        // Ears remain relative to the face anchor, so they automatically follow the face
        // This method can be used for more advanced animations based on blend shapes
    }
    
    func updateEarParameters(outerColor: UIColor, innerColor: UIColor, height: CGFloat, width: CGFloat, thickness: CGFloat, rotX: CGFloat, rotY: CGFloat, rotZ: CGFloat) {
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
        
        // Update stored values
        currentOuterColor = outerColor
        currentInnerColor = innerColor
        currentHeight = height
        currentWidth = width
        currentThickness = thickness
        currentRotationX = rotX
        currentRotationY = rotY
        currentRotationZ = rotZ
        
        // If dimensions or rotations changed, recreate the ears
        if parametersChanged {
            recreateEars()
        } else if colorsChanged {
            // Just update colors without recreating geometry
            updateEarColors()
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
    
    // MARK: - Photo & Video Capture
    
    private func capturePhoto() {
        guard let sceneView = sceneView else { return }
        
        // Ensure we're on the main thread for UI operations
        DispatchQueue.main.async {
            // Take a snapshot of the AR scene
            let image = sceneView.snapshot()
            
            // Request permission and save to photo library
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
        
        // Create temporary file URL for video
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        videoURL = documentsPath.appendingPathComponent("temp_video_\(UUID().uuidString).mp4")
        
        guard let videoURL = videoURL else {
            showAlert(message: "Failed to create video file")
            return
        }
        
        // Remove existing file if it exists
        try? FileManager.default.removeItem(at: videoURL)
        
        do {
            // Create video writer
            videoWriter = try AVAssetWriter(outputURL: videoURL, fileType: .mp4)
            
            // Get the scene view bounds
            let width = Int(sceneView.bounds.width)
            let height = Int(sceneView.bounds.height)
            
            // Configure video settings
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: width,
                AVVideoHeightKey: height
            ]
            
            // Create video writer input
            videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            videoWriterInput?.expectsMediaDataInRealTime = true
            
            // Create pixel buffer adaptor
            let sourcePixelBufferAttributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height
            ]
            
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: videoWriterInput!,
                sourcePixelBufferAttributes: sourcePixelBufferAttributes
            )
            
            // Add input to writer
            if let videoWriterInput = videoWriterInput,
               videoWriter?.canAdd(videoWriterInput) == true {
                videoWriter?.add(videoWriterInput)
            }
            
            // Start writing
            videoWriter?.startWriting()
            videoWriter?.startSession(atSourceTime: .zero)
            
            isRecordingVideo = true
            videoStartTime = Date()
            lastFrameTime = nil
            
            // Start capturing frames
            setupDisplayLink()
            
        } catch {
            showAlert(message: "Failed to start recording: \(error.localizedDescription)")
            cleanupRecording()
        }
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(captureFrame))
        // Let it run at screen refresh rate, we'll limit to target FPS in captureFrame
        displayLink?.preferredFramesPerSecond = 0 // 0 = use screen refresh rate
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
        
        // Frame rate limiting: only capture if enough time has passed
        if let lastFrame = lastFrameTime {
            let timeSinceLastFrame = now.timeIntervalSince(lastFrame)
            let minimumFrameInterval = 1.0 / targetFrameRate
            
            if timeSinceLastFrame < minimumFrameInterval {
                return // Skip this frame, too soon
            }
        }
        
        // Capture the current frame as an image
        let image = sceneView.snapshot()
        
        // Convert UIImage to pixel buffer
        if let pixelBuffer = pixelBuffer(from: image) {
            // Calculate actual elapsed time since recording started
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

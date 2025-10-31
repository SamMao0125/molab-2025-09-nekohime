import ARKit
import AVFoundation
import Photos
import UIKit

// MARK: - ARCaptureManager
class ARCaptureManager: NSObject {
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
    
    // MARK: - Photo Capture
    
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
    
    // MARK: - Video Capture
    
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


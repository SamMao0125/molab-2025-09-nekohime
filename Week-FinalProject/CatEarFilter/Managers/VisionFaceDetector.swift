import Vision
import UIKit
import CoreImage

@Observable
class VisionFaceDetector {
    var detectedFaces: [DetectedFace] = []
    var isDetecting = false
    var detectionFailed = false
    
    private var detectionTimeout: DispatchWorkItem?
    
    func detectFaces(in image: UIImage, completion: @escaping () -> Void) {
        isDetecting = true
        detectionFailed = false
        detectedFaces = []
        
        // Set up 10-second timeout
        let timeoutItem = DispatchWorkItem { [weak self] in
            self?.detectionFailed = true
            self?.isDetecting = false
            completion()
        }
        detectionTimeout = timeoutItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: timeoutItem)
        
        guard let cgImage = image.cgImage else {
            detectionFailed = true
            isDetecting = false
            detectionTimeout?.cancel()
            completion()
            return
        }
        
        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }
            
            self.detectionTimeout?.cancel()
            
            if let error = error {
                print("Face detection error: \(error)")
                self.detectionFailed = true
                self.isDetecting = false
                completion()
                return
            }
            
            guard let observations = request.results as? [VNFaceObservation] else {
                self.detectionFailed = true
                self.isDetecting = false
                completion()
                return
            }
            
            if observations.isEmpty {
                self.detectionFailed = true
            } else {
                // Convert observations to DetectedFace objects
                self.detectedFaces = observations.enumerated().map { index, observation in
                    DetectedFace(
                        id: UUID(),
                        boundingBox: observation.boundingBox,
                        imageSize: CGSize(width: cgImage.width, height: cgImage.height),
                        index: index
                    )
                }
            }
            
            self.isDetecting = false
            completion()
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform face detection: \(error)")
                DispatchQueue.main.async {
                    self.detectionTimeout?.cancel()
                    self.detectionFailed = true
                    self.isDetecting = false
                    completion()
                }
            }
        }
    }
    
    func cancelDetection() {
        detectionTimeout?.cancel()
        isDetecting = false
    }
}

struct DetectedFace: Identifiable {
    let id: UUID
    let boundingBox: CGRect // Normalized coordinates (0-1)
    let imageSize: CGSize
    let index: Int
    
    // Convert normalized coordinates to actual pixel coordinates
    func actualBoundingBox(for displaySize: CGSize) -> CGRect {
        // Vision uses bottom-left origin, SwiftUI uses top-left
        let x = boundingBox.origin.x * displaySize.width
        let y = (1 - boundingBox.origin.y - boundingBox.height) * displaySize.height
        let width = boundingBox.width * displaySize.width
        let height = boundingBox.height * displaySize.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    // Suggested ear positions based on face bounds
    func suggestedEarPositions(for displaySize: CGSize) -> (left: CGPoint, right: CGPoint) {
        let faceRect = actualBoundingBox(for: displaySize)
        
        // Position ears at top corners of face, slightly above
        let leftEar = CGPoint(
            x: faceRect.minX + faceRect.width * 0.15,
            y: faceRect.minY - faceRect.height * 0.1
        )
        
        let rightEar = CGPoint(
            x: faceRect.maxX - faceRect.width * 0.15,
            y: faceRect.minY - faceRect.height * 0.1
        )
        
        return (leftEar, rightEar)
    }
}

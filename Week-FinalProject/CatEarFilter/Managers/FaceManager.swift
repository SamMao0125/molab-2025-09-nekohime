import SwiftUI

@Observable
class FaceManager {
    var faces: [FaceWithEars] = []
    var selectedFaceId: UUID?
    
    var selectedFace: FaceWithEars? {
        faces.first { $0.id == selectedFaceId }
    }
    
    func addFace(_ detectedFace: DetectedFace) {
        let faceWithEars = FaceWithEars(detectedFace: detectedFace)
        faces.append(faceWithEars)
        
        // Auto-select first face
        if selectedFaceId == nil {
            selectedFaceId = faceWithEars.id
        }
    }
    
    func selectFace(_ faceId: UUID) {
        selectedFaceId = faceId
    }
    
    func updateEarConfiguration(for faceId: UUID, config: EarConfiguration) {
        if let index = faces.firstIndex(where: { $0.id == faceId }) {
            faces[index].earConfig = config
        }
    }
    
    func removeFace(_ faceId: UUID) {
        faces.removeAll { $0.id == faceId }
        
        // If removed face was selected, select first available
        if selectedFaceId == faceId {
            selectedFaceId = faces.first?.id
        }
    }
    
    func reset() {
        faces.removeAll()
        selectedFaceId = nil
    }
}

struct FaceWithEars: Identifiable {
    let id: UUID
    let detectedFace: DetectedFace
    var earConfig: EarConfiguration
    var leftEarPosition: CGPoint
    var rightEarPosition: CGPoint
    
    init(detectedFace: DetectedFace) {
        self.id = detectedFace.id
        self.detectedFace = detectedFace
        self.earConfig = EarConfiguration()
        
        // Initialize with zero positions (will be updated)
        self.leftEarPosition = .zero
        self.rightEarPosition = .zero
    }
    
    mutating func updateEarPositions(for imageSize: CGSize) {
        // Convert normalized bounding box to actual screen coordinates
        let faceRect = CGRect(
            x: detectedFace.boundingBox.origin.x * imageSize.width,
            y: detectedFace.boundingBox.origin.y * imageSize.height,
            width: detectedFace.boundingBox.width * imageSize.width,
            height: detectedFace.boundingBox.height * imageSize.height
        )
        
        // Calculate ear positions relative to face
        let earOffsetX: CGFloat = faceRect.width * 0.4  // Ears 40% of face width from center
        let earOffsetY: CGFloat = faceRect.height * 0.3  // Ears 30% above face center
        
        let faceCenterX = faceRect.midX
        let faceCenterY = faceRect.midY
        
        // Position ears at the top corners of the face
        leftEarPosition = CGPoint(
            x: faceCenterX - earOffsetX,
            y: faceCenterY - earOffsetY
        )
        
        rightEarPosition = CGPoint(
            x: faceCenterX + earOffsetX,
            y: faceCenterY - earOffsetY
        )
        
        print("📍 Updated ear positions for image size: \(imageSize)")
        print("   Face rect: \(faceRect)")
        print("   Left ear: \(leftEarPosition)")
        print("   Right ear: \(rightEarPosition)")
    }
}

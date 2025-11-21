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
        
        // Initialize with suggested positions (will be updated based on actual image size)
        self.leftEarPosition = .zero
        self.rightEarPosition = .zero
    }
    
    mutating func updateEarPositions(for displaySize: CGSize) {
        let suggested = detectedFace.suggestedEarPositions(for: displaySize)
        self.leftEarPosition = suggested.left
        self.rightEarPosition = suggested.right
    }
}

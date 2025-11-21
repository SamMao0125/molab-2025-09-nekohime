import SwiftUI
import Combine

@Observable
class PerformanceMonitor {
    var currentFPS: Double = 60.0
    var shouldReduceQuality: Bool = false
    var qualityReduced: Bool = false
    
    private var lastFrameTime: CFTimeInterval = 0
    private var frameCount: Int = 0
    private var fpsBuffer: [Double] = []
    private let bufferSize = 30 // Average over 30 frames
    private let fpsThreshold = 25.0 // Suggest quality reduction below 25fps
    
    func updateFrame() {
        let currentTime = CACurrentMediaTime()
        
        if lastFrameTime > 0 {
            let deltaTime = currentTime - lastFrameTime
            let instantFPS = 1.0 / deltaTime
            
            fpsBuffer.append(instantFPS)
            if fpsBuffer.count > bufferSize {
                fpsBuffer.removeFirst()
            }
            
            // Calculate average FPS
            currentFPS = fpsBuffer.reduce(0, +) / Double(fpsBuffer.count)
            
            // Check if we should suggest quality reduction
            if currentFPS < fpsThreshold && !qualityReduced {
                shouldReduceQuality = true
            }
        }
        
        lastFrameTime = currentTime
        frameCount += 1
    }
    
    func userAcceptedQualityReduction() {
        qualityReduced = true
        shouldReduceQuality = false
    }
    
    func userDeclinedQualityReduction() {
        shouldReduceQuality = false
    }
    
    func reset() {
        fpsBuffer.removeAll()
        lastFrameTime = 0
        frameCount = 0
        shouldReduceQuality = false
        qualityReduced = false
        currentFPS = 60.0
    }
}

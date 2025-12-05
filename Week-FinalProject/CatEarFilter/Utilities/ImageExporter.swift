import UIKit
import SwiftUI

class ImageExporter {
    func exportImage(
        baseImage: UIImage,
        faces: [FaceWithEars],
        progressHandler: @escaping (Double) -> Void,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                progressHandler(0.1)
                
                let imageSize = baseImage.size
                let scale = baseImage.scale
                
                progressHandler(0.2)
                
                let format = UIGraphicsImageRendererFormat()
                format.scale = scale
                format.opaque = false
                
                let renderer = UIGraphicsImageRenderer(size: imageSize, format: format)
                
                let finalImage = renderer.image { context in
                    baseImage.draw(at: .zero)
                    
                    progressHandler(0.4)
                    
                    let totalFaces = Double(faces.count)
                    for (index, face) in faces.enumerated() {
                        self.drawEars(for: face, in: context.cgContext, imageSize: imageSize)
                        
                        let progress = 0.4 + (Double(index + 1) / totalFaces) * 0.5
                        progressHandler(progress)
                    }
                }
                
                progressHandler(0.95)
                
                DispatchQueue.main.async {
                    progressHandler(1.0)
                    completion(.success(finalImage))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func drawEars(for face: FaceWithEars, in context: CGContext, imageSize: CGSize) {
        let config = face.earConfig
        
        // Calculate ear size EXACTLY like in EarOverlayView
        let baseSize: CGFloat = 120
        let earWidth: CGFloat
        let earHeight: CGFloat
        
        if config.lockScale {
            earWidth = baseSize * CGFloat(config.size)
            earHeight = earWidth * 1.6
        } else {
            earWidth = baseSize * CGFloat(config.scaleWidth)
            earHeight = baseSize * CGFloat(config.scaleHeight) * 1.6
        }
        
        let earSize = CGSize(width: earWidth, height: earHeight)
        
        // Draw left ear at EXACT position from overlay
        drawSingleEar(
            at: face.leftEarPosition,
            size: earSize,
            rotation: CGFloat(config.leftRotation),
            config: config,
            isLeft: true,
            in: context
        )
        
        // Draw right ear at EXACT position from overlay
        let rightRotation = config.syncRotation ? config.leftRotation : config.rightRotation
        drawSingleEar(
            at: face.rightEarPosition,
            size: earSize,
            rotation: CGFloat(rightRotation),
            config: config,
            isLeft: false,
            in: context
        )
    }
    
    private func drawSingleEar(
        at position: CGPoint,
        size: CGSize,
        rotation: CGFloat,
        config: EarConfiguration,
        isLeft: Bool,
        in context: CGContext
    ) {
        context.saveGState()
        
        context.translateBy(x: position.x, y: position.y)
        context.rotate(by: rotation)
        
        // Draw outer ear with beautiful shape
        let outerEarPath = createBeautifulEarPath(size: size)
        context.addPath(outerEarPath)
        context.setFillColor(UIColor(config.outerColor.color).cgColor)
        context.fillPath()
        
        // Draw inner ear (smaller, offset down)
        let innerSize = CGSize(width: size.width * 0.6, height: size.height * 0.6)
        let innerOffset = size.height * 0.2
        
        context.saveGState()
        context.translateBy(x: 0, y: innerOffset)
        
        let innerEarPath = createBeautifulEarPath(size: innerSize)
        context.addPath(innerEarPath)
        context.setFillColor(UIColor(config.innerColor.color).cgColor)
        context.fillPath()
        
        context.restoreGState()
        
        context.restoreGState()
    }
    
    private func createBeautifulEarPath(size: CGSize) -> CGPath {
        let path = CGMutablePath()
        
        let width = size.width
        let height = size.height
        
        let offsetX = -width / 2
        let offsetY = -height / 2
        
        // Beautiful curved ear matching EarOverlayView
        let baseLeft = CGPoint(x: offsetX + width * 0.2, y: offsetY + height)
        let baseRight = CGPoint(x: offsetX + width * 0.8, y: offsetY + height)
        let tip = CGPoint(x: offsetX + width * 0.5, y: offsetY)
        
        path.move(to: baseLeft)
        
        // Left side - big smooth curve
        let leftControl1 = CGPoint(x: offsetX + width * 0.05, y: offsetY + height * 0.65)
        let leftControl2 = CGPoint(x: offsetX + width * 0.25, y: offsetY + height * 0.15)
        path.addCurve(to: tip, control1: leftControl1, control2: leftControl2)
        
        // Right side - big smooth curve
        let rightControl1 = CGPoint(x: offsetX + width * 0.75, y: offsetY + height * 0.15)
        let rightControl2 = CGPoint(x: offsetX + width * 0.95, y: offsetY + height * 0.65)
        path.addCurve(to: baseRight, control1: rightControl1, control2: rightControl2)
        
        // Curved bottom
        let bottomControl1 = CGPoint(x: offsetX + width * 0.7, y: offsetY + height * 1.02)
        let bottomControl2 = CGPoint(x: offsetX + width * 0.3, y: offsetY + height * 1.02)
        path.addCurve(to: baseLeft, control1: bottomControl1, control2: bottomControl2)
        
        path.closeSubpath()
        
        return path
    }
}

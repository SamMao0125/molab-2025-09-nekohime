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
                
                // Get original image size
                let imageSize = baseImage.size
                let scale = baseImage.scale
                
                progressHandler(0.2)
                
                // Create graphics context at full resolution
                let format = UIGraphicsImageRendererFormat()
                format.scale = scale
                format.opaque = false
                
                let renderer = UIGraphicsImageRenderer(size: imageSize, format: format)
                
                let finalImage = renderer.image { context in
                    // Draw base image
                    baseImage.draw(at: .zero)
                    
                    progressHandler(0.4)
                    
                    // Draw ears for each face
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
        
        // Calculate ear size based on configuration
        let baseSize: CGFloat = 80
        let earWidth = baseSize * CGFloat(config.size)
        let earHeight = earWidth * 1.6
        
        // Draw left ear
        drawSingleEar(
            at: face.leftEarPosition,
            size: CGSize(width: earWidth, height: earHeight),
            rotation: CGFloat(config.leftRotation),
            config: config,
            isLeft: true,
            in: context
        )
        
        // Draw right ear
        let rightRotation = config.syncRotation ? config.leftRotation : config.rightRotation
        drawSingleEar(
            at: face.rightEarPosition,
            size: CGSize(width: earWidth, height: earHeight),
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
        
        // Translate to ear position
        context.translateBy(x: position.x, y: position.y)
        
        // Apply rotation
        context.rotate(by: rotation)
        
        // Draw shadow if configured
        if config.shadowOpacity > 0 {
            let shadowOffset = CGSize(
                width: CGFloat(config.shadowOffsetX * 100),
                height: CGFloat(config.shadowOffsetY * 100)
            )
            context.setShadow(
                offset: shadowOffset,
                blur: CGFloat(config.shadowBlur * 100),
                color: UIColor.black.withAlphaComponent(CGFloat(config.shadowOpacity)).cgColor
            )
        }
        
        // Create ear path
        let earPath = createEarPath(size: size)
        
        // Fill with color
        context.addPath(earPath)
        context.setFillColor(UIColor(config.outerColor.color).cgColor)
        context.fillPath()
        
        // Draw outline if configured
        if config.hasOutline {
            context.addPath(earPath)
            context.setStrokeColor(UIColor(config.outlineColor.color).cgColor)
            context.setLineWidth(CGFloat(config.outlineWidth * 100))
            context.strokePath()
        }
        
        // Draw inner ear
        let innerEarPath = createInnerEarPath(size: size)
        context.addPath(innerEarPath)
        context.setFillColor(UIColor(config.innerColor.color).cgColor)
        context.fillPath()
        
        context.restoreGState()
    }
    
    private func createEarPath(size: CGSize) -> CGPath {
        let path = CGMutablePath()
        
        let width = size.width
        let height = size.height
        
        // Center the ear around (0, 0)
        let offsetX = -width / 2
        let offsetY = -height / 2
        
        let baseLeft = CGPoint(x: offsetX + width * 0.2, y: offsetY + height)
        let baseRight = CGPoint(x: offsetX + width * 0.8, y: offsetY + height)
        let tip = CGPoint(x: offsetX + width * 0.5, y: offsetY)
        
        path.move(to: baseLeft)
        
        // Curved left side
        let leftControl1 = CGPoint(x: offsetX + width * 0.1, y: offsetY + height * 0.6)
        let leftControl2 = CGPoint(x: offsetX + width * 0.3, y: offsetY + height * 0.2)
        path.addCurve(to: tip, control1: leftControl1, control2: leftControl2)
        
        // Curved right side
        let rightControl1 = CGPoint(x: offsetX + width * 0.7, y: offsetY + height * 0.2)
        let rightControl2 = CGPoint(x: offsetX + width * 0.9, y: offsetY + height * 0.6)
        path.addCurve(to: baseRight, control1: rightControl1, control2: rightControl2)
        
        path.addLine(to: baseLeft)
        path.closeSubpath()
        
        return path
    }
    
    private func createInnerEarPath(size: CGSize) -> CGPath {
        let path = CGMutablePath()
        
        let width = size.width
        let height = size.height
        let inset: CGFloat = 10
        
        let offsetX = -width / 2
        let offsetY = -height / 2
        
        let baseLeft = CGPoint(x: offsetX + width * 0.3, y: offsetY + height - inset)
        let baseRight = CGPoint(x: offsetX + width * 0.7, y: offsetY + height - inset)
        let tip = CGPoint(x: offsetX + width * 0.5, y: offsetY + height * 0.3)
        
        path.move(to: baseLeft)
        
        let leftControl = CGPoint(x: offsetX + width * 0.35, y: offsetY + height * 0.5)
        path.addQuadCurve(to: tip, control: leftControl)
        
        let rightControl = CGPoint(x: offsetX + width * 0.65, y: offsetY + height * 0.5)
        path.addQuadCurve(to: baseRight, control: rightControl)
        
        path.addLine(to: baseLeft)
        path.closeSubpath()
        
        return path
    }
}

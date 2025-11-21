import SwiftUI

struct EarOverlayView: View {
    @Binding var face: FaceWithEars
    let isSelected: Bool
    let imageSize: CGSize
    let zoom: CGFloat
    let offset: CGSize
    let onSelect: () -> Void
    
    @State private var isDraggingLeft = false
    @State private var isDraggingRight = false
    
    var body: some View {
        ZStack {
            // Left ear
            EarShape(config: face.earConfig, isLeft: true)
                .fill(earColor)
                .overlay(
                    EarShape(config: face.earConfig, isLeft: true)
                        .stroke(
                            face.earConfig.hasOutline ? face.earConfig.outlineColor.color : Color.clear,
                            lineWidth: CGFloat(face.earConfig.outlineWidth * 100)
                        )
                )
                .frame(width: earSize.width, height: earSize.height)
                .rotationEffect(Angle(radians: Double(face.earConfig.leftRotation)))
                .shadow(
                    color: Color.black.opacity(Double(face.earConfig.shadowOpacity)),
                    radius: CGFloat(face.earConfig.shadowBlur * 100),
                    x: CGFloat(face.earConfig.shadowOffsetX * 100),
                    y: CGFloat(face.earConfig.shadowOffsetY * 100)
                )
                .position(face.leftEarPosition)
                .gesture(earDragGesture(isLeft: true))
                .overlay(
                    isSelected ? selectionIndicator : nil
                )
            
            // Right ear
            EarShape(config: face.earConfig, isLeft: false)
                .fill(earColor)
                .overlay(
                    EarShape(config: face.earConfig, isLeft: false)
                        .stroke(
                            face.earConfig.hasOutline ? face.earConfig.outlineColor.color : Color.clear,
                            lineWidth: CGFloat(face.earConfig.outlineWidth * 100)
                        )
                )
                .frame(width: earSize.width, height: earSize.height)
                .rotationEffect(Angle(radians: Double(face.earConfig.syncRotation ? face.earConfig.leftRotation : face.earConfig.rightRotation)))
                .shadow(
                    color: Color.black.opacity(Double(face.earConfig.shadowOpacity)),
                    radius: CGFloat(face.earConfig.shadowBlur * 100),
                    x: CGFloat(face.earConfig.shadowOffsetX * 100),
                    y: CGFloat(face.earConfig.shadowOffsetY * 100)
                )
                .position(face.rightEarPosition)
                .gesture(earDragGesture(isLeft: false))
                .overlay(
                    isSelected ? selectionIndicator : nil
                )
        }
        .onTapGesture {
            onSelect()
        }
    }
    
    private var earSize: CGSize {
        let baseSize: CGFloat = 80
        let scaledSize = baseSize * CGFloat(face.earConfig.size)
        return CGSize(width: scaledSize, height: scaledSize * 1.6) // Ears are taller than wide
    }
    
    private var earColor: Color {
        if face.earConfig.useGradient {
            // For gradient, we'll use a simple approximation
            // Real gradient rendering would need a custom shape
            return face.earConfig.outerColor.color
        } else {
            return face.earConfig.outerColor.color
        }
    }
    
    private var selectionIndicator: some View {
        Circle()
            .stroke(Color.white, lineWidth: 2)
            .frame(width: 10, height: 10)
            .position(x: earSize.width / 2, y: 0)
    }
    
    private func earDragGesture(isLeft: Bool) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if isLeft {
                    face.leftEarPosition = CGPoint(
                        x: face.leftEarPosition.x + value.translation.width,
                        y: face.leftEarPosition.y + value.translation.height
                    )
                } else {
                    face.rightEarPosition = CGPoint(
                        x: face.rightEarPosition.x + value.translation.width,
                        y: face.rightEarPosition.y + value.translation.height
                    )
                }
            }
    }
}

// Custom ear shape
struct EarShape: Shape {
    let config: EarConfiguration
    let isLeft: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Create a pointed ear shape (chibi style)
        // Base points
        let baseLeft = CGPoint(x: width * 0.2, y: height)
        let baseRight = CGPoint(x: width * 0.8, y: height)
        let tip = CGPoint(x: width * 0.5, y: 0)
        
        // Outer ear
        path.move(to: baseLeft)
        
        // Curved left side
        let leftControl1 = CGPoint(x: width * 0.1, y: height * 0.6)
        let leftControl2 = CGPoint(x: width * 0.3, y: height * 0.2)
        path.addCurve(to: tip, control1: leftControl1, control2: leftControl2)
        
        // Curved right side
        let rightControl1 = CGPoint(x: width * 0.7, y: height * 0.2)
        let rightControl2 = CGPoint(x: width * 0.9, y: height * 0.6)
        path.addCurve(to: baseRight, control1: rightControl1, control2: rightControl2)
        
        // Bottom edge
        path.addLine(to: baseLeft)
        path.closeSubpath()
        
        // Inner ear (slightly smaller, different color)
        let innerPath = createInnerEar(in: rect)
        path.addPath(innerPath)
        
        return path
    }
    
    private func createInnerEar(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let inset: CGFloat = 10
        
        let baseLeft = CGPoint(x: width * 0.3, y: height - inset)
        let baseRight = CGPoint(x: width * 0.7, y: height - inset)
        let tip = CGPoint(x: width * 0.5, y: height * 0.3)
        
        path.move(to: baseLeft)
        
        let leftControl = CGPoint(x: width * 0.35, y: height * 0.5)
        path.addQuadCurve(to: tip, control: leftControl)
        
        let rightControl = CGPoint(x: width * 0.65, y: height * 0.5)
        path.addQuadCurve(to: baseRight, control: rightControl)
        
        path.addLine(to: baseLeft)
        path.closeSubpath()
        
        return path
    }
}

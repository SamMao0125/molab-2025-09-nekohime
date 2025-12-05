import SwiftUI

struct EarOverlayView: View {
    @Binding var face: FaceWithEars
    let isSelected: Bool
    let imageSize: CGSize
    let zoom: CGFloat
    let offset: CGSize
    let onSelect: () -> Void
    
    @State private var dragStartLeft: CGPoint?
    @State private var dragStartRight: CGPoint?
    
    var body: some View {
        ZStack {
            // Left ear
            BeautifulEarShape(config: face.earConfig, isLeft: true)
                .fill(face.earConfig.outerColor.color)
                .overlay(
                    BeautifulEarShape(config: face.earConfig, isLeft: true)
                        .fill(face.earConfig.innerColor.color)
                        .scaleEffect(0.6)
                        .offset(y: 20)
                )
                .frame(width: earSize.width, height: earSize.height)
                .rotationEffect(Angle(radians: Double(face.earConfig.leftRotation)))
                .position(face.leftEarPosition)
                .gesture(earDragGesture(isLeft: true))
                .overlay(
                    isSelected ? Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .position(x: earSize.width / 2, y: 0)
                    : nil
                )
            
            // Right ear
            BeautifulEarShape(config: face.earConfig, isLeft: false)
                .fill(face.earConfig.outerColor.color)
                .overlay(
                    BeautifulEarShape(config: face.earConfig, isLeft: false)
                        .fill(face.earConfig.innerColor.color)
                        .scaleEffect(0.6)
                        .offset(y: 20)
                )
                .frame(width: earSize.width, height: earSize.height)
                .rotationEffect(Angle(radians: Double(face.earConfig.syncRotation ? face.earConfig.leftRotation : face.earConfig.rightRotation)))
                .position(face.rightEarPosition)
                .gesture(earDragGesture(isLeft: false))
                .overlay(
                    isSelected ? Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .position(x: earSize.width / 2, y: 0)
                    : nil
                )
        }
        // Force re-render when ANY config property changes
        .id("\(face.earConfig.size)-\(face.earConfig.scaleWidth)-\(face.earConfig.scaleHeight)-\(face.earConfig.leftRotation)-\(face.earConfig.rightRotation)-\(face.earConfig.outerColor.red)-\(face.earConfig.outerColor.green)-\(face.earConfig.outerColor.blue)-\(face.earConfig.innerColor.red)-\(face.earConfig.innerColor.green)-\(face.earConfig.innerColor.blue)")
        .onTapGesture {
            onSelect()
        }
    }
    
    private var earSize: CGSize {
        let baseSize: CGFloat = 120
        
        let width: CGFloat
        let height: CGFloat
        
        if face.earConfig.lockScale {
            width = baseSize * CGFloat(face.earConfig.size)
            height = width * 1.6
        } else {
            width = baseSize * CGFloat(face.earConfig.scaleWidth)
            height = baseSize * CGFloat(face.earConfig.scaleHeight) * 1.6
        }
        
        return CGSize(width: width, height: height)
    }
    
    private func earDragGesture(isLeft: Bool) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if isLeft && dragStartLeft == nil {
                    dragStartLeft = face.leftEarPosition
                } else if !isLeft && dragStartRight == nil {
                    dragStartRight = face.rightEarPosition
                }
                
                if isLeft, let start = dragStartLeft {
                    face.leftEarPosition = CGPoint(
                        x: start.x + value.translation.width,
                        y: start.y + value.translation.height
                    )
                } else if !isLeft, let start = dragStartRight {
                    face.rightEarPosition = CGPoint(
                        x: start.x + value.translation.width,
                        y: start.y + value.translation.height
                    )
                }
            }
            .onEnded { _ in
                if isLeft {
                    dragStartLeft = nil
                } else {
                    dragStartRight = nil
                }
            }
    }
}

struct BeautifulEarShape: Shape {
    let config: EarConfiguration
    let isLeft: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        let baseLeft = CGPoint(x: width * 0.2, y: height)
        let baseRight = CGPoint(x: width * 0.8, y: height)
        let tip = CGPoint(x: width * 0.5, y: 0)
        
        path.move(to: baseLeft)
        
        let leftControl1 = CGPoint(x: width * 0.05, y: height * 0.65)
        let leftControl2 = CGPoint(x: width * 0.25, y: height * 0.15)
        path.addCurve(to: tip, control1: leftControl1, control2: leftControl2)
        
        let rightControl1 = CGPoint(x: width * 0.75, y: height * 0.15)
        let rightControl2 = CGPoint(x: width * 0.95, y: height * 0.65)
        path.addCurve(to: baseRight, control1: rightControl1, control2: rightControl2)
        
        let bottomControl1 = CGPoint(x: width * 0.7, y: height * 1.02)
        let bottomControl2 = CGPoint(x: width * 0.3, y: height * 1.02)
        path.addCurve(to: baseLeft, control1: bottomControl1, control2: bottomControl2)
        
        path.closeSubpath()
        
        return path
    }
}

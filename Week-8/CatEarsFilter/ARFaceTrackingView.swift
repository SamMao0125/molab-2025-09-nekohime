import SwiftUI
import ARKit
import SceneKit
import UIKit

// MARK: - ARFaceTrackingView
struct ARFaceTrackingView: UIViewRepresentable {
    @Binding var outerEarColor: Color
    @Binding var innerEarColor: Color
    @Binding var earHeight: Double
    @Binding var earWidth: Double
    @Binding var earThickness: Double
    @Binding var rotationX: Double
    @Binding var rotationY: Double
    @Binding var rotationZ: Double
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        
        // Check if face tracking is supported
        guard ARFaceTrackingConfiguration.isSupported else {
            return sceneView
        }
        
        sceneView.delegate = context.coordinator
        sceneView.automaticallyUpdatesLighting = true
        
        // Store reference to sceneView in coordinator
        context.coordinator.sceneView = sceneView
        
        // Start face tracking session
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Update all customization parameters
        context.coordinator.updateEarParameters(
            outerColor: uiColor(from: outerEarColor),
            innerColor: uiColor(from: innerEarColor),
            height: CGFloat(earHeight),
            width: CGFloat(earWidth),
            thickness: CGFloat(earThickness),
            rotX: CGFloat(rotationX),
            rotY: CGFloat(rotationY),
            rotZ: CGFloat(rotationZ)
        )
    }
    
    func makeCoordinator() -> ARFaceTrackingCoordinator {
        ARFaceTrackingCoordinator()
    }
    
    // Convert SwiftUI Color to UIColor
    private func uiColor(from color: Color) -> UIColor {
        let components = UIColor(color).cgColor.components ?? [1, 0, 0, 1]
        return UIColor(
            red: components[0],
            green: components[1],
            blue: components[2],
            alpha: components[3]
        )
    }
}

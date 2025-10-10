import SwiftUI
import CoreMotion
import Combine

@main
struct CatBalanceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var motionDetector = MotionDetector()
    @State private var showData = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.pink.opacity(0.3), Color.purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("🐱 Cat Balance 🐱")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.purple)
                    .padding(.top, 40)
                
                Spacer()
                
                CatBalanceView(
                    pitch: motionDetector.pitch,
                    roll: motionDetector.roll
                )
                .frame(height: 400)
                
                Spacer()
                
                // Status text
                VStack(spacing: 10) {
                    Text(balanceStatus)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(isBalanced ? .green : .orange)
                    
                    Text(balanceEmoji)
                        .font(.system(size: 50))
                }
                .padding()
                
                Button(action: {
                    showData.toggle()
                }) {
                    Text(showData ? "Hide Data" : "Show Data")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
            }
            
            if showData {
                VStack {
                    Spacer()
                    OrientationDataView(
                        pitch: motionDetector.pitch,
                        roll: motionDetector.roll,
                        yaw: motionDetector.yaw
                    )
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(15)
                    .padding()
                    .shadow(radius: 10)
                }
            }
        }
        .onAppear {
            motionDetector.start()
        }
        .onDisappear {
            motionDetector.stop()
        }
    }
    
    private var isBalanced: Bool {
        abs(motionDetector.pitch) < 5 && abs(motionDetector.roll) < 5
    }
    
    private var balanceStatus: String {
        if isBalanced {
            return "Purrfect Balance!"
        } else if abs(motionDetector.pitch) > 15 || abs(motionDetector.roll) > 15 {
            return "Whoa! Too wobbly!"
        } else {
            return "Almost there..."
        }
    }
    
    private var balanceEmoji: String {
        if isBalanced {
            return "😸"
        } else if abs(motionDetector.pitch) > 15 || abs(motionDetector.roll) > 15 {
            return "🙀"
        } else {
            return "😺"
        }
    }
}

struct CatBalanceView: View {
    let pitch: Double
    let roll: Double
    
    private let maxTilt: Double = 30.0
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let catSize = size * 0.25
            
            ZStack {
                // Platform
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [Color.brown.opacity(0.6), Color.brown.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.8, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.brown, lineWidth: 2)
                    )
                    .rotation3DEffect(
                        .degrees(pitch),
                        axis: (x: 1, y: 0, z: 0)
                    )
                    .rotation3DEffect(
                        .degrees(-roll),
                        axis: (x: 0, y: 0, z: 1)
                    )
                
                // Cat sitting on platform
                VStack(spacing: 0) {
                    // Cat head
                    ZStack {
                        // Ears
                        HStack(spacing: catSize * 0.4) {
                            Triangle()
                                .fill(Color.orange)
                                .frame(width: catSize * 0.3, height: catSize * 0.3)
                            Triangle()
                                .fill(Color.orange)
                                .frame(width: catSize * 0.3, height: catSize * 0.3)
                        }
                        .offset(y: -catSize * 0.15)
                        
                        // Face
                        Circle()
                            .fill(Color.orange)
                            .frame(width: catSize, height: catSize)
                            .overlay(
                                VStack(spacing: catSize * 0.1) {
                                    // Eyes
                                    HStack(spacing: catSize * 0.2) {
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: catSize * 0.15, height: catSize * 0.2)
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: catSize * 0.15, height: catSize * 0.2)
                                    }
                                    .offset(y: -catSize * 0.1)
                                    
                                    // Nose
                                    Circle()
                                        .fill(Color.pink)
                                        .frame(width: catSize * 0.1, height: catSize * 0.1)
                                        .offset(y: -catSize * 0.05)
                                }
                            )
                    }
                    
                    // Body
                    Capsule()
                        .fill(Color.orange)
                        .frame(width: catSize * 0.8, height: catSize * 0.6)
                        .offset(y: -10)
                }
                .offset(
                    x: -roll.clamped(to: -maxTilt...maxTilt) / maxTilt * (size * 0.3),
                    y: -pitch.clamped(to: -maxTilt...maxTilt) / maxTilt * (size * 0.2) - catSize * 0.6
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pitch)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: roll)
                
                // Paw prints when balanced
                if abs(pitch) < 5 && abs(roll) < 5 {
                    ForEach(0..<4, id: \.self) { i in
                        PawPrint()
                            .fill(Color.pink.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .offset(
                                x: CGFloat([60, -60, 80, -80][i]),
                                y: CGFloat([100, 100, 150, 150][i])
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct PawPrint: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Main pad
        let mainPad = CGRect(
            x: rect.midX - rect.width * 0.3,
            y: rect.midY,
            width: rect.width * 0.6,
            height: rect.height * 0.4
        )
        path.addEllipse(in: mainPad)
        
        // Toe pads
        let toeSize = rect.width * 0.2
        let toePositions: [(CGFloat, CGFloat)] = [
            (0.3, 0.2),
            (0.5, 0.1),
            (0.7, 0.2)
        ]
        
        for (x, y) in toePositions {
            let toe = CGRect(
                x: rect.width * x - toeSize/2,
                y: rect.height * y - toeSize/2,
                width: toeSize,
                height: toeSize
            )
            path.addEllipse(in: toe)
        }
        
        return path
    }
}

struct OrientationDataView: View {
    let pitch: Double
    let roll: Double
    let yaw: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("📊 Orientation Data")
                .font(.headline)
                .foregroundColor(.purple)
            
            DataRow(label: "Pitch", value: pitch, unit: "°")
            DataRow(label: "Roll", value: roll, unit: "°")
            DataRow(label: "Yaw", value: yaw, unit: "°")
        }
        .padding()
    }
}

struct DataRow: View {
    let label: String
    let value: Double
    let unit: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .fontWeight(.semibold)
                .frame(width: 60, alignment: .leading)
            
            Text(String(format: "%.1f", value) + unit)
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
    }
}

// MARK: - Motion Detector

class MotionDetector: ObservableObject {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    @Published var yaw: Double = 0.0
    
    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] motion, error in
            guard let motion = motion, error == nil else { return }
            
            let pitch = motion.attitude.pitch.toDegrees
            let roll = motion.attitude.roll.toDegrees
            let yaw = motion.attitude.yaw.toDegrees
            
            DispatchQueue.main.async {
                self?.pitch = pitch
                self?.roll = roll
                self?.yaw = yaw
            }
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}

// MARK: - Extensions
extension Double {
    var toDegrees: Double {
        return self * 180 / .pi
    }
    
    func clamped(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

#Preview {
    ContentView()
}

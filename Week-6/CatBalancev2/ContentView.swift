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
    @StateObject private var balanceTracker = BalanceTracker()
    @State private var showData = false
    @State private var showStats = false
    @State private var lastBalanceState = false
    @State private var spherePosition = CGPoint.zero
    @State private var sphereVelocity = CGVector.zero
    @State private var sphereRotation: Double = 0
    
    let sphereRadius: CGFloat = 40
    let platformSize: CGFloat = 250
    let friction: CGFloat = 0.95
    let acceleration: CGFloat = 2.0
    
    var body: some View {
        ZStack {
            // Background gradient - black and white
            LinearGradient(
                colors: [Color.gray.opacity(0.2), Color.black.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Sphere Balance")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 40)
                
                // Stats button
                HStack {
                    Spacer()
                    Button(action: {
                        showStats.toggle()
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding(.trailing, 20)
                }
                
                Spacer()
                
                // 3D Platform with sphere
                SphereBalanceView(
                    pitch: motionDetector.pitch,
                    roll: motionDetector.roll,
                    spherePosition: $spherePosition,
                    sphereVelocity: $sphereVelocity,
                    sphereRotation: $sphereRotation,
                    sphereRadius: sphereRadius,
                    platformSize: platformSize
                )
                .frame(height: 400)
                
                Spacer()
                
                // Status text
                VStack(spacing: 10) {
                    Text(balanceStatus)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(isBalanced ? .black : .gray)
                    
                    if isBalanced {
                        Text("Balance #\(balanceTracker.totalBalances + 1)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                Button(action: {
                    showData.toggle()
                }) {
                    Text(showData ? "Hide Data" : "Show Data")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
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
            
            if showStats {
                StatsView(balanceTracker: balanceTracker, isShowing: $showStats)
            }
        }
        .onAppear {
            motionDetector.start()
            startPhysicsUpdate()
        }
        .onDisappear {
            motionDetector.stop()
        }
        .onChange(of: isBalanced) { oldValue, newValue in
            if newValue && !lastBalanceState {
                // Just achieved balance
                balanceTracker.recordBalance()
            }
            lastBalanceState = newValue
        }
    }
    
    private var isBalanced: Bool {
        let distanceFromCenter = sqrt(spherePosition.x * spherePosition.x + spherePosition.y * spherePosition.y)
        return distanceFromCenter < 20 && abs(motionDetector.pitch) < 5 && abs(motionDetector.roll) < 5
    }
    
    private var balanceStatus: String {
        let distanceFromCenter = sqrt(spherePosition.x * spherePosition.x + spherePosition.y * spherePosition.y)
        
        if isBalanced {
            return "Perfect Balance!"
        } else if distanceFromCenter > platformSize / 2 - sphereRadius {
            return "Falling off!"
        } else if abs(motionDetector.pitch) > 15 || abs(motionDetector.roll) > 15 {
            return "Too tilted!"
        } else {
            return "Keep centering..."
        }
    }
    
    private func startPhysicsUpdate() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updatePhysics()
        }
    }
    
    private func updatePhysics() {
        // Apply acceleration based on tilt
        let accelX = -motionDetector.roll * acceleration
        let accelY = motionDetector.pitch * acceleration
        
        // Update velocity
        sphereVelocity.dx += accelX
        sphereVelocity.dy += accelY
        
        // Apply friction
        sphereVelocity.dx *= friction
        sphereVelocity.dy *= friction
        
        // Update position
        var newPosition = spherePosition
        newPosition.x += sphereVelocity.dx
        newPosition.y += sphereVelocity.dy
        
        // Keep sphere on platform (circular boundary)
        let maxDistance = platformSize / 2 - sphereRadius
        let distance = sqrt(newPosition.x * newPosition.x + newPosition.y * newPosition.y)
        
        if distance > maxDistance {
            // Normalize and constrain to platform edge
            let scale = maxDistance / distance
            newPosition.x *= scale
            newPosition.y *= scale
            
            // Bounce back
            sphereVelocity.dx *= -0.5
            sphereVelocity.dy *= -0.5
        }
        
        spherePosition = newPosition
        
        // Update rotation based on velocity
        let speed = sqrt(sphereVelocity.dx * sphereVelocity.dx + sphereVelocity.dy * sphereVelocity.dy)
        sphereRotation += speed * 2
    }
}

struct SphereBalanceView: View {
    let pitch: Double
    let roll: Double
    @Binding var spherePosition: CGPoint
    @Binding var sphereVelocity: CGVector
    @Binding var sphereRotation: Double
    let sphereRadius: CGFloat
    let platformSize: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 3D Platform (circular)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.8)],
                            center: .center,
                            startRadius: 0,
                            endRadius: platformSize / 2
                        )
                    )
                    .frame(width: platformSize, height: platformSize)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .rotation3DEffect(
                        .degrees(pitch),
                        axis: (x: 1, y: 0, z: 0)
                    )
                    .rotation3DEffect(
                        .degrees(-roll),
                        axis: (x: 0, y: 0, z: 1)
                    )
                    .shadow(radius: 10)
                
                // Target zone (center)
                Circle()
                    .stroke(Color.black.opacity(0.3), lineWidth: 1)
                    .frame(width: 40, height: 40)
                
                // Rolling sphere with :3 face
                ZStack {
                    // Sphere body
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color.gray.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: sphereRadius * 2, height: sphereRadius * 2)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .shadow(radius: 5)
                    
                    // :3 face
                    Text(":3")
                        .font(.system(size: sphereRadius * 0.8, weight: .bold))
                        .foregroundColor(.black)
                        .rotationEffect(.degrees(-sphereRotation))
                }
                .offset(x: spherePosition.x, y: spherePosition.y)
                .rotationEffect(.degrees(sphereRotation))
                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: spherePosition)
                
                // Shadow under sphere
                Ellipse()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: sphereRadius * 1.8, height: sphereRadius * 0.6)
                    .offset(x: spherePosition.x, y: spherePosition.y + sphereRadius + 10)
                    .blur(radius: 3)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct StatsView: View {
    @ObservedObject var balanceTracker: BalanceTracker
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }
            
            VStack(spacing: 20) {
                Text("Balance Statistics")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 15) {
                    StatRow(label: "Total Balances", value: "\(balanceTracker.totalBalances)")
                    StatRow(label: "Today's Balances", value: "\(balanceTracker.todayBalances)")
                    StatRow(label: "Best Streak", value: "\(balanceTracker.bestStreak)")
                    StatRow(label: "Current Streak", value: "\(balanceTracker.currentStreak)")
                    
                    if let lastBalance = balanceTracker.lastBalanceTime {
                        StatRow(label: "Last Balance", value: formatDate(lastBalance))
                    }
                    
                    if let firstBalance = balanceTracker.firstBalanceTime {
                        StatRow(label: "First Balance", value: formatDate(firstBalance))
                    }
                }
                .padding()
                
                Button(action: {
                    balanceTracker.resetStats()
                }) {
                    Text("Reset Stats")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    isShowing = false
                }) {
                    Text("Close")
                        .foregroundColor(.black)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(40)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
        .frame(minWidth: 200)
    }
}

struct OrientationDataView: View {
    let pitch: Double
    let roll: Double
    let yaw: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Orientation Data")
                .font(.headline)
                .foregroundColor(.black)
            
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
                .foregroundColor(.black)
                .frame(width: 60, alignment: .leading)
            
            Text(String(format: "%.1f", value) + unit)
                .foregroundColor(.gray)
                .monospacedDigit()
        }
    }
}

// MARK: - Balance Tracker

class BalanceTracker: ObservableObject {
    @Published var totalBalances: Int = 0
    @Published var todayBalances: Int = 0
    @Published var currentStreak: Int = 0
    @Published var bestStreak: Int = 0
    @Published var lastBalanceTime: Date?
    @Published var firstBalanceTime: Date?
    
    private let userDefaults = UserDefaults.standard
    private let totalKey = "catBalance.total"
    private let todayKey = "catBalance.today"
    private let todayDateKey = "catBalance.todayDate"
    private let streakKey = "catBalance.streak"
    private let bestStreakKey = "catBalance.bestStreak"
    private let lastBalanceKey = "catBalance.lastTime"
    private let firstBalanceKey = "catBalance.firstTime"
    private let lastStreakDateKey = "catBalance.lastStreakDate"
    
    init() {
        loadData()
        checkDayReset()
    }
    
    func recordBalance() {
        let now = Date()
        
        // Update totals
        totalBalances += 1
        todayBalances += 1
        lastBalanceTime = now
        
        // First balance ever
        if firstBalanceTime == nil {
            firstBalanceTime = now
        }
        
        // Update streak
        updateStreak()
        
        // Save data
        saveData()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastStreakDate = userDefaults.object(forKey: lastStreakDateKey) as? Date {
            let lastStreak = calendar.startOfDay(for: lastStreakDate)
            let daysDifference = calendar.dateComponents([.day], from: lastStreak, to: today).day ?? 0
            
            if daysDifference == 0 {
                // Same day, continue streak
                currentStreak = max(currentStreak, 1)
            } else if daysDifference == 1 {
                // Consecutive day
                currentStreak += 1
            } else {
                // Streak broken
                currentStreak = 1
            }
        } else {
            // First streak
            currentStreak = 1
        }
        
        userDefaults.set(today, forKey: lastStreakDateKey)
        
        // Update best streak
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }
    }
    
    private func checkDayReset() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let savedDate = userDefaults.object(forKey: todayDateKey) as? Date {
            let savedDay = calendar.startOfDay(for: savedDate)
            
            if savedDay != today {
                // New day, reset today's count
                todayBalances = 0
                userDefaults.set(today, forKey: todayDateKey)
            }
        } else {
            // First time
            userDefaults.set(today, forKey: todayDateKey)
        }
    }
    
    private func loadData() {
        totalBalances = userDefaults.integer(forKey: totalKey)
        todayBalances = userDefaults.integer(forKey: todayKey)
        currentStreak = userDefaults.integer(forKey: streakKey)
        bestStreak = userDefaults.integer(forKey: bestStreakKey)
        lastBalanceTime = userDefaults.object(forKey: lastBalanceKey) as? Date
        firstBalanceTime = userDefaults.object(forKey: firstBalanceKey) as? Date
    }
    
    private func saveData() {
        userDefaults.set(totalBalances, forKey: totalKey)
        userDefaults.set(todayBalances, forKey: todayKey)
        userDefaults.set(currentStreak, forKey: streakKey)
        userDefaults.set(bestStreak, forKey: bestStreakKey)
        userDefaults.set(lastBalanceTime, forKey: lastBalanceKey)
        userDefaults.set(firstBalanceTime, forKey: firstBalanceKey)
    }
    
    func resetStats() {
        totalBalances = 0
        todayBalances = 0
        currentStreak = 0
        bestStreak = 0
        lastBalanceTime = nil
        firstBalanceTime = nil
        
        // Clear UserDefaults
        userDefaults.removeObject(forKey: totalKey)
        userDefaults.removeObject(forKey: todayKey)
        userDefaults.removeObject(forKey: streakKey)
        userDefaults.removeObject(forKey: bestStreakKey)
        userDefaults.removeObject(forKey: lastBalanceKey)
        userDefaults.removeObject(forKey: firstBalanceKey)
        userDefaults.removeObject(forKey: lastStreakDateKey)
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

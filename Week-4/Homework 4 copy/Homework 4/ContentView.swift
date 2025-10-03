import SwiftUI

// Page 1: Timer Setup
struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Choose Timer Duration")
                    .font(.title)
                
                NavigationLink(destination: TimerPage(seconds: 60)) {
                    Text("1 Minute")
                        .frame(width: 200, height: 60)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: TimerPage(seconds: 180)) {
                    Text("3 Minutes")
                        .frame(width: 200, height: 60)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: TimerPage(seconds: 300)) {
                    Text("5 Minutes")
                        .frame(width: 200, height: 60)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Timer App")
        }
    }
}

// Page 2: Timer Countdown
struct TimerPage: View {
    let seconds: Int
    @State private var timeRemaining: Int = 0
    @State private var isActive = false
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 40) {
            Text(timeString(time: timeRemaining))
                .font(.system(size: 60, weight: .bold))
            
            HStack(spacing: 20) {
                Button(isActive ? "Pause" : "Start") {
                    if isActive {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }
                .frame(width: 120, height: 50)
                .background(isActive ? Color.orange : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Reset") {
                    stopTimer()
                    timeRemaining = seconds
                }
                .frame(width: 120, height: 50)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            if timeRemaining == 0 && !isActive {
                Text("Time's Up :333")
                    .font(.title)
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Timer")
        .onAppear {
            timeRemaining = seconds
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    func startTimer() {
        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
}

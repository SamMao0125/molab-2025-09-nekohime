import SwiftUI

struct ToastNotification: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            if isShowing {
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(25)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 50)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isShowing)
        .onChange(of: isShowing) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    isShowing = false
                }
            }
        }
    }
}

// Toast modifier for easy use
struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
            ToastNotification(message: message, isShowing: $isShowing)
        }
    }
}

extension View {
    func toast(message: String, isShowing: Binding<Bool>) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message))
    }
}

import SwiftUI

// MARK: - CameraControlsView
struct CameraControlsView: View {
    @Binding var isRecording: Bool
    let onPhotoCapture: () -> Void
    let onToggleRecording: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            // Photo button
            Button(action: onPhotoCapture) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Color.blue.opacity(0.8)))
                    .shadow(radius: 5)
            }
            .padding(.trailing, 20)
            
            // Video button
            Button(action: onToggleRecording) {
                Image(systemName: isRecording ? "stop.circle.fill" : "video.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(isRecording ? Color.red.opacity(0.8) : Color.blue.opacity(0.8)))
                    .shadow(radius: 5)
            }
            .padding(.trailing, 20)
        }
        .padding(.top, 60)
    }
}

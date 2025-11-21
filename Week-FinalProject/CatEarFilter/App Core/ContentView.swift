import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CameraView()  // CHANGED BACK to CameraView
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Camera")
                }
                .tag(0)
            
            PhotoLibraryView()
                .tabItem {
                    Image(systemName: "photo.fill")
                    Text("Library")
                }
                .tag(1)
        }
        .accentColor(.white)
    }
}

#Preview {
    ContentView()
}

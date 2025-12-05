import SwiftUI

struct PhotoEditorView: View {
    let image: UIImage
    
    @State private var faceDetector = VisionFaceDetector()
    @State private var faceManager = FaceManager()
    @State private var presetManager = PresetManager()
    
    @State private var showCustomization = false
    @State private var showFaceDetectionMessage = true
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isExporting = false
    @State private var exportProgress: Double = 0.0
    @State private var showUnsavedChangesAlert = false
    @State private var hasUnsavedChanges = false
    
    @State private var currentZoom: CGFloat = 1.0
    @State private var totalZoom: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @State private var totalOffset: CGSize = .zero
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            GeometryReader { geometry in
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(currentZoom * totalZoom)
                        .offset(
                            x: currentOffset.width + totalOffset.width,
                            y: currentOffset.height + totalOffset.height
                        )
                        .gesture(photoZoomGesture)
                        .gesture(photoPanGesture)
                    
                    if !faceDetector.isDetecting {
                        ForEach(faceManager.faces.indices, id: \.self) { index in
                            EarOverlayView(
                                face: $faceManager.faces[index],
                                isSelected: faceManager.selectedFaceId == faceManager.faces[index].id,
                                imageSize: geometry.size,
                                zoom: currentZoom * totalZoom,
                                offset: CGSize(
                                    width: currentOffset.width + totalOffset.width,
                                    height: currentOffset.height + totalOffset.height
                                ),
                                onSelect: {
                                    faceManager.selectFace(faceManager.faces[index].id)
                                },
                                onConfigChange: {
                                    hasUnsavedChanges = true
                                }
                            )
                        }
                    }
                    
                    if faceDetector.isDetecting {
                        LoadingView(message: "Detecting faces...")
                    }
                    
                    if faceDetector.detectionFailed && showFaceDetectionMessage && faceManager.faces.isEmpty {
                        VStack {
                            Spacer()
                            
                            HStack {
                                Text("No face detected - tap 'Add Ears' button to place manually")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(12)
                                
                                Button(action: {
                                    showFaceDetectionMessage = false
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }
                    }
                }
                .onAppear {
                    detectFaces(imageSize: geometry.size)
                }
            }
            
            VStack {
                HStack {
                    Button("Cancel") {
                        if hasUnsavedChanges {
                            showUnsavedChangesAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Faces: \(faceManager.faces.count)")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 12))
                    
                    Spacer()
                    
                    Button(action: {
                        addNewFace()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle")
                            Text("Add Ears")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    
                    Button("Export") {
                        exportImage()
                    }
                    .foregroundColor(.white)
                    .disabled(faceManager.faces.isEmpty)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                if faceManager.selectedFace != nil {
                    HStack(spacing: 20) {
                        Button(action: {
                            showCustomization.toggle()
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            resetEarPositions()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            if let selectedId = faceManager.selectedFaceId {
                                faceManager.removeFace(selectedId)
                                hasUnsavedChanges = true
                            }
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 24))
                                .foregroundColor(.red)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            
            if showCustomization,
               let selectedIndex = faceManager.faces.firstIndex(where: { $0.id == faceManager.selectedFaceId }) {
                CustomizationSheetWrapper(
                    config: faceManager.faces[selectedIndex].earConfig,
                    isPresented: $showCustomization,
                    onConfigChange: {
                        hasUnsavedChanges = true
                    }
                )
                .transition(.move(edge: .bottom))
            }
            
            if isExporting {
                ExportProgressView(progress: exportProgress)
            }
        }
        .toast(message: toastMessage, isShowing: $showToast)
        .alert("Unsaved Changes", isPresented: $showUnsavedChangesAlert) {
            Button("Discard", role: .destructive) {
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You have unsaved changes. Are you sure you want to leave?")
        }
        .navigationBarHidden(true)
    }
    
    private var photoZoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                currentZoom = value
            }
            .onEnded { value in
                totalZoom *= currentZoom
                currentZoom = 1.0
            }
    }
    
    private var photoPanGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                currentOffset = value.translation
            }
            .onEnded { value in
                totalOffset.width += currentOffset.width
                totalOffset.height += currentOffset.height
                currentOffset = .zero
            }
    }
    
    private func detectFaces(imageSize: CGSize) {
        print("🔍 Starting face detection...")
        
        faceDetector.detectFaces(in: image) {
            print("🔍 Detected faces: \(self.faceDetector.detectedFaces.count)")
            
            if !self.faceDetector.detectedFaces.isEmpty {
                for detectedFace in self.faceDetector.detectedFaces {
                    var faceWithEars = FaceWithEars(detectedFace: detectedFace)
                    faceWithEars.updateEarPositions(for: imageSize)
                    self.faceManager.faces.append(faceWithEars)
                    
                    print("🟢 Added face with ears at: \(faceWithEars.leftEarPosition), \(faceWithEars.rightEarPosition)")
                }
                
                self.faceManager.selectedFaceId = self.faceManager.faces.first?.id
                self.showFaceDetectionMessage = false
            } else {
                print("⚠️ No faces detected")
            }
        }
    }
    
    private func addNewFace() {
        let displaySize = UIScreen.main.bounds.size
        let centerX = displaySize.width / 2
        let centerY = displaySize.height / 2
        
        let newDetectedFace = DetectedFace(
            id: UUID(),
            boundingBox: CGRect(x: 0.45, y: 0.45, width: 0.1, height: 0.1),
            imageSize: displaySize,
            index: faceManager.faces.count
        )
        
        var newFace = FaceWithEars(detectedFace: newDetectedFace)
        newFace.leftEarPosition = CGPoint(x: centerX - 60, y: centerY - 100)
        newFace.rightEarPosition = CGPoint(x: centerX + 60, y: centerY - 100)
        
        faceManager.faces.append(newFace)
        faceManager.selectedFaceId = newFace.id
        hasUnsavedChanges = true
        
        toastMessage = "Ears added! Drag to position"
        showToast = true
    }
    
    private func resetEarPositions() {
        guard let selectedId = faceManager.selectedFaceId,
              let index = faceManager.faces.firstIndex(where: { $0.id == selectedId }) else { return }
        
        let displaySize = UIScreen.main.bounds.size
        let centerX = displaySize.width / 2
        let centerY = displaySize.height / 2
        
        faceManager.faces[index].leftEarPosition = CGPoint(x: centerX - 60, y: centerY - 100)
        faceManager.faces[index].rightEarPosition = CGPoint(x: centerX + 60, y: centerY - 100)
        
        toastMessage = "Positions reset"
        showToast = true
        hasUnsavedChanges = true
    }
    
    private func exportImage() {
        isExporting = true
        exportProgress = 0.0
        
        let exporter = ImageExporter()
        
        exporter.exportImage(
            baseImage: image,
            faces: faceManager.faces,
            progressHandler: { progress in
                exportProgress = progress
            },
            completion: { result in
                isExporting = false
                
                switch result {
                case .success(let exportedImage):
                    UIImageWriteToSavedPhotosAlbum(exportedImage, nil, nil, nil)
                    toastMessage = "Saved to Photos! 📸"
                    showToast = true
                    hasUnsavedChanges = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                    
                case .failure(let error):
                    toastMessage = "Export failed: \(error.localizedDescription)"
                    showToast = true
                }
            }
        )
    }
}

// Wrapper to properly observe @Observable class changes - iOS 16 compatible
struct CustomizationSheetWrapper: View {
    var config: EarConfiguration  // Remove @Bindable
    @Binding var isPresented: Bool
    let onConfigChange: () -> Void
    
    var body: some View {
        CustomizationSheet(
            config: Binding(
                get: { config },
                set: { _ in }
            ),
            isPresented: $isPresented,
            onSavePreset: {}
        )
        // iOS 16+ compatible onChange syntax
        .onChange(of: config.size) { _ in onConfigChange() }
        .onChange(of: config.scaleWidth) { _ in onConfigChange() }
        .onChange(of: config.scaleHeight) { _ in onConfigChange() }
        .onChange(of: config.leftRotation) { _ in onConfigChange() }
        .onChange(of: config.rightRotation) { _ in onConfigChange() }
        .onChange(of: config.outerColor.red) { _ in onConfigChange() }
        .onChange(of: config.outerColor.green) { _ in onConfigChange() }
        .onChange(of: config.outerColor.blue) { _ in onConfigChange() }
        .onChange(of: config.innerColor.red) { _ in onConfigChange() }
        .onChange(of: config.innerColor.green) { _ in onConfigChange() }
        .onChange(of: config.innerColor.blue) { _ in onConfigChange() }
    }
}

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.5)
            
            Text(message)
                .foregroundColor(.white)
                .font(.system(size: 14))
        }
        .padding(30)
        .background(Color.black.opacity(0.8))
        .cornerRadius(16)
    }
}

struct ExportProgressView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: progress, total: 1.0)
                .tint(.white)
                .frame(width: 200)
            
            Text("Exporting \(Int(progress * 100))%")
                .foregroundColor(.white)
                .font(.system(size: 14))
        }
        .padding(30)
        .background(Color.black.opacity(0.8))
        .cornerRadius(16)
    }
}

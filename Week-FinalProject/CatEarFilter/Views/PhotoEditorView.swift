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
    
    // Zoom and pan state
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
                    // Photo with zoom and pan
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
                    
                    // Ear overlays
                    if !faceDetector.isDetecting {
                        ForEach(faceManager.faces) { face in
                            EarOverlayView(
                                face: Binding(
                                    get: { face },
                                    set: { newFace in
                                        if let index = faceManager.faces.firstIndex(where: { $0.id == face.id }) {
                                            faceManager.faces[index] = newFace
                                        }
                                    }
                                ),
                                isSelected: faceManager.selectedFaceId == face.id,
                                imageSize: geometry.size,
                                zoom: currentZoom * totalZoom,
                                offset: CGSize(
                                    width: currentOffset.width + totalOffset.width,
                                    height: currentOffset.height + totalOffset.height
                                ),
                                onSelect: {
                                    faceManager.selectFace(face.id)
                                }
                            )
                        }
                    }
                    
                    // Face detection overlay
                    if faceDetector.isDetecting {
                        LoadingView(message: "Detecting faces...")
                    }
                    
                    if faceDetector.detectionFailed && showFaceDetectionMessage {
                        VStack {
                            Spacer()
                            
                            Text("No face detected - manual placement available")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(12)
                                .padding(.bottom, 100)
                                .onTapGesture {
                                    showFaceDetectionMessage = false
                                }
                        }
                    }
                }
                .onAppear {
                    detectFaces(imageSize: geometry.size)
                }
            }
            
            // Top toolbar
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
                    
                    if !faceManager.faces.isEmpty {
                        Button(action: {
                            addNewFace()
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button("Export") {
                        exportImage()
                    }
                    .foregroundColor(.white)
                    .disabled(faceManager.faces.isEmpty)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                
                Spacer()
            }
            
            // Bottom controls
            VStack {
                Spacer()
                
                if let selectedFace = faceManager.selectedFace {
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
                            faceManager.removeFace(selectedFace.id)
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
            
            // Customization sheet
            if showCustomization, let selectedFace = faceManager.selectedFace {
                CustomizationSheet(
                    config: Binding(
                        get: { selectedFace.earConfig },
                        set: { newConfig in
                            faceManager.updateEarConfiguration(for: selectedFace.id, config: newConfig)
                            hasUnsavedChanges = true
                        }
                    ),
                    isPresented: $showCustomization,
                    onSavePreset: {
                        // Save preset logic handled in sheet
                    }
                )
                .transition(.move(edge: .bottom))
            }
            
            // Export progress
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
        faceDetector.detectFaces(in: image) {
            if !faceDetector.detectedFaces.isEmpty {
                for detectedFace in faceDetector.detectedFaces {
                    var faceWithEars = FaceWithEars(detectedFace: detectedFace)
                    faceWithEars.updateEarPositions(for: imageSize)
                    faceManager.faces.append(faceWithEars)
                }
                
                faceManager.selectedFaceId = faceManager.faces.first?.id
                showFaceDetectionMessage = false
            }
        }
    }
    
    private func addNewFace() {
        // Add a new face with manual positioning
        let newDetectedFace = DetectedFace(
            id: UUID(),
            boundingBox: CGRect(x: 0.4, y: 0.4, width: 0.2, height: 0.2),
            imageSize: image.size,
            index: faceManager.faces.count
        )
        faceManager.addFace(newDetectedFace)
        hasUnsavedChanges = true
    }
    
    private func resetEarPositions() {
        guard let selectedFace = faceManager.selectedFace else { return }
        
        // Reset to auto-detected position if available
        toastMessage = "Positions reset to auto-detected values"
        showToast = true
    }
    
    private func exportImage() {
        isExporting = true
        exportProgress = 0.0
        
        // Use ImageExporter to combine image with ears
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
                    toastMessage = "Saved to Photos"
                    showToast = true
                    hasUnsavedChanges = false
                    
                    // Dismiss after short delay
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

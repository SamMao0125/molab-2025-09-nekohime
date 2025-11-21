import SwiftUI

struct PresetPickerOverlay: View {
    @Bindable var presetManager: PresetManager
    @Binding var isPresented: Bool
    let onSelectPreset: (EarConfiguration) -> Void
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Presets")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
                .padding()
                .background(Color.black)
                
                if presetManager.presets.isEmpty {
                    EmptyPresetsView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(presetManager.presets) { preset in
                                PresetThumbnailView(preset: preset)
                                    .onTapGesture {
                                        onSelectPreset(preset)
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            presetManager.deletePreset(preset)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
                
                // Storage info
                Text("Storage: \(presetManager.getTotalStorageSizeMB()) MB")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 8)
            }
            .background(Color.black)
            .cornerRadius(20)
            .padding()
        }
    }
}

struct PresetThumbnailView: View {
    let preset: EarConfiguration
    
    var body: some View {
        VStack(spacing: 8) {
            if let thumbnailData = preset.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(12)
            } else {
                // Fallback: show color preview
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(preset.outerColor.color)
                    
                    Image(systemName: "photo")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: 30))
                }
                .frame(width: 100, height: 100)
            }
            
            Text(preset.name)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(width: 100)
    }
}

struct EmptyPresetsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No Presets Saved")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
            
            Text("Customize your ears and save them as presets")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

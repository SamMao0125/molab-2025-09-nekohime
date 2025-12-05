import SwiftUI
import Photos
import PhotosUI

struct PhotoLibraryView: View {
    @State private var permissionManager = PermissionManager()
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var photoAssets: [PHAsset] = []
    
    // Better grid layout - 3 columns with spacing
    let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if permissionManager.photoLibraryAuthorized {
                    if photoAssets.isEmpty {
                        EmptyLibraryView()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 4) {
                                ForEach(photoAssets, id: \.localIdentifier) { asset in
                                    PhotoThumbnailView(asset: asset)
                                        .aspectRatio(1, contentMode: .fill)
                                        .cornerRadius(4)
                                        .onTapGesture {
                                            loadFullImage(asset: asset)
                                        }
                                }
                            }
                            .padding(4)
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Photo Library Access Required")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Please grant access to your photos in Settings")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Library")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedImage != nil },
                set: { if !$0 { selectedImage = nil } }
            )) {
                if let image = selectedImage {
                    PhotoEditorView(image: image)
                }
            }
            .onAppear {
                permissionManager.checkPhotoLibraryPermission()
                if permissionManager.photoLibraryAuthorized {
                    loadPhotoAssets()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func loadPhotoAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let results = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        photoAssets = []
        
        results.enumerateObjects { asset, _, _ in
            photoAssets.append(asset)
        }
    }
    
    private func loadFullImage(asset: PHAsset) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        // Request high quality image for editing
        let targetSize = CGSize(width: 2000, height: 2000)
        
        manager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            if let image = image {
                DispatchQueue.main.async {
                    selectedImage = image
                }
            }
        }
    }
}

struct PhotoThumbnailView: View {
    let asset: PHAsset
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                } else if isLoading {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                        
                        ProgressView()
                            .tint(.white)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.width)
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                        
                        Image(systemName: "photo")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(width: geometry.size.width, height: geometry.size.width)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        
        let size = CGSize(width: 300, height: 300)
        
        manager.requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: options
        ) { result, _ in
            DispatchQueue.main.async {
                image = result
                isLoading = false
            }
        }
    }
}

struct EmptyLibraryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No Photos")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Take some photos to get started!")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

#Preview {
    PhotoLibraryView()
}

import SwiftUI
import Photos
import PhotosUI

struct PhotoLibraryView: View {
    @State private var permissionManager = PermissionManager()
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var photoAssets: [PHAsset] = []
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 2)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if permissionManager.photoLibraryAuthorized {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(photoAssets, id: \.localIdentifier) { asset in
                                PhotoThumbnailView(asset: asset)
                                    .aspectRatio(1, contentMode: .fill)
                                    .onTapGesture {
                                        loadFullImage(asset: asset)
                                    }
                            }
                        }
                    }
                } else {
                    ProgressView()
                        .tint(.white)
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
        
        // Request image at screen size for editing (will export at full res later)
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
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        
        let size = CGSize(width: 200, height: 200)
        
        manager.requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: options
        ) { result, _ in
            DispatchQueue.main.async {
                image = result
            }
        }
    }
}

#Preview {
    PhotoLibraryView()
}

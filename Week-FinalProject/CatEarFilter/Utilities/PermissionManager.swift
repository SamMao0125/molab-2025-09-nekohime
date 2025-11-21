import SwiftUI
import AVFoundation
import Photos

@Observable
class PermissionManager {
    var cameraAuthorized = false
    var photoLibraryAuthorized = false
    var shouldRequestPermissions = true
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraAuthorized = true
        case .notDetermined:
            requestCameraPermission()
        case .denied, .restricted:
            cameraAuthorized = false
            // Don't exit immediately - give user a chance
            if shouldRequestPermissions {
                // Will re-check on next launch
                print("Camera permission denied")
            }
        @unknown default:
            cameraAuthorized = false
        }
    }
    
    func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            photoLibraryAuthorized = true
        case .notDetermined:
            requestPhotoLibraryPermission()
        case .denied, .restricted:
            photoLibraryAuthorized = false
            // Don't exit immediately
            if shouldRequestPermissions {
                print("Photo library permission denied")
            }
        @unknown default:
            photoLibraryAuthorized = false
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.cameraAuthorized = granted
            }
        }
    }
    
    private func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                self?.photoLibraryAuthorized = (status == .authorized || status == .limited)
            }
        }
    }
}

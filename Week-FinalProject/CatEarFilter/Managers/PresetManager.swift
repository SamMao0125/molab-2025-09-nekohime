import Foundation
import UIKit
import SwiftUI

@Observable
class PresetManager {
    var presets: [EarConfiguration] = []
    private let presetsFileName = "ear_presets.json"
    private let storageWarningThresholdMB: Int = 50
    
    init() {
        loadPresets()
    }
    
    var presetsDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("Presets")
    }
    
    private var presetsFileURL: URL {
        presetsDirectory.appendingPathComponent(presetsFileName)
    }
    
    func savePreset(_ config: EarConfiguration, thumbnail: UIImage?) {
        // Generate thumbnail data if provided
        if let thumbnail = thumbnail {
            config.thumbnailData = thumbnail.jpegData(compressionQuality: 0.7)
        }
        
        presets.append(config)
        savePresets()
        checkStorageSize()
    }
    
    func updatePreset(_ config: EarConfiguration) {
        if let index = presets.firstIndex(where: { $0.id == config.id }) {
            presets[index] = config
            savePresets()
        }
    }
    
    func deletePreset(_ config: EarConfiguration) {
        presets.removeAll { $0.id == config.id }
        savePresets()
    }
    
    func deletePreset(at indexSet: IndexSet) {
        presets.remove(atOffsets: indexSet)
        savePresets()
    }
    
    private func savePresets() {
        do {
            // Create directory if it doesn't exist
            try FileManager.default.createDirectory(at: presetsDirectory, withIntermediateDirectories: true)
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(presets)
            try data.write(to: presetsFileURL)
        } catch {
            print("Error saving presets: \(error)")
        }
    }
    
    private func loadPresets() {
        do {
            guard FileManager.default.fileExists(atPath: presetsFileURL.path) else {
                return
            }
            
            let data = try Data(contentsOf: presetsFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            presets = try decoder.decode([EarConfiguration].self, from: data)
            
            // Sort by date created (newest first)
            presets.sort { $0.createdDate > $1.createdDate }
        } catch {
            print("Error loading presets: \(error)")
            presets = []
        }
    }
    
    private func checkStorageSize() {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: presetsFileURL.path)
            if let fileSize = attributes[.size] as? Int {
                let fileSizeMB = fileSize / (1024 * 1024)
                if fileSizeMB > storageWarningThresholdMB {
                    // Post notification about storage warning
                    NotificationCenter.default.post(
                        name: NSNotification.Name("StorageWarning"),
                        object: nil,
                        userInfo: ["sizeMB": fileSizeMB]
                    )
                }
            }
        } catch {
            print("Error checking storage size: \(error)")
        }
    }
    
    func getTotalStorageSizeMB() -> Int {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: presetsFileURL.path)
            if let fileSize = attributes[.size] as? Int {
                return fileSize / (1024 * 1024)
            }
        } catch {
            // File might not exist yet
            return 0
        }
        return 0
    }
}

import Foundation
import AppKit
import SwiftUI

/// Represents a captured exercise photo
struct ExercisePhoto: Identifiable {
    let id = UUID()
    let repNumber: Int
    let position: Position
    let image: NSImage
    let timestamp: Date

    enum Position: String {
        case sitting = "Sitting"
        case standing = "Standing"
    }

    var filename: String {
        "rep\(repNumber)_\(position.rawValue.lowercased()).png"
    }
}

/// Manages photos captured during an exercise session
class SessionPhotoManager: ObservableObject {
    @Published var photos: [ExercisePhoto] = []
    @Published var sessionStartTime: Date?

    private var sessionDirectory: URL?

    /// Start a new session
    func startSession() {
        photos.removeAll()
        sessionStartTime = Date()

        // Create session directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sessionsPath = documentsPath.appendingPathComponent("XtremePomodoro/Sessions", isDirectory: true)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let sessionName = formatter.string(from: sessionStartTime!)

        sessionDirectory = sessionsPath.appendingPathComponent(sessionName, isDirectory: true)

        try? FileManager.default.createDirectory(at: sessionDirectory!, withIntermediateDirectories: true)
    }

    /// Capture and store a photo
    func capturePhoto(image: CGImage, repNumber: Int, position: ExercisePhoto.Position) {
        let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))

        let photo = ExercisePhoto(
            repNumber: repNumber,
            position: position,
            image: nsImage,
            timestamp: Date()
        )

        DispatchQueue.main.async {
            self.photos.append(photo)
        }

        // Save to disk
        savePhotoToDisk(photo)
    }

    private func savePhotoToDisk(_ photo: ExercisePhoto) {
        guard let sessionDirectory = sessionDirectory else { return }

        let fileURL = sessionDirectory.appendingPathComponent(photo.filename)

        if let tiffData = photo.image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            try? pngData.write(to: fileURL)
        }
    }

    /// Clear current session photos (from memory, not disk)
    func clearSession() {
        photos.removeAll()
        sessionStartTime = nil
        sessionDirectory = nil
    }

    /// Get photos for a specific rep
    func photosForRep(_ repNumber: Int) -> [ExercisePhoto] {
        photos.filter { $0.repNumber == repNumber }
    }

    /// Get the session folder path
    var sessionPath: String? {
        sessionDirectory?.path
    }
}

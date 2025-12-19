import SwiftUI
import AppKit

/// Detailed view of a single pomodoro session with journal and photos
struct SessionDetailView: View {
    let session: PomodoroSession
    @ObservedObject var sessionStore: SessionStore
    @Binding var navigationPath: NavigationPath

    @State private var journalText: String = ""
    @State private var isEditingJournal: Bool = false
    @State private var loadedPhotos: [LoadedPhoto] = []

    struct LoadedPhoto: Identifiable {
        let id = UUID()
        let repNumber: Int
        let position: String
        let image: NSImage
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                Button(action: { navigationPath.removeLast() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)

                Spacer()

                // Status badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)
                    Text(statusText)
                        .font(.subheadline)
                        .foregroundColor(statusColor)
                }

                Spacer()

                // Placeholder for symmetry
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .opacity(0)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Session info header
                    sessionHeader

                    Divider()

                    // Photos section
                    photosSection

                    Divider()

                    // Journal section
                    journalSection
                }
                .padding()
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            journalText = session.journalEntry ?? ""
            loadPhotosFromDisk()
        }
    }

    private var sessionHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack(spacing: 16) {
                        Label(session.timeString, systemImage: "clock")
                        Label("\(session.durationMinutes) min", systemImage: "timer")
                        Label(exerciseName, systemImage: exerciseIcon)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }

                Spacer()

                // Large status indicator
                VStack {
                    Image(systemName: statusIcon)
                        .font(.system(size: 36))
                        .foregroundColor(statusColor)
                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(statusColor)
                }
                .padding()
                .background(statusColor.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Exercise Photos", systemImage: "photo.on.rectangle.angled")
                    .font(.headline)

                Spacer()

                if let path = session.photoSessionPath {
                    Button("Open Folder") {
                        NSWorkspace.shared.open(URL(fileURLWithPath: path))
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                }
            }

            if loadedPhotos.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)

                    Text("No photos available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            } else {
                // Group photos by rep number
                let repNumbers = Set(loadedPhotos.map { $0.repNumber }).sorted()

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(repNumbers, id: \.self) { repNumber in
                        let repPhotos = loadedPhotos.filter { $0.repNumber == repNumber }
                        ForEach(repPhotos) { photo in
                            DetailPhotoCard(photo: photo)
                        }
                    }
                }
            }
        }
    }

    private var journalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Journal", systemImage: "note.text")
                    .font(.headline)

                Spacer()

                if isEditingJournal {
                    Button("Cancel") {
                        journalText = session.journalEntry ?? ""
                        isEditingJournal = false
                    }
                    .buttonStyle(.bordered)

                    Button("Save") {
                        let entry = journalText.trimmingCharacters(in: .whitespacesAndNewlines)
                        sessionStore.updateJournal(for: session.id, entry: entry.isEmpty ? nil : entry)
                        isEditingJournal = false
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Edit") {
                        isEditingJournal = true
                    }
                    .buttonStyle(.bordered)
                }
            }

            if isEditingJournal {
                TextEditor(text: $journalText)
                    .font(.body)
                    .frame(minHeight: 100, maxHeight: 200)
                    .padding(8)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else if let journal = session.journalEntry, !journal.isEmpty {
                Text(journal)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
            } else {
                Text("No journal entry for this session")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
            }
        }
    }

    // MARK: - Computed Properties

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: session.startTime)
    }

    private var exerciseName: String {
        switch session.exerciseType {
        case "sitToStand": return "Sit-to-Stand"
        case "squats": return "Squats"
        case "jumpingJacks": return "Jumping Jacks"
        case "armRaises": return "Arm Raises"
        default: return session.exerciseType
        }
    }

    private var exerciseIcon: String {
        switch session.exerciseType {
        case "sitToStand": return "figure.stand"
        case "squats": return "figure.strengthtraining.traditional"
        case "jumpingJacks": return "figure.jumprope"
        case "armRaises": return "figure.arms.open"
        default: return "figure.walk"
        }
    }

    private var statusColor: Color {
        switch session.status {
        case .completed: return .green
        case .cancelled: return .red
        case .inProgress: return .gray
        }
    }

    private var statusText: String {
        switch session.status {
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .inProgress: return "In Progress"
        }
    }

    private var statusIcon: String {
        switch session.status {
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        case .inProgress: return "clock.fill"
        }
    }

    private func loadPhotosFromDisk() {
        guard let path = session.photoSessionPath else { return }

        let fileManager = FileManager.default
        let folderURL = URL(fileURLWithPath: path)

        guard fileManager.fileExists(atPath: path) else { return }

        do {
            let files = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            let pngFiles = files.filter { $0.pathExtension.lowercased() == "png" }

            loadedPhotos = pngFiles.compactMap { fileURL -> LoadedPhoto? in
                guard let image = NSImage(contentsOf: fileURL) else { return nil }

                // Parse filename: rep1_sitting.png or rep1_standing.png
                let filename = fileURL.deletingPathExtension().lastPathComponent
                let parts = filename.split(separator: "_")
                guard parts.count >= 2,
                      let repNumber = Int(parts[0].dropFirst(3)) else {
                    return nil
                }

                let position = String(parts[1])
                return LoadedPhoto(repNumber: repNumber, position: position, image: image)
            }
            .sorted { $0.repNumber < $1.repNumber }
        } catch {
            print("Error loading photos: \(error)")
        }
    }
}

/// Photo card for detail view
struct DetailPhotoCard: View {
    let photo: SessionDetailView.LoadedPhoto

    var body: some View {
        VStack(spacing: 8) {
            Image(nsImage: photo.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 200)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 2)
                )

            HStack {
                Circle()
                    .fill(borderColor)
                    .frame(width: 8, height: 8)

                Text("Rep \(photo.repNumber) - \(photo.position.capitalized)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var borderColor: Color {
        photo.position.lowercased() == "sitting" ? .blue : .green
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var path = NavigationPath()

        var body: some View {
            NavigationStack(path: $path) {
                SessionDetailView(
                    session: PomodoroSession(
                        startTime: Date().addingTimeInterval(-25 * 60),
                        exerciseType: "sitToStand",
                        journalEntry: "Worked on the new feature implementation",
                        status: .completed
                    ),
                    sessionStore: SessionStore(),
                    navigationPath: $path
                )
            }
        }
    }

    return PreviewWrapper()
}

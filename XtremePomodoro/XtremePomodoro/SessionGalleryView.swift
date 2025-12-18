import SwiftUI

/// Gallery view displaying photos from the current exercise session
struct SessionGalleryView: View {
    @ObservedObject var photoManager: SessionPhotoManager
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Session Gallery")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                if let startTime = photoManager.sessionStartTime {
                    Text(startTime, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            if photoManager.photos.isEmpty {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No photos yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Photos will appear here as you complete reps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    // Group photos by rep number
                    let repNumbers = Set(photoManager.photos.map { $0.repNumber }).sorted()

                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(repNumbers, id: \.self) { repNumber in
                            RepPhotoSection(
                                repNumber: repNumber,
                                photos: photoManager.photosForRep(repNumber)
                            )
                        }
                    }
                    .padding()
                }
            }

            Divider()

            // Footer with stats
            HStack {
                Text("\(photoManager.photos.count) photos")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let avgScore = photoManager.averageScore {
                    Text("|")
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Text("Avg Score:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(avgScore)%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(avgScoreColor(avgScore))
                    }
                }

                Spacer()

                if let path = photoManager.sessionPath {
                    Button("Open Folder") {
                        NSWorkspace.shared.open(URL(fileURLWithPath: path))
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                }
            }
            .padding()
        }
        .frame(minWidth: 900, minHeight: 600)
    }

    private func avgScoreColor(_ score: Int) -> Color {
        switch score {
        case 90...100: return .green
        case 70..<90: return .blue
        case 50..<70: return .orange
        default: return .red
        }
    }
}

/// Section showing photos for a single rep
struct RepPhotoSection: View {
    let repNumber: Int
    let photos: [ExercisePhoto]

    var repScore: Int? {
        photos.compactMap { $0.score }.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Rep \(repNumber)")
                    .font(.headline)
                    .foregroundColor(.blue)

                if let score = repScore {
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Score:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(score)%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(scoreColor(score))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(scoreColor(score).opacity(0.15))
                    .cornerRadius(8)
                }
            }

            HStack(spacing: 12) {
                ForEach(photos.sorted(by: { $0.position.rawValue < $1.position.rawValue })) { photo in
                    PhotoCard(photo: photo)
                }
            }
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 90...100: return .green
        case 70..<90: return .blue
        case 50..<70: return .orange
        default: return .red
        }
    }
}

/// Card displaying a single photo
struct PhotoCard: View {
    let photo: ExercisePhoto
    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 8) {
            Image(nsImage: photo.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 400, maxHeight: 300)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 3)
                )
                .shadow(radius: isHovering ? 6 : 3)
                .scaleEffect(isHovering ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isHovering)
                .onHover { hovering in
                    isHovering = hovering
                }

            HStack {
                Circle()
                    .fill(borderColor)
                    .frame(width: 10, height: 10)
                Text(photo.position.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var borderColor: Color {
        photo.position == .sitting ? .blue : .green
    }
}

#Preview {
    SessionGalleryView(photoManager: SessionPhotoManager())
}

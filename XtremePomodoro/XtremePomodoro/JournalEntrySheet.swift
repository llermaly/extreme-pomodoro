import SwiftUI

/// Sheet displayed after completing a pomodoro session to capture journal notes
struct JournalEntrySheet: View {
    @Binding var isPresented: Bool
    let session: PomodoroSession
    let onSave: (String?) -> Void

    @State private var journalText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.green)

                Text("Session Complete!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("What did you accomplish?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Journal entry
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick note (optional)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextEditor(text: $journalText)
                    .font(.body)
                    .frame(minHeight: 120, maxHeight: 200)
                    .padding(8)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .focused($isTextFieldFocused)
            }

            // Session info
            HStack(spacing: 16) {
                Label(session.timeString, systemImage: "clock")
                Label("\(session.durationMinutes) min", systemImage: "timer")
            }
            .font(.caption)
            .foregroundColor(.secondary)

            // Buttons
            HStack(spacing: 16) {
                Button("Skip") {
                    onSave(nil)
                    isPresented = false
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.escape)

                Button("Save") {
                    let entry = journalText.trimmingCharacters(in: .whitespacesAndNewlines)
                    onSave(entry.isEmpty ? nil : entry)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return)
            }
        }
        .padding(32)
        .frame(width: 400)
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

#Preview {
    JournalEntrySheet(
        isPresented: .constant(true),
        session: PomodoroSession(
            startTime: Date().addingTimeInterval(-25 * 60),
            exerciseType: "sitToStand"
        ),
        onSave: { _ in }
    )
}

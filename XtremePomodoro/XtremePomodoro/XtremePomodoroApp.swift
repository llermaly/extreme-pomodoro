import SwiftUI

@main
struct XtremePomodoroApp: App {
    @StateObject private var cameraManager = OBSBOTManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cameraManager)
        }
    }
}

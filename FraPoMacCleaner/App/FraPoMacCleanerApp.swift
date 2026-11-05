import SwiftUI

@main
struct FraPoMacCleanerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(dependencies: .live)
        }
        .defaultSize(width: 960, height: 640)

        Settings {
            SettingsView()
        }
    }
}

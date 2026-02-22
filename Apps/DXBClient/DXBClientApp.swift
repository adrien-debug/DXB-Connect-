import SwiftUI
import DXBCore

@main
struct DXBClientApp: App {
    init() {
        APIConfig.current = .production
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

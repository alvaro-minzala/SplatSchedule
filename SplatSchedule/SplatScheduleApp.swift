import SwiftUI

@main
struct SplatScheduleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
#if os(macOS)
                .frame(minWidth: 900, minHeight: 600)
#endif
        }
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
#endif
    }
}

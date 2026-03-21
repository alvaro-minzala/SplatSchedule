#if !os(macOS)
import SwiftUI

struct iOS_RootView: View {
    @StateObject private var service = ScheduleService()

    var body: some View {
        TabView {
            iOS_ModeView(mode: .turfWar, service: service)
                .tabItem { Label("Turf War", systemImage: "paintbrush.fill") }

            iOS_ModeView(mode: .anarchyOpen, service: service)
                .tabItem { Label("Anarchy Open", systemImage: "flame.fill") }

            iOS_ModeView(mode: .anarchySeries, service: service)
                .tabItem { Label("Anarchy Series", systemImage: "trophy.fill") }

            iOS_ModeView(mode: .xBattle, service: service)
                .tabItem { Label("X Battle", systemImage: "bolt.fill") }

            iOS_SalmonView(service: service)
                .tabItem { Label("Salmon Run", systemImage: "fish.fill") }

            iOS_AboutView()
                .tabItem { Label("About", systemImage: "info.circle.fill") }
        }
        .preferredColorScheme(.dark)
    }
}
#endif

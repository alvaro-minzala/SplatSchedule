import SwiftUI

// MARK: - Entry point — routes to platform-specific root

struct ContentView: View {
    var body: some View {
        #if os(macOS)
        macOSRoot
        #else
        iOS_RootView()
        #endif
    }

    #if os(macOS)
    @StateObject private var service = ScheduleService()
    @State private var destination: NavDestination = .mode(.turfWar)

    var macOSRoot: some View {
        HStack(spacing: 0) {
            SidebarView(destination: $destination, service: service)
                .frame(width: 220)
            Divider()
            macOSDestination
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(alignment: .topTrailing) {
            if destination != .about {
                macOSStatusBar.padding(16)
            }
        }
    }

    @ViewBuilder
    var macOSDestination: some View {
        switch destination {
        case .mode(let mode): ModeScheduleView(mode: mode, service: service)
        case .salmonRun:      SalmonRunView(service: service)
        case .about:          AboutView()
        }
    }

    var macOSStatusBar: some View {
        HStack(spacing: 6) {
            if service.isLoading {
                ProgressView().scaleEffect(0.6).frame(width: 14, height: 14)
            } else if service.lastUpdated != nil {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).font(.system(size: 11))
            }
            Button { Task { await service.fetchAll() } } label: {
                Image(systemName: "arrow.clockwise").font(.system(size: 11, weight: .semibold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
    #endif
}


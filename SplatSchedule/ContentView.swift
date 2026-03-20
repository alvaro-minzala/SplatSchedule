import SwiftUI

enum NavDestination: Equatable {
    case mode(GameMode)
    case salmonRun
    case about
}

struct ContentView: View {
    @StateObject private var service = ScheduleService()
    @State private var destination: NavDestination = .mode(.turfWar)

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(destination: $destination, service: service)
                .frame(width: 220)

            Divider()

            switch destination {
            case .mode(let mode):
                ModeScheduleView(mode: mode, service: service)
            case .salmonRun:
                SalmonRunView(service: service)
            case .about:
                AboutView()
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(alignment: .topTrailing) {
            if destination != .about {
                StatusBar(service: service)
                    .padding(16)
            }
        }
    }
}

struct StatusBar: View {
    @ObservedObject var service: ScheduleService

    var body: some View {
        HStack(spacing: 8) {
            if service.isLoading {
                ProgressView()
                    .scaleEffect(0.6)
                    .frame(width: 14, height: 14)
                Text("Updating...")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            } else if let updated = service.lastUpdated {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 11))
                Text("Updated \(updated, style: .relative) ago")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Button {
                Task { await service.fetchAll() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 11, weight: .semibold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

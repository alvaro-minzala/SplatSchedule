import SwiftUI

struct ContentView: View {
    @StateObject private var service = ScheduleService()
    @State private var selectedMode: GameMode = .turfWar
    @State private var showAbout = false

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            SidebarView(selectedMode: $selectedMode, showAbout: $showAbout, service: service)
                .frame(width: 220)

            Divider()

            // Main Content
            if showAbout {
                AboutView()
            } else {
                ModeScheduleView(mode: selectedMode, service: service)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(alignment: .topTrailing) {
            if !showAbout {
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

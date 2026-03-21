#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
enum NavDestination: Hashable {
    case mode(GameMode)
    case salmonRun
    case about
}
#endif

import SwiftUI

struct SidebarView: View {
    @Binding var destination: NavDestination
    @ObservedObject var service: ScheduleService

    var body: some View {
#if os(macOS)
        macOSSidebar
#else
        iOSList
#endif
    }

    // MARK: - macOS sidebar (fixed panel)
#if os(macOS)
    var macOSSidebar: some View {
        VStack(spacing: 0) {
            // App Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "#C8E645"), Color(hex: "#F54910")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 36, height: 36)
                    Text("🦑").font(.system(size: 18))
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("Splat").font(.system(size: 17, weight: .black, design: .rounded)).foregroundStyle(.primary)
                    + Text("Schedule").font(.system(size: 17, weight: .black, design: .rounded)).foregroundStyle(Color(hex: "#C8E645"))
                    Text("Splatoon 3").font(.system(size: 10, weight: .medium)).foregroundStyle(.tertiary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Divider().padding(.horizontal, 12)

            VStack(alignment: .leading, spacing: 2) {
                SectionLabel("BATTLE MODES").padding(.top, 12).padding(.bottom, 4)
                ForEach(GameMode.allCases.filter { $0 != .salmonRun }) { mode in
                    MacSidebarRow(mode: mode, isSelected: destination == .mode(mode), slots: service.scheduleSlots[mode] ?? [])
                        .onTapGesture { destination = .mode(mode) }
                }
            }
            .padding(.horizontal, 8)

            Divider().padding(.horizontal, 12).padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 2) {
                SectionLabel("CO-OP").padding(.bottom, 4)
                MacSalmonRow(isSelected: destination == .salmonRun, slots: service.coopSlots)
                    .onTapGesture { destination = .salmonRun }
            }
            .padding(.horizontal, 8)

            Divider().padding(.horizontal, 12).padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 2) {
                MacAboutRow(isSelected: destination == .about)
                    .onTapGesture { destination = .about }
            }
            .padding(.horizontal, 8)

            Spacer()
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
#endif

    // MARK: - iOS/iPadOS list (NavigationStack rows)
#if !os(macOS)
    var iOSList: some View {
        List {
            Section("Battle Modes") {
                ForEach(GameMode.allCases.filter { $0 != .salmonRun }) { mode in
                    NavigationLink(value: NavDestination.mode(mode)) {
                        IOSSidebarRow(
                            emoji: modeEmoji(mode),
                            title: mode.rawValue,
                            subtitle: (service.scheduleSlots[mode] ?? []).first(where: \.isActive)?.ruleName,
                            accentHex: mode.accentColor,
                            isActive: (service.scheduleSlots[mode] ?? []).contains(where: \.isActive)
                        )
                    }
                }
            }
            Section("Co-op") {
                NavigationLink(value: NavDestination.salmonRun) {
                    IOSSidebarRow(
                        emoji: "🐻",
                        title: "Salmon Run",
                        subtitle: service.coopSlots.first(where: \.isActive)?.stageName
                            ?? service.coopSlots.first?.stageName,
                        accentHex: "#FF6B1A",
                        isActive: service.coopSlots.contains(where: \.isActive)
                    )
                }
            }
            Section {
                NavigationLink(value: NavDestination.about) {
                    IOSSidebarRow(emoji: "ℹ️", title: "About", subtitle: nil, accentHex: "#888888", isActive: false)
                }
            }
        }
        .listStyle(.insetGrouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func modeEmoji(_ mode: GameMode) -> String {
        switch mode {
        case .turfWar: return "🎨"
        case .anarchyOpen: return "🔥"
        case .anarchySeries: return "🏆"
        case .xBattle: return "⚡️"
        case .salmonRun: return "🐻"
        }
    }
#endif
}

// MARK: - iOS Row

#if !os(macOS)
struct IOSSidebarRow: View {
    let emoji: String
    let title: String
    let subtitle: String?
    let accentHex: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: accentHex).opacity(0.15))
                    .frame(width: 36, height: 36)
                Text(emoji).font(.system(size: 18))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .semibold))
                if let sub = subtitle {
                    Text(sub).font(.system(size: 12)).foregroundStyle(Color(hex: accentHex))
                }
            }
            Spacer()
            if isActive {
                Circle().fill(Color(hex: accentHex)).frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
}
#endif

// MARK: - macOS Rows

#if os(macOS)
struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text).font(.system(size: 10, weight: .semibold)).foregroundStyle(.tertiary).padding(.horizontal, 8)
    }
}

struct MacSidebarRow: View {
    let mode: GameMode
    let isSelected: Bool
    let slots: [ScheduleSlot]
    @State private var isHovered = false

    var activeSlot: ScheduleSlot? { slots.first(where: \.isActive) }
    var modeEmoji: String {
        switch mode {
        case .turfWar: return "🎨"
        case .anarchyOpen: return "🔥"
        case .anarchySeries: return "🏆"
        case .xBattle: return "⚡️"
        case .salmonRun: return "🐻"
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: mode.accentColor).opacity(isSelected ? 1 : 0.15))
                    .frame(width: 28, height: 28)
                Text(modeEmoji).font(.system(size: 14))
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(mode.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)
                if let active = activeSlot {
                    Text(active.ruleName).font(.system(size: 10, weight: .medium)).foregroundStyle(Color(hex: mode.accentColor))
                } else {
                    Text("No active rotation").font(.system(size: 10)).foregroundStyle(.quaternary)
                }
            }
            Spacer()
            if activeSlot != nil { Circle().fill(Color(hex: mode.accentColor)).frame(width: 6, height: 6) }
        }
        .padding(.horizontal, 8).padding(.vertical, 7)
        .background(RoundedRectangle(cornerRadius: 8).fill(
            isSelected ? Color(hex: mode.accentColor).opacity(0.1) :
            isHovered  ? Color.primary.opacity(0.04) : Color.clear
        ))
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
    }
}

struct MacSalmonRow: View {
    let isSelected: Bool
    let slots: [CoopSlot]
    @State private var isHovered = false
    var activeSlot: CoopSlot? { slots.first(where: \.isActive) }
    let accent = Color(hex: "#FF6B1A")

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(accent.opacity(isSelected ? 1 : 0.15))
                    .frame(width: 28, height: 28)
                Text("🐻").font(.system(size: 14))
            }
            VStack(alignment: .leading, spacing: 1) {
                Text("Salmon Run")
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)
                if let active = activeSlot {
                    Text(active.stageName).font(.system(size: 10, weight: .medium)).foregroundStyle(accent)
                } else if let next = slots.first {
                    Text(next.stageName).font(.system(size: 10)).foregroundStyle(.quaternary)
                }
            }
            Spacer()
            if activeSlot != nil { Circle().fill(accent).frame(width: 6, height: 6) }
        }
        .padding(.horizontal, 8).padding(.vertical, 7)
        .background(RoundedRectangle(cornerRadius: 8).fill(
            isSelected ? accent.opacity(0.1) :
            isHovered  ? Color.primary.opacity(0.04) : Color.clear
        ))
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
    }
}

struct MacAboutRow: View {
    let isSelected: Bool
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(isSelected ? 0.3 : 0.1))
                    .frame(width: 28, height: 28)
                Image(systemName: "info.circle.fill").font(.system(size: 14)).foregroundStyle(.secondary)
            }
            Text("About")
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .primary : .secondary)
            Spacer()
        }
        .padding(.horizontal, 8).padding(.vertical, 7)
        .background(RoundedRectangle(cornerRadius: 8).fill(
            isSelected ? Color.primary.opacity(0.07) :
            isHovered  ? Color.primary.opacity(0.04) : Color.clear
        ))
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
    }
}
#endif

// MARK: - Color hex extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

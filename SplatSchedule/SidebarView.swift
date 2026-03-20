import SwiftUI

struct SidebarView: View {
    @Binding var selectedMode: GameMode
    @Binding var showAbout: Bool
    @ObservedObject var service: ScheduleService

    var body: some View {
        VStack(spacing: 0) {
            // App Header
            VStack(spacing: 4) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color(hex: "#C8E645"), Color(hex: "#F54910")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 36, height: 36)
                        Text("🦑")
                            .font(.system(size: 18))
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Splat")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                        + Text("Schedule")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(Color(hex: "#C8E645"))
                        Text("v0.1a")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Divider()
                .padding(.horizontal, 12)

            // Battle Modes
            VStack(alignment: .leading, spacing: 2) {
                SectionLabel("BATTLE MODES")
                    .padding(.top, 12)
                    .padding(.bottom, 4)

                ForEach(GameMode.allCases) { mode in
                    SidebarRow(
                        mode: mode,
                        isSelected: !showAbout && selectedMode == mode,
                        slots: service.scheduleSlots[mode] ?? []
                    )
                    .onTapGesture {
                        showAbout = false
                        selectedMode = mode
                    }
                }
            }
            .padding(.horizontal, 8)

            Divider()
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            // About
            VStack(alignment: .leading, spacing: 2) {
                AboutSidebarRow(isSelected: showAbout)
                    .onTapGesture { showAbout = true }
            }
            .padding(.horizontal, 8)

            Spacer()
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.tertiary)
            .padding(.horizontal, 8)
    }
}

struct SidebarRow: View {
    let mode: GameMode
    let isSelected: Bool
    let slots: [ScheduleSlot]
    @State private var isHovered = false

    var activeSlot: ScheduleSlot? { slots.first(where: \.isActive) }

    var body: some View {
        HStack(spacing: 10) {
            // Mode color dot
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: mode.accentColor).opacity(isSelected ? 1 : 0.15))
                    .frame(width: 28, height: 28)
                Text(modeEmoji)
                    .font(.system(size: 14))
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(mode.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)

                if let active = activeSlot {
                    Text(active.ruleName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(hex: mode.accentColor))
                } else {
                    Text("No active rotation")
                        .font(.system(size: 10))
                        .foregroundStyle(.quaternary)
                }
            }

            Spacer()

            if let _ = activeSlot {
                Circle()
                    .fill(Color(hex: mode.accentColor))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color(hex: mode.accentColor).opacity(0.1) :
                      isHovered ? Color.primary.opacity(0.04) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
    }

    var modeEmoji: String {
        switch mode {
        case .turfWar: return "🎨"
        case .anarchyOpen: return "🔥"
        case .anarchySeries: return "🏆"
        case .xBattle: return "⚡️"
        }
    }
}

struct AboutSidebarRow: View {
    let isSelected: Bool
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(isSelected ? 0.3 : 0.1))
                    .frame(width: 28, height: 28)
                Text("🦊")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }

            Text("About")
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .primary : .secondary)

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.primary.opacity(0.07) :
                      isHovered ? Color.primary.opacity(0.04) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

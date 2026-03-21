#if !os(macOS)
import SwiftUI

struct iOS_ModeView: View {
    let mode: GameMode
    @ObservedObject var service: ScheduleService

    var accent: Color { Color(hex: mode.accentColor) }

    var slots: [ScheduleSlot] {
        (service.scheduleSlots[mode] ?? []).sorted { $0.startTime < $1.startTime }
    }
    var active: ScheduleSlot? { slots.first(where: \.isActive) }
    var upcoming: [ScheduleSlot] { slots.filter { !$0.isActive } }

    var modeDescription: String {
        switch mode {
        case .turfWar:       return "Paint the most turf to win!"
        case .anarchyOpen:   return "Casual ranked — team up with friends"
        case .anarchySeries: return "Competitive series — fight for your rating"
        case .xBattle:       return "Top-tier ranked play for the elite"
        case .salmonRun:     return "Co-op wave defense!"
        }
    }

    var modeEmoji: String {
        switch mode {
        case .turfWar:       return "🎨"
        case .anarchyOpen:   return "🔥"
        case .anarchySeries: return "🏆"
        case .xBattle:       return "⚡️"
        case .salmonRun:     return "🐻"
        }
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // ── Header ──
                    iOS_ModeHeader(
                        emoji: modeEmoji,
                        title: mode.rawValue,
                        description: modeDescription,
                        accent: accent,
                        rotationCount: slots.count
                    )

                    // ── Content ──
                    VStack(spacing: 0) {
                        if service.isLoading && slots.isEmpty {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)
                        } else {
                            if let active {
                                iOS_SectionHeader(
                                    title: "Now Playing",
                                    systemImage: "play.circle.fill",
                                    color: accent
                                )
                                .padding(.top, 16)

                                iOS_ActiveCard(slot: active, accent: accent)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 24)
                            }

                            if !upcoming.isEmpty {
                                iOS_SectionHeader(
                                    title: "Upcoming Rotations",
                                    systemImage: "clock",
                                    color: Color.white.opacity(0.45)
                                )
                                .padding(.top, active == nil ? 16 : 0)

                                VStack(spacing: 8) {
                                    ForEach(upcoming) { slot in
                                        iOS_UpcomingRow(slot: slot, accent: accent)
                                            .padding(.horizontal, 16)
                                    }
                                }
                                .padding(.bottom, 32)
                            }
                        }
                    }
                }
            }
            .background(Color.black)
            .navigationTitle(mode.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    iOS_RefreshButton(service: service)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Header block

struct iOS_ModeHeader: View {
    let emoji: String
    let title: String
    let description: String
    let accent: Color
    let rotationCount: Int

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(LinearGradient(
                    colors: [accent.opacity(0.22), Color.black.opacity(0.0)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(maxWidth: .infinity)
                .frame(height: 140)

            Circle()
                .fill(accent.opacity(0.08))
                .frame(width: 220, height: 220)
                .offset(x: 240, y: 10)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 10) {
                    Text(emoji)
                        .font(.system(size: 26))
                    Text(title)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("\(rotationCount)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(accent.opacity(0.2), in: Capsule())
                }
                Text(description)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white.opacity(0.55))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
    }
}

// MARK: - Active card

struct iOS_ActiveCard: View {
    let slot: ScheduleSlot
    let accent: Color

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(accent).frame(width: 8, height: 8)
                    Text(slot.ruleName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(accent)
                }
                Spacer()
                iOS_Countdown(endTime: slot.endTime, accent: accent)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)

            Divider().background(Color.white.opacity(0.1)).padding(.horizontal, 16)

            VStack(spacing: 10) {
                ForEach(slot.stages) { stage in
                    iOS_StageCard(name: stage.name, imageURL: stage.image.url, height: 150)
                }
            }
            .padding(14)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.07))
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(accent.opacity(0.35), lineWidth: 1.5))
        )
    }
}

// MARK: - Upcoming row

struct iOS_UpcomingRow: View {
    let slot: ScheduleSlot
    let accent: Color
    @State private var expanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    expanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(slot.ruleName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                        Text(iOS_timeLabel(slot.startTime, slot.endTime))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.4))
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.3))
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                Divider().background(Color.white.opacity(0.08)).padding(.horizontal, 16)
                VStack(spacing: 10) {
                    ForEach(slot.stages) { stage in
                        iOS_StageCard(name: stage.name, imageURL: stage.image.url, height: 120)
                    }
                }
                .padding(14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.07)))
    }
}
#endif

import SwiftUI

struct ModeScheduleView: View {
    let mode: GameMode
    @ObservedObject var service: ScheduleService

    var slots: [ScheduleSlot] {
        (service.scheduleSlots[mode] ?? []).sorted { $0.startTime < $1.startTime }
    }

    var activeSlot: ScheduleSlot? { slots.first(where: \.isActive) }
    var upcomingSlots: [ScheduleSlot] { slots.filter { !$0.isActive } }
    var accentColor: Color { Color(hex: mode.accentColor) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ModeHeaderView(mode: mode, accentColor: accentColor, slotCount: slots.count)

                if service.isLoading && slots.isEmpty {
                    LoadingView()
                } else if slots.isEmpty {
                    EmptyStateView(mode: mode)
                } else {
                    VStack(spacing: 20) {
                        if let active = activeSlot {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Now Playing", systemImage: "play.circle.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(accentColor)
                                    .padding(.horizontal, 24)
                                ActiveSlotCard(slot: active, accentColor: accentColor)
                                    .padding(.horizontal, 20)
                            }
                        }

                        if !upcomingSlots.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Upcoming Rotations", systemImage: "clock")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 24)
                                LazyVStack(spacing: 10) {
                                    ForEach(upcomingSlots) { slot in
                                        ScheduleSlotRow(slot: slot, accentColor: accentColor)
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color.platformBackground)
        .animation(.easeInOut(duration: 0.25), value: mode)
    }
}

struct ModeHeaderView: View {
    let mode: GameMode
    let accentColor: Color
    let slotCount: Int

    var modeDescription: String {
        switch mode {
        case .turfWar:      return "Paint the most turf to win!"
        case .anarchyOpen:  return "Casual ranked matches — team up with friends"
        case .anarchySeries:return "Competitive ranked series — fight for your rating"
        case .xBattle:      return "Top-tier ranked play for the elite"
        case .salmonRun:    return "Co-op wave defense against the Salmonids"
        }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(LinearGradient(
                    colors: [accentColor.opacity(0.15), accentColor.opacity(0.03)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 130)

            Circle().fill(accentColor.opacity(0.08)).frame(width: 200, height: 200).offset(x: 400, y: 20)
            Circle().fill(accentColor.opacity(0.05)).frame(width: 120, height: 120).offset(x: 500, y: -30)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 12) {
                    Text(mode.rawValue)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                    Text("\(slotCount) rotations")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(accentColor.opacity(0.12), in: Capsule())
                }
                Text(modeDescription)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
}

struct ActiveSlotCard: View {
    let slot: ScheduleSlot
    let accentColor: Color
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(accentColor).frame(width: 8, height: 8)
                    Text(slot.ruleName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(accentColor)
                }
                Spacer()
                TimeRemainingView(endTime: slot.endTime)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)

            Divider().padding(.horizontal, 16)

            // iPhone: stacked; iPad/Mac: side by side
            if hSizeClass == .compact {
                VStack(spacing: 10) {
                    ForEach(slot.stages) { stage in
                        StageCard(stage: stage, size: .large)
                    }
                }
                .padding(16)
            } else {
                HStack(spacing: 12) {
                    ForEach(slot.stages) { stage in
                        StageCard(stage: stage, size: .large)
                    }
                }
                .padding(16)
            }
        }
        .background(accentColor.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accentColor.opacity(0.25), lineWidth: 1.5))
    }
}

struct ScheduleSlotRow: View {
    let slot: ScheduleSlot
    let accentColor: Color
    @State private var isExpanded = false
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(slot.ruleName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(timeRange(slot.startTime, slot.endTime))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                if !isExpanded {
                    HStack(spacing: 4) {
                        ForEach(slot.stages) { stage in
                            Text(stage.name)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.primary.opacity(0.05), in: Capsule())
                                .lineLimit(1)
                        }
                    }
                }
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .onTapGesture { withAnimation(.spring(response: 0.3)) { isExpanded.toggle() } }

            if isExpanded {
                Divider().padding(.horizontal, 16)

                // iPhone: stacked; iPad/Mac: side by side
                if hSizeClass == .compact {
                    VStack(spacing: 10) {
                        ForEach(slot.stages) { stage in
                            StageCard(stage: stage, size: .medium)
                        }
                    }
                    .padding(14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    HStack(spacing: 10) {
                        ForEach(slot.stages) { stage in
                            StageCard(stage: stage, size: .medium)
                        }
                    }
                    .padding(14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .background(Color.platformControlBackground, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.primary.opacity(0.06), lineWidth: 1))
    }

    func timeRange(_ start: Date, _ end: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        let df = DateFormatter()
        df.dateFormat = "EEE MMM d"
        return "\(df.string(from: start))  ·  \(f.string(from: start)) – \(f.string(from: end))"
    }
}

enum StageSize { case large, medium }

struct StageCard: View {
    let stage: VsStage
    let size: StageSize
    var cardHeight: CGFloat { size == .large ? 120 : 90 }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: URL(string: stage.image.url)) { phase in
                switch phase {
                case .success(let img): img.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle().fill(Color.gray.opacity(0.3))
                        .overlay(Image(systemName: "photo").foregroundStyle(.quaternary))
                default:
                    Rectangle().fill(Color.gray.opacity(0.15))
                        .overlay(ProgressView().scaleEffect(0.6))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(stage.name)
                .font(.system(size: size == .large ? 12 : 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TimeRemainingView: View {
    let endTime: Date
    @State private var timeRemaining: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "timer").font(.system(size: 10))
            Text(timeRemaining)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
        }
        .foregroundStyle(.secondary)
        .onAppear { updateTime() }
        .onReceive(timer) { _ in updateTime() }
    }

    func updateTime() {
        let remaining = endTime.timeIntervalSince(Date())
        if remaining <= 0 { timeRemaining = "Ended"; return }
        let h = Int(remaining) / 3600
        let m = (Int(remaining) % 3600) / 60
        let s = Int(remaining) % 60
        timeRemaining = String(format: "%d:%02d:%02d", h, m, s)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading schedules…").font(.system(size: 13)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

struct EmptyStateView: View {
    let mode: GameMode
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark").font(.system(size: 36)).foregroundStyle(.quaternary)
            Text("No \(mode.rawValue) rotations available").font(.system(size: 15, weight: .medium)).foregroundStyle(.secondary)
            Text("Check back later or try refreshing").font(.system(size: 12)).foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

// MARK: - Cross-platform color helpers
extension Color {
    static var platformBackground: Color {
        #if os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color(uiColor: .systemBackground)
        #endif
    }
    static var platformControlBackground: Color {
        #if os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color(uiColor: .secondarySystemBackground)
        #endif
    }
}

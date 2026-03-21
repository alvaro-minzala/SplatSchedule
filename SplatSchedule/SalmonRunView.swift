import SwiftUI

struct SalmonRunView: View {
    @ObservedObject var service: ScheduleService
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var activeSlot: CoopSlot? { service.coopSlots.first(where: \.isActive) }
    var upcomingSlots: [CoopSlot] { service.coopSlots.filter { !$0.isActive } }
    let accentColor = Color(hex: "#FF6B1A")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [accentColor.opacity(0.15), accentColor.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 130)

                    Circle()
                        .fill(accentColor.opacity(0.08))
                        .frame(width: 200, height: 200)
                        .offset(x: 400, y: 20)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 12) {
                            Text("Salmon Run")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                            Text("\(service.coopSlots.count) rotations")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(accentColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(accentColor.opacity(0.12), in: Capsule())
                        }
                        Text("Team up with 4 players to defeat waves of Salmonids!")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }

                if service.isLoading && service.coopSlots.isEmpty {
                    LoadingView()
                } else if service.coopSlots.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "fish.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.quaternary)
                        Text("No Salmon Run rotations available")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    VStack(spacing: 20) {
                        if let active = activeSlot {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Now Running", systemImage: "play.circle.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(accentColor)
                                    .padding(.horizontal, 24)
                                ActiveCoopCard(slot: active, accentColor: accentColor)
                                    .padding(.horizontal, 20)
                            }
                        }

                        if !upcomingSlots.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Upcoming Rotations", systemImage: "clock")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 24)
                                ForEach(upcomingSlots) { slot in
                                    CoopSlotRow(slot: slot, accentColor: accentColor)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color.platformBackground)
    }
}

struct ActiveCoopCard: View {
    let slot: CoopSlot
    let accentColor: Color
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Circle().fill(accentColor).frame(width: 8, height: 8)
                        Text(slot.coopMode.rawValue)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(accentColor)
                    }
                    if let boss = slot.bossName {
                        Text("King Salmonid: \(boss)")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                TimeRemainingView(endTime: slot.endTime)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)

            Divider().padding(.horizontal, 16)

            // iPhone: stacked layout; iPad/Mac: side-by-side
            if hSizeClass == .compact {
                VStack(alignment: .leading, spacing: 12) {
                    CoopStageImage(url: slot.stageImageURL, name: slot.stageName, height: 160)
                    CoopWeaponsGrid(weapons: slot.weapons, urls: slot.weaponImageURLs)
                }
                .padding(16)
            } else {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        CoopStageImage(url: slot.stageImageURL, name: slot.stageName, height: 110)
                    }
                    .frame(maxWidth: .infinity)
                    CoopWeaponsGrid(weapons: slot.weapons, urls: slot.weaponImageURLs)
                        .frame(maxWidth: .infinity)
                }
                .padding(16)
            }
        }
        .background(accentColor.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accentColor.opacity(0.25), lineWidth: 1.5))
    }
}

struct CoopStageImage: View {
    let url: String
    let name: String
    let height: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .success(let img): img.resizable().aspectRatio(contentMode: .fill)
                default: Rectangle().fill(Color.gray.opacity(0.2))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
    }
}

struct CoopWeaponsGrid: View {
    let weapons: [String]
    let urls: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WEAPONS")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.tertiary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(Array(zip(weapons, urls).prefix(4)), id: \.0) { name, url in
                    WeaponBadge(name: name, imageURL: url)
                }
            }
        }
    }
}

struct WeaponBadge: View {
    let name: String
    let imageURL: String

    var body: some View {
        HStack(spacing: 6) {
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .success(let img): img.resizable().aspectRatio(contentMode: .fit)
                default: Image(systemName: "questionmark").font(.system(size: 10))
                }
            }
            .frame(width: 22, height: 22)

            Text(name)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 6))
    }
}

struct CoopSlotRow: View {
    let slot: CoopSlot
    let accentColor: Color
    @State private var isExpanded = false
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(slot.coopMode.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                        if slot.coopMode != .regular {
                            Text(slot.coopMode == .bigRun ? "EVENT" : "CONTEST")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(accentColor, in: Capsule())
                        }
                    }
                    Text(timeRange(slot.startTime, slot.endTime))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
                Spacer()

                if !isExpanded {
                    Text(slot.stageName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.primary.opacity(0.05), in: Capsule())
                        .lineLimit(1)
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
                    VStack(alignment: .leading, spacing: 12) {
                        CoopStageImage(url: slot.stageImageURL, name: slot.stageName, height: 140)
                        if let boss = slot.bossName {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill").font(.system(size: 9)).foregroundStyle(accentColor)
                                Text(boss).font(.system(size: 10, weight: .medium)).foregroundStyle(.secondary)
                            }
                        }
                        CoopWeaponsGrid(weapons: slot.weapons, urls: slot.weaponImageURLs)
                    }
                    .padding(14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            CoopStageImage(url: slot.stageImageURL, name: slot.stageName, height: 80)
                            if let boss = slot.bossName {
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill").font(.system(size: 9)).foregroundStyle(accentColor)
                                    Text(boss).font(.system(size: 10, weight: .medium)).foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        CoopWeaponsGrid(weapons: slot.weapons, urls: slot.weaponImageURLs)
                            .frame(maxWidth: .infinity)
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
        let df = DateFormatter()
        df.dateFormat = "EEE MMM d"
        let tf = DateFormatter()
        tf.timeStyle = .short
        tf.dateStyle = .none
        return "\(df.string(from: start))  ·  \(tf.string(from: start)) – \(tf.string(from: end))"
    }
}

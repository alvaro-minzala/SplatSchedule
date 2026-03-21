#if !os(macOS)
import SwiftUI

struct iOS_SalmonView: View {
    @ObservedObject var service: ScheduleService
    let accent = Color(hex: "#FF6B1A")

    var active: CoopSlot? { service.coopSlots.first(where: \.isActive) }
    var upcoming: [CoopSlot] { service.coopSlots.filter { !$0.isActive } }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    iOS_ModeHeader(
                        emoji: "🐻",
                        title: "Salmon Run",
                        description: "Team up with 4 players to defeat Salmonids!",
                        accent: accent,
                        rotationCount: service.coopSlots.count
                    )

                    VStack(spacing: 0) {
                        if service.isLoading && service.coopSlots.isEmpty {
                            ProgressView().tint(.white).frame(maxWidth: .infinity).padding(.top, 60)
                        } else if service.coopSlots.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "fish.fill").font(.system(size: 40)).foregroundStyle(.quaternary)
                                Text("No rotations available").font(.system(size: 15, weight: .medium)).foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity).padding(.top, 60)
                        } else {
                            if let active {
                                iOS_SectionHeader(title: "Now Running", systemImage: "play.circle.fill", color: accent)
                                    .padding(.top, 16)
                                iOS_ActiveCoopCard(slot: active, accent: accent)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 24)
                            }

                            if !upcoming.isEmpty {
                                iOS_SectionHeader(title: "Upcoming Rotations", systemImage: "clock", color: Color.white.opacity(0.45))
                                    .padding(.top, active == nil ? 16 : 0)
                                VStack(spacing: 8) {
                                    ForEach(upcoming) { slot in
                                        iOS_CoopRow(slot: slot, accent: accent)
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
            .navigationTitle("Salmon Run")
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

// MARK: - Active coop card

struct iOS_ActiveCoopCard: View {
    let slot: CoopSlot
    let accent: Color

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Circle().fill(accent).frame(width: 8, height: 8)
                        Text(slot.coopMode.rawValue)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(accent)
                    }
                    if let boss = slot.bossName {
                        Text("King Salmonid: \(boss)")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.white.opacity(0.5))
                    }
                }
                Spacer()
                iOS_Countdown(endTime: slot.endTime, accent: accent)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)

            Divider().background(Color.white.opacity(0.1)).padding(.horizontal, 16)

            VStack(spacing: 10) {
                iOS_StageCard(name: slot.stageName, imageURL: slot.stageImageURL, height: 150)

                VStack(alignment: .leading, spacing: 8) {
                    Text("WEAPONS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.35))
                        .tracking(1)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(Array(zip(slot.weapons, slot.weaponImageURLs).prefix(4)), id: \.0) { name, url in
                            iOS_WeaponBadge(name: name, imageURL: url)
                        }
                    }
                }
            }
            .padding(14)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.07))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(accent.opacity(0.35), lineWidth: 1.5))
        )
    }
}

// MARK: - Upcoming coop row

struct iOS_CoopRow: View {
    let slot: CoopSlot
    let accent: Color
    @State private var expanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { expanded.toggle() }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(slot.coopMode.rawValue)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                            if slot.coopMode != .regular {
                                Text(slot.coopMode == .bigRun ? "EVENT" : "CONTEST")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 5).padding(.vertical, 2)
                                    .background(accent, in: Capsule())
                            }
                        }
                        Text(iOS_timeLabel(slot.startTime, slot.endTime))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.4))
                    }
                    Spacer()
                    Text(slot.stageName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.4))
                        .lineLimit(1)
                        .frame(maxWidth: 110, alignment: .trailing)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.3))
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                        .padding(.leading, 6)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                Divider().background(Color.white.opacity(0.08)).padding(.horizontal, 16)
                VStack(spacing: 10) {
                    iOS_StageCard(name: slot.stageName, imageURL: slot.stageImageURL, height: 120)
                    if let boss = slot.bossName {
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill").font(.system(size: 11)).foregroundStyle(accent)
                            Text(boss).font(.system(size: 12, weight: .medium)).foregroundStyle(Color.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("WEAPONS").font(.system(size: 11, weight: .bold)).foregroundStyle(Color.white.opacity(0.35)).tracking(1)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(Array(zip(slot.weapons, slot.weaponImageURLs).prefix(4)), id: \.0) { name, url in
                                iOS_WeaponBadge(name: name, imageURL: url)
                            }
                        }
                    }
                }
                .padding(14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.07)))
    }
}

// MARK: - Weapon badge

struct iOS_WeaponBadge: View {
    let name: String
    let imageURL: String

    var body: some View {
        HStack(spacing: 8) {
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .success(let img): img.resizable().aspectRatio(contentMode: .fit)
                default: Image(systemName: "questionmark").font(.system(size: 10)).foregroundStyle(.secondary)
                }
            }
            .frame(width: 26, height: 26)
            Text(name)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.65))
                .lineLimit(2)
        }
        .padding(.horizontal, 8).padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
    }
}
#endif

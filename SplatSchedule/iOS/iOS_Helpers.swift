#if !os(macOS)
import SwiftUI

// MARK: - Refresh button (circular, matches screenshot)

struct iOS_RefreshButton: View {
    @ObservedObject var service: ScheduleService

    var body: some View {
        Button {
            Task { await service.fetchAll() }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 36, height: 36)
                if service.isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.7)
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Live countdown

struct iOS_Countdown: View {
    let endTime: Date
    let accent: Color
    @State private var remaining: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "timer").font(.system(size: 11))
            Text(remaining)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
        }
        .foregroundStyle(Color.white.opacity(0.55))
        .onAppear { update() }
        .onReceive(timer) { _ in update() }
    }

    func update() {
        let left = endTime.timeIntervalSince(Date())
        guard left > 0 else { remaining = "Ended"; return }
        let h = Int(left) / 3600
        let m = (Int(left) % 3600) / 60
        let s = Int(left) % 60
        remaining = String(format: "%d:%02d:%02d", h, m, s)
    }
}

// MARK: - Section header

struct iOS_SectionHeader: View {
    let title: String
    let systemImage: String
    let color: Color

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
    }
}

// MARK: - Stage image card

struct iOS_StageCard: View {
    let name: String
    let imageURL: String
    var height: CGFloat = 150

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle().fill(Color.white.opacity(0.08))
                        .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                default:
                    Rectangle().fill(Color.white.opacity(0.05))
                        .overlay(ProgressView().tint(.white))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.65))
        }
    }
}

// MARK: - Time range label

func iOS_timeLabel(_ start: Date, _ end: Date) -> String {
    let df = DateFormatter()
    df.dateFormat = "EEE MMM d"
    let tf = DateFormatter()
    tf.dateStyle = .none
    tf.timeStyle = .short
    return "\(df.string(from: start))  ·  \(tf.string(from: start)) – \(tf.string(from: end))"
}
#endif

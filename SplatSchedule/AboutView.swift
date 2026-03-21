import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [Color.accentColor.opacity(0.12), Color.accentColor.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 130)

                    Circle()
                        .fill(Color.accentColor.opacity(0.07))
                        .frame(width: 200, height: 200)
                        .offset(x: 400, y: 20)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("About")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                        Text("More information on this app")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }

                // Content area — replace this with whatever you want
                VStack(alignment: .leading, spacing: 20) {
                    // ── YOUR CONTENT GOES HERE ──────────────────────────────
                    // Example placeholder:
                    Text("Made by Álvaro Minzala(@thezarufox on X) as a way to check Splatoon 3 rotations quickly on the computer and iOS devices.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                    Text("Not affiliated with Nintendo Co., Ltd.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                    Text("Uses data from Splatoon3.ink")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                    // ────────────────────────────────────────────────────────
                }
                .padding(24)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

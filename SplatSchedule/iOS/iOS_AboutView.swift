#if !os(macOS)
import SwiftUI

struct iOS_AboutView: View {
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    ZStack(alignment: .bottomLeading) {
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.black.opacity(0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)

                        Circle()
                            .fill(Color.white.opacity(0.04))
                            .frame(width: 200, height: 200)
                            .offset(x: 240, y: 10)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("About")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Write anything you'd like here")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.white.opacity(0.5))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 18)
                    }

                    // ── YOUR CONTENT GOES HERE ──────────────────────────
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your content goes here.")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                    // ────────────────────────────────────────────────────
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                }
            }
            .background(Color.black)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .navigationViewStyle(.stack)
    }
}
#endif

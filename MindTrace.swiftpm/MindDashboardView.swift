import SwiftUI

struct MindDashboardView: View {

    @EnvironmentObject private var scoreManager: ScoreManager
    @State private var animatePulse: Bool = false

    private var totalGames: Int { scoreManager.totalGamesPlayed }
    private var bestScore: Int { scoreManager.bestScore }
    private var averageScore: Int { scoreManager.averageScore }
    private var lastTopic: String { scoreManager.lastPlayedTopic ?? "Play a game to get started" }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.25),
                    Color.purple.opacity(0.20),
                    Color.blue.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    scoreGrid
                    overallCard
                    topicMasterySection
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                animatePulse = true
            }
        }
    }

    // MARK: - Header & Greeting

    private var header: some View {
        VStack(spacing: 6) {
            Text("Mind % Dashboard")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
        }
    }

    // MARK: - Score Grid (less text, equal card sizes)

    private var scoreGrid: some View {
        let cols = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        return LazyVGrid(columns: cols, spacing: 12) {
            statCard(title: "Games", value: "\(totalGames)", icon: "gamecontroller", tint: .mint)
            statCard(title: "Best", value: "\(bestScore)%", icon: "trophy", tint: .orange)
            statCard(title: "Avg", value: "\(averageScore)%", icon: "chart.line.uptrend.xyaxis", tint: .cyan)
            statCard(title: "Last", value: lastTopic, icon: "clock", tint: .purple, isTextValue: true)
        }
    }

    private func statCard(
        title: String,
        value: String,
        icon: String,
        tint: Color,
        isTextValue: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            if isTextValue {
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            } else {
                Text(value)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 92, maxHeight: 92, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15))
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 6)
    }

    // MARK: - Overall Mind %

    private var overallCard: some View {
        VStack(spacing: 12) {
            Text("Overall Mind %")
                .font(.headline)
                .foregroundStyle(.primary)

            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.15))
                    )
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)

                VStack(spacing: 8) {
                    Text("\(averageScore)%")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .scaleEffect(animatePulse ? 1.02 : 0.98)
                        .animation(.easeInOut(duration: 1.4), value: animatePulse)
                    Text("Average across all sessions")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(26)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
        }
    }

    // MARK: - Topic Mastery

    private var topicMasterySection: some View {
        let topics = scoreManager.topicAverages
        return VStack(alignment: .leading, spacing: 12) {
            Text("Mastery")
                .font(.headline)

            if topics.isEmpty {
                Text("Play to build mastery.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(topics.prefix(8).enumerated()), id: \.offset) { _, item in
                        topicRow(topic: item.topic, value: item.average)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15))
        )
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    private func topicRow(topic: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(topic)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(value)%")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: Double(value), total: 100)
                .tint(.green)
        }
    }

}

#Preview {
    MindDashboardView()
}


import SwiftUI

struct GameSummaryView: View {

    let gameName: String
    let levelReached: Int
    let accuracy: Double
    let avgResponseTime: Double
    let totalTime: TimeInterval
    let score: Int
    let onRetry: () -> Void
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(gameName)
                .font(.title2.weight(.semibold))

            VStack(spacing: 12) {
                summaryRow(title: "Level", value: "Level \(levelReached)")
                summaryRow(title: "Accuracy", value: "\(Int(round(accuracy)))%")
                summaryRow(title: "Avg time", value: String(format: "%.1fs", avgResponseTime))
                summaryRow(title: "Total time", value: String(format: "%.1fs", totalTime))
                summaryRow(title: "Score", value: "\(score)")
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15))
            )

            HStack(spacing: 16) {
                Button("Retry") {
                    onRetry()
                }
                .buttonStyle(.borderedProminent)

                Button("Done") {
                    onDone()
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }

    private func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
        }
    }
}

#Preview {
    NavigationStack {
        GameSummaryView(
            gameName: "Pattern Memory Challenge",
            levelReached: 4,
            accuracy: 86,
            avgResponseTime: 1.2,
            totalTime: 45.7,
            score: 780,
            onRetry: {},
            onDone: {}
        )
    }
}


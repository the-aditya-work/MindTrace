import SwiftUI

struct TestTabView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Memory Games")
                        .font(.largeTitle.bold())
                    Text("Level‑based puzzles inspired by game‑based aptitude tests.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)

                VStack(spacing: 16) {
                    GameCardView(
                        title: "Geo‑Sudo Challenge",
                        subtitle: "Fill shapes so each row and column is unique.",
                        systemImage: "square.grid.4x3.fill",
                        destination: DeductiveLogicGameView()
                    )

                    GameCardView(
                        title: "Pattern Memory Challenge",
                        subtitle: "Remember a grid pattern, then tap cells in order.",
                        systemImage: "square.grid.3x3.fill",
                        destination: PatternMemoryChallengeView()
                    )

                    GameCardView(
                        title: "Logic Master Challenge",
                        subtitle: "Mixed logic, rule and switch puzzles.",
                        systemImage: "brain.head.profile",
                        destination: LogicMasterChallengeView()
                    )

                    GameCardView(
                        title: "Digit Challenge",
                        subtitle: "Use digits 1‑9 once to satisfy the equation.",
                        systemImage: "function",
                        destination: DigitChallengeView()
                    )

                    GameCardView(
                        title: "Motion Challenge",
                        subtitle: "Guide the ball to the hole in fewest moves.",
                        systemImage: "circle.hexagonpath",
                        destination: MotionChallengeView()
                    )

                    GameCardView(
                        title: "Colour the Grid",
                        subtitle: "Learn color rules, then complete the pattern.",
                        systemImage: "paintpalette",
                        destination: ColourTheGridView()
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    NavigationStack {
        TestTabView()
    }
}


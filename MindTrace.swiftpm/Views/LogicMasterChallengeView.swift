import SwiftUI

struct LogicMasterChallengeView: View {

    @StateObject private var viewModel = LogicMasterViewModel()
    @EnvironmentObject private var gameResultManager: GameResultManager

    @State private var showingSummary = false

    var body: some View {
        VStack(spacing: 20) {
            header

            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.question)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 10) {
                    ForEach(viewModel.options.indices, id: \.self) { idx in
                        Button {
                            viewModel.submitOption(at: idx)
                        } label: {
                            HStack {
                                Text(viewModel.options[idx])
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if viewModel.showFeedback,
                                   let selected = viewModel.selectedIndex,
                                   selected == idx {
                                    Image(systemName: idx == viewModel.correctIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(idx == viewModel.correctIndex ? .green : .red)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(idx == viewModel.selectedIndex ? Color.blue.opacity(0.2) : Color.white.opacity(0.9))
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.showFeedback)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Logic Master")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Finish") {
                    finishRun()
                }
            }
        }
        .onAppear {
            viewModel.configureForCurrentLevel()
        }
        .sheet(isPresented: $showingSummary) {
            GameSummaryView(
                gameName: "Logic Master Challenge",
                levelReached: viewModel.level,
                accuracy: viewModel.lastAccuracy,
                avgResponseTime: viewModel.lastAvgResponseTime,
                score: viewModel.lastScore
            ) {
                // Retry
                viewModel.configureForCurrentLevel()
                showingSummary = false
            } onDone: {
                showingSummary = false
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Level \(viewModel.level)")
                    .font(.headline)
                if viewModel.isTimed {
                    Text("Timed puzzle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Take your time to reason it out.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if viewModel.isTimed {
                ProgressView(value: viewModel.timeLeft, total: viewModel.timeTotal)
                    .progressViewStyle(.linear)
                    .frame(width: 140)
            }
        }
    }

    private func finishRun() {
        // Ensure we have some stats
        if viewModel.lastScore == 0 && viewModel.selectedIndex != nil {
            // Stats were already computed in submitOption
        }
        gameResultManager.record(
            gameName: "Logic Master Challenge",
            maxLevelReached: viewModel.level,
            accuracy: viewModel.lastAccuracy,
            avgResponseTime: viewModel.lastAvgResponseTime,
            totalScore: viewModel.lastScore
        )
        showingSummary = true
    }
}

#Preview {
    NavigationStack {
        LogicMasterChallengeView()
            .environmentObject(GameResultManager.shared)
    }
}


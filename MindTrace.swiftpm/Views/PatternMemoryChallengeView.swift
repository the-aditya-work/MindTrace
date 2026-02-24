import SwiftUI

struct PatternMemoryChallengeView: View {

    @StateObject private var viewModel = PatternMemoryViewModel()
    @EnvironmentObject private var gameResultManager: GameResultManager

    @State private var showingSummary = false

    var body: some View {
        VStack(spacing: 20) {
            header

            gridSection

            if viewModel.phase == .input {
                Text("Tap the cells in the order they lit up.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("Memorize the highlighted pattern.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Pattern Memory")
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
                gameName: "Pattern Memory Challenge",
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
                Text("Grid \(viewModel.gridSize)×\(viewModel.gridSize)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if viewModel.phase == .preview {
                ProgressView(value: viewModel.previewTimeRemaining, total: viewModel.previewTimeTotal)
                    .progressViewStyle(.linear)
                    .frame(width: 140)
            }
        }
    }

    private var gridSection: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: viewModel.gridSize)
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<(viewModel.gridSize * viewModel.gridSize), id: \.self) { index in
                let isInPattern = viewModel.pattern.contains(index)
                let isTapped = viewModel.taps.contains(index)
                Button {
                    viewModel.handleTap(on: index)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(cellColor(isInPattern: isInPattern, isTapped: isTapped))
                            .frame(height: 44)
                        if isTapped, let pos = viewModel.taps.firstIndex(of: index) {
                            Text("\(pos + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(viewModel.phase == .preview)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.regularMaterial)
        )
    }

    private func cellColor(isInPattern: Bool, isTapped: Bool) -> Color {
        switch viewModel.phase {
        case .preview:
            return isInPattern ? Color.blue.opacity(0.7) : Color.gray.opacity(0.15)
        case .input:
            if isTapped {
                return Color.blue.opacity(0.7)
            } else {
                return Color.gray.opacity(0.15)
            }
        }
    }

    private func finishRun() {
        if viewModel.lastScore == 0 {
            viewModel.computeStatsAndScore()
        }
        gameResultManager.record(
            gameName: "Pattern Memory Challenge",
            maxLevelReached: viewModel.level,
            accuracy: viewModel.lastAccuracy,
            avgResponseTime: viewModel.lastAvgResponseTime,
            totalScore: viewModel.lastScore
        )
        showingSummary = true
        viewModel.advanceLevelIfSuccessful()
    }
}

#Preview {
    NavigationStack {
        PatternMemoryChallengeView()
            .environmentObject(GameResultManager.shared)
    }
}


import SwiftUI

struct PatternMemoryChallengeView: View {

    @StateObject private var viewModel = PatternMemoryViewModel()
    @EnvironmentObject private var gameResultManager: GameResultManager

    @State private var showingSummary = false
    @State private var showingCorrectPopup = false
    @State private var showingWrongPopup = false
    @State private var gameStartTime = Date()
    @State private var totalGameTime: TimeInterval = 0

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
            gameStartTime = Date()
            viewModel.configureForCurrentLevel()
            
            // Set up callbacks for immediate feedback
            viewModel.onCorrectAnswer = {
                showingCorrectPopup = true
            }
            viewModel.onWrongAnswer = {
                showingWrongPopup = true
            }
        }
        .sheet(isPresented: $showingCorrectPopup) {
            CorrectAnswerPopup {
                viewModel.moveToNextLevel()
                showingCorrectPopup = false
            }
        }
        .sheet(isPresented: $showingWrongPopup) {
            WrongAnswerPopup {
                viewModel.retryLevel()
                showingWrongPopup = false
            }
        }
        .sheet(isPresented: $showingSummary) {
            GameSummaryView(
                gameName: "Pattern Memory Challenge",
                levelReached: viewModel.level,
                accuracy: viewModel.lastAccuracy,
                avgResponseTime: viewModel.lastAvgResponseTime,
                totalTime: totalGameTime,
                score: viewModel.lastScore
            ) {
                // Retry - reset game to fresh state
                resetGame()
                showingSummary = false
            } onDone: {
                // Done - reset game to fresh state
                resetGame()
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
                        
                        // Show numbers during preview phase for pattern cells
                        if viewModel.phase == .preview, let pos = viewModel.pattern.firstIndex(of: index) {
                            Text("\(pos + 1)")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.white)
                        }
                        
                        // Show numbers during input phase for tapped cells
                        if viewModel.phase == .input, let pos = viewModel.taps.firstIndex(of: index) {
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
        totalGameTime = Date().timeIntervalSince(gameStartTime)
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
    }
    
    private func resetGame() {
        // Reset timing
        gameStartTime = Date()
        totalGameTime = 0
        
        // Reset view model to fresh state
        viewModel.level = 1
        viewModel.configureForCurrentLevel()
        
        // Clear any showing popups
        showingCorrectPopup = false
        showingWrongPopup = false
    }
}

#Preview {
    NavigationStack {
        PatternMemoryChallengeView()
            .environmentObject(GameResultManager.shared)
    }
}


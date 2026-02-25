import SwiftUI

struct LogicMasterChallengeView: View {

    @StateObject private var viewModel = LogicMasterViewModel()
    @EnvironmentObject private var gameResultManager: GameResultManager

    @State private var showingSummary = false
    @State private var showSuccessAnimation = false
    @State private var showWrongAnimation = false
    @State private var pulseAnimation = false
    @State private var slideInAnimation = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if #available(iOS 17.0, *) {
                VStack(spacing: 0) {
                    // Game Header
                    gameHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    // Question Card
                    questionCard
                        .padding(.horizontal, 20)
                        .scaleEffect(slideInAnimation ? 1.0 : 0.8)
                        .opacity(slideInAnimation ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: slideInAnimation)
                    
                    Spacer()
                    
                    // Options Grid
                    optionsGrid
                        .padding(.horizontal, 20)
                        .scaleEffect(slideInAnimation ? 1.0 : 0.9)
                        .opacity(slideInAnimation ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: slideInAnimation)
                    
                    Spacer(minLength: 30)
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Exit") {
                            finishRun()
                        }
                        .foregroundColor(.red)
                        .font(.subheadline.weight(.medium))
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 12) {
                            // Score Display
                            VStack(spacing: 2) {
                                Text("Score")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.lastScore)")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.primary)
                            }
                            
                            // Level Badge
                            VStack(spacing: 2) {
                                Text("Level")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.level)")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .onAppear {
                    viewModel.configureForCurrentLevel()
                    withAnimation {
                        slideInAnimation = true
                    }
                }
                .onChange(of: viewModel.selectedIndex) { newValue in
                    if newValue != nil {
                        handleAnswerSelection()
                    }
                }
                .sheet(isPresented: $showingSummary) {
                    GameSummaryView(
                        gameName: "Logic Master Challenge",
                        levelReached: viewModel.level,
                        accuracy: viewModel.lastAccuracy,
                        avgResponseTime: viewModel.lastAvgResponseTime,
                        totalTime: viewModel.timeTotal,
                        score: viewModel.lastScore,
                    ) {
                        // Retry
                        resetGame()
                        showingSummary = false
                    } onDone: {
                        showingSummary = false
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }

    private var gameHeader: some View {
        VStack(spacing: 16) {
            // Title and Timer
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Logic Master")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                        
                        Text(viewModel.isTimed ? "Speed Round" : "Think Carefully")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Timer Display
                if viewModel.isTimed {
                    if #available(iOS 17.0, *) {
                        VStack(spacing: 4) {
                            Text("Time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                                    .frame(width: 40, height: 40)
                                
                                Circle()
                                    .trim(from: 0, to: viewModel.timeLeft / viewModel.timeTotal)
                                    .stroke(
                                        viewModel.timeLeft <= 5 ? Color.red : Color.blue,
                                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                    )
                                    .frame(width: 40, height: 40)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 1), value: viewModel.timeLeft)
                                
                                Text("\(Int(viewModel.timeLeft))")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(viewModel.timeLeft <= 5 ? .red : .primary)
                            }
                        }
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulseAnimation)
                        .onAppear {
                            if viewModel.isTimed {
                                pulseAnimation = true
                            }
                        }
                        .onChange(of: viewModel.isTimed) { _, newValue in
                            pulseAnimation = newValue
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            
            // Progress Bar
            HStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index < viewModel.level ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 30, height: 4)
                        .scaleEffect(index == viewModel.level - 1 && pulseAnimation ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseAnimation)
                }
                
                Spacer()
                
                Text("Level \(viewModel.level)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var questionCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Spacer()
                
                Text("Puzzle")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
            
            Text(viewModel.question)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    private var optionsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 16) {
            ForEach(viewModel.options.indices, id: \.self) { idx in
                Button {
                    viewModel.submitOption(at: idx)
                } label: {
                    VStack(spacing: 8) {
                        // Option Letter
                        Text("\(Character(UnicodeScalar(65 + idx)!))")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.blue)
                        
                        // Option Text
                        Text(viewModel.options[idx])
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Feedback Icon
                        if viewModel.showFeedback,
                           let selected = viewModel.selectedIndex,
                           selected == idx {
                            Image(systemName: idx == viewModel.correctIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(idx == viewModel.correctIndex ? .green : .red)
                                .scaleEffect(showSuccessAnimation || showWrongAnimation ? 1.5 : 1.0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuccessAnimation)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showWrongAnimation)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(optionBackgroundColor(for: idx))
                            .shadow(color: optionShadowColor(for: idx), radius: 8, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                optionBorderColor(for: idx),
                                lineWidth: 2
                            )
                    )
                    .scaleEffect(
                        viewModel.selectedIndex == idx && !viewModel.showFeedback ? 0.95 : 1.0
                    )
                    .animation(.easeInOut(duration: 0.1), value: viewModel.selectedIndex)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.showFeedback)
            }
        }
    }
    
    private func optionBackgroundColor(for index: Int) -> Color {
        if viewModel.showFeedback {
            if let selected = viewModel.selectedIndex, selected == index {
                return index == viewModel.correctIndex ? Color.green.opacity(0.1) : Color.red.opacity(0.1)
            } else if index == viewModel.correctIndex {
                return Color.green.opacity(0.1)
            }
        } else if viewModel.selectedIndex == index {
            return Color.blue.opacity(0.1)
        }
        
        return Color.white
    }
    
    private func optionBorderColor(for index: Int) -> Color {
        if viewModel.showFeedback {
            if let selected = viewModel.selectedIndex, selected == index {
                return index == viewModel.correctIndex ? Color.green : Color.red
            } else if index == viewModel.correctIndex {
                return Color.green
            }
        } else if viewModel.selectedIndex == index {
            return Color.blue
        }
        
        return Color.gray.opacity(0.3)
    }
    
    private func optionShadowColor(for index: Int) -> Color {
        if viewModel.showFeedback {
            if let selected = viewModel.selectedIndex, selected == index {
                return (index == viewModel.correctIndex ? Color.green : Color.red).opacity(0.3)
            }
        } else if viewModel.selectedIndex == index {
            return Color.blue.opacity(0.2)
        }
        
        return Color.black.opacity(0.05)
    }
    
    private func handleAnswerSelection() {
        guard let selected = viewModel.selectedIndex else { return }
        
        if selected == viewModel.correctIndex {
            showSuccessAnimation = true
            // Auto-advance after success
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if viewModel.level > 5 { // Game complete after 5 levels
                    finishRun()
                } else {
                    nextLevel()
                }
            }
        } else {
            showWrongAnimation = true
            // Show summary after wrong answer
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                finishRun()
            }
        }
    }
    
    private func nextLevel() {
        withAnimation(.easeInOut(duration: 0.3)) {
            slideInAnimation = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.configureForCurrentLevel()
            showSuccessAnimation = false
            showWrongAnimation = false
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                slideInAnimation = true
            }
        }
    }
    
    private func resetGame() {
        viewModel.level = 1
        viewModel.lastScore = 0
        nextLevel()
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


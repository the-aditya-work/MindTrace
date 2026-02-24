//
//  File.swift
//  MindSpan
//
//  Created by Aditya Rai on 15/02/26.
//

import SwiftUI

struct ActualMemoryTestView: View {

    // MARK: - Game Phases
    enum GamePhase {
        case sequence
        case distraction
        case recall
        case result
    }

    @EnvironmentObject private var scoreManager: ScoreManager

    @State private var phase: GamePhase = .sequence
    @State private var sequenceItems: [Color] = []
    @State private var currentIndex: Int = 0
    @State private var showItem: Bool = false
    @State private var distractionTimeLeft: Int = 15
    @State private var score: Int = 0
    @State private var currentQuestion: Int = 0
    @State private var hasRecordedScore: Bool = false

    let totalQuestions = 5

    // MARK: - Body
    var body: some View {

        ZStack {
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.4),
                    Color.purple.opacity(0.3),
                    Color.blue.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {

                switch phase {

                case .sequence:
                    sequenceView

                case .distraction:
                    distractionView

                case .recall:
                    recallView

                case .result:
                    resultView
                }
            }
            .padding()
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            startGame()
        }
    }
}

// MARK: - Game Logic
extension ActualMemoryTestView {

    func startGame() {
        sequenceItems = generateRandomColors()
        currentIndex = 0
        score = 0
        currentQuestion = 0
        phase = .sequence
        playSequence()
    }

    func generateRandomColors() -> [Color] {
        let palette: [Color] = [
            .mint, .pink, .orange, .blue, .purple, .teal, .indigo
        ]
        return Array(palette.shuffled().prefix(6))
    }

    func playSequence() {
        guard currentIndex < sequenceItems.count else {
            phase = .distraction
            startDistractionTimer()
            return
        }

        showItem = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showItem = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentIndex += 1
                playSequence()
            }
        }
    }

    func startDistractionTimer() {
        distractionTimeLeft = 15

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if distractionTimeLeft > 0 {
                distractionTimeLeft -= 1
            } else {
                timer.invalidate()
                phase = .recall
            }
        }
    }

    func calculatePercentage() -> Int {
        return Int((Double(score) / Double(totalQuestions)) * 100)
    }
}

// MARK: - UI Views
extension ActualMemoryTestView {

    // 🔹 Sequence Phase
    var sequenceView: some View {
        VStack(spacing: 20) {

            Text("Observe Carefully")
                .font(.headline)

            if showItem {
                RoundedRectangle(cornerRadius: 24)
                    .fill(sequenceItems[currentIndex])
                    .frame(height: 220)
                    .shadow(radius: 12)
                    .transition(.scale)
                    .animation(.easeInOut, value: showItem)
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 220)
            }

            ProgressView(value: Double(currentIndex),
                         total: Double(sequenceItems.count))
                .progressViewStyle(.linear)
                .tint(.orange)
        }
    }

    // 🔹 Distraction Phase
    var distractionView: some View {
        VStack(spacing: 20) {

            Text("Tap the Circles")
                .font(.headline)

            Text("Time Left: \(distractionTimeLeft)s")
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(Color.orange.opacity(0.7))
                        .frame(width: 70, height: 70)
                }
            }
        }
    }

    // 🔹 Recall Phase
    var recallView: some View {
        VStack(spacing: 20) {

            Text("Question \(currentQuestion + 1) of \(totalQuestions)")
                .font(.headline)

            Text("Which color appeared?")
                .foregroundColor(.secondary)

            ForEach(sequenceItems.shuffled(), id: \.self) { color in
                Button(action: {
                    if color == sequenceItems[currentQuestion] {
                        score += 1
                    }

                    if currentQuestion < totalQuestions - 1 {
                        currentQuestion += 1
                    } else {
                        phase = .result
                    }

                }) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color)
                        .frame(height: 50)
                }
            }
        }
    }

    // 🔹 Result Phase
    var resultView: some View {
        VStack(spacing: 20) {

            Text("Mind Remembering %")
                .font(.headline)

            Text("\(calculatePercentage())%")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.orange)

            Text(resultMessage())
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Play Again") {
                startGame()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .onAppear {
            if !hasRecordedScore {
                hasRecordedScore = true
                scoreManager.record(
                    topic: "Sequence Recall (Test)",
                    source: .test,
                    score: calculatePercentage()
                )
            }
        }
    }

    func resultMessage() -> String {
        let percent = calculatePercentage()

        switch percent {
        case 80...100:
            return "Your memory is strong and focused."
        case 50..<80:
            return "Your mind remembers well with gentle focus."
        default:
            return "With calm attention, your memory can grow stronger."
        }
    }
}

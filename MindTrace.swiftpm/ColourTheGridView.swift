//
//  ColourTheGridView.swift
//  MindSpan
//
//  Capgemini Colour the Grid: Learn rules from 6 tables, color 4 tables.
//

import SwiftUI

struct ColourTheGridView: View {

    private let colors: [Color] = [.red, .blue, .green, .orange, .purple]
    @State private var phase: Phase = .learn
    @State private var sampleGrid: [[Color]] = []
    @State private var quizGrid: [[Color?]] = []
    @State private var userColors: [Int: Color] = [:]
    @State private var showResult = false
    @State private var score = 0
    @State private var level: Int = 1
    @State private var showSummary = false
    @State private var runStart = Date()

    @EnvironmentObject private var gameResultManager: GameResultManager

    enum Phase {
        case learn, quiz, result
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.indigo.opacity(0.3), Color.blue.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text("Colour the Grid")
                        .font(.title2)
                        .bold()

                    Text("Learn the pattern, then color the empty cells.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    switch phase {
                    case .learn:
                        learnPhase
                    case .quiz:
                        quizPhase
                    case .result:
                        resultPhase
                    }
                }
                .padding()
            }
            .onAppear {
                runStart = Date()
                startGame()
            }
        }
        .navigationTitle("Colour the Grid")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Finish") {
                    finishRun()
                }
            }
        }
        .sheet(isPresented: $showSummary) {
            GameSummaryView(
                gameName: "Colour the Grid",
                levelReached: level,
                accuracy: Double(score),
                avgResponseTime: Date().timeIntervalSince(runStart),
                score: score
            ) {
                level = 1
                startGame()
                runStart = Date()
                showSummary = false
            } onDone: {
                showSummary = false
            }
        }
    }

    private var learnPhase: some View {
        VStack(spacing: 16) {
            Text("Sample grid (observe the pattern)")
                .font(.headline)

            if !sampleGrid.isEmpty {
                gridView2D(sampleGrid)
            }

            Button("Start Quiz") {
                phase = .quiz
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var quizPhase: some View {
        VStack(spacing: 16) {
            Text("Color the empty cells to match the pattern")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { r in
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { c in
                            let i = r * 3 + c
                            let cellColor = quizGrid.indices.contains(r) && quizGrid[r].indices.contains(c) ? quizGrid[r][c] : nil
                            if let col = cellColor {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(col)
                                    .frame(height: 50)
                            } else {
                                Menu {
                                    ForEach(Array(colors.enumerated()), id: \.offset) { _, col in
                                        Button {
                                            userColors[i] = col
                                        } label: {
                                            Label("", systemImage: "circle.fill")
                                                .foregroundColor(col)
                                        }
                                    }
                                } label: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(userColors[i] ?? Color.gray.opacity(0.5))
                                        .frame(height: 50)
                                }
                            }
                        }
                    }
                }
            }
            .padding(8)
            .background(Color.black.opacity(0.1))
            .cornerRadius(12)

            Button("Submit") {
                checkAnswer()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var resultPhase: some View {
        VStack(spacing: 16) {
            Text("Score: \(score)")
                .font(.title)
                .foregroundColor(.green)
            Button("Play Again") { startGame() }
                .buttonStyle(.borderedProminent)
        }
    }

    private func gridView2D(_ grid: [[Color]]) -> some View {
        VStack(spacing: 4) {
            ForEach(0..<grid.count, id: \.self) { r in
                HStack(spacing: 4) {
                    ForEach(0..<grid[r].count, id: \.self) { c in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(grid[r][c])
                            .frame(width: 40, height: 40)
                    }
                }
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
    }

    private func startGame() {
        sampleGrid = (0..<3).map { _ in
            (0..<3).map { _ in colors.randomElement()! }
        }
        quizGrid = sampleGrid.map { row in row.map { Optional($0) } }
        quizGrid[1][1] = nil
        quizGrid[0][2] = nil
        quizGrid[2][0] = nil
        userColors = [:]
        phase = .learn
        showResult = false
        score = 0
    }

    private func checkAnswer() {
        var correct = 0
        for (i, col) in userColors {
            let r = i / 3, c = i % 3
            if r < 3 && c < 3, let expected = sampleGrid[safe: r]?[safe: c] {
                if col == expected { correct += 1 }
            }
        }
        score = correct * 10
        phase = .result
        gameResultManager.record(
            gameName: "Colour the Grid",
            maxLevelReached: level,
            accuracy: Double(score),
            avgResponseTime: Date().timeIntervalSince(runStart),
            totalScore: score
        )
        level = min(level + 1, 10)
    }

    private func finishRun() {
        gameResultManager.record(
            gameName: "Colour the Grid",
            maxLevelReached: level,
            accuracy: Double(score),
            avgResponseTime: Date().timeIntervalSince(runStart),
            totalScore: score
        )
        showSummary = true
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

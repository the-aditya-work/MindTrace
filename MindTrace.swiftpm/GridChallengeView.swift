//
//  GridChallengeView.swift
//  MindSpan
//
//  Capgemini Grid Challenge: Remember highlighted positions + symmetry check.
//

import SwiftUI

struct GridPos: Hashable {
    let r: Int
    let c: Int
}

struct GridChallengeView: View {

    private let gridRows = 3
    private let gridCols = 4
    @State private var phase: Phase = .observe
    @State private var highlighted: [(Int, Int)] = []
    @State private var symmetryPairs: [(String, String)] = []
    @State private var currentPairIndex = 0
    @State private var userSymmetryAnswers: [Bool] = []
    @State private var userGridAnswers: Set<GridPos> = []
    @State private var showResult = false
    @State private var score = 0
    @State private var showingCorrectPopup = false
    @State private var showingWrongPopup = false

    enum Phase {
        case observe, symmetry, recall
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
                VStack(spacing: 20) {
                    Text("Grid Challenge")
                        .font(.title2)
                        .bold()

                    switch phase {
                    case .observe:
                        observePhase
                    case .symmetry:
                        symmetryPhase
                    case .recall:
                        recallPhase
                    }
                }
                .padding()
            }
            .onAppear { startGame() }
        }
        .sheet(isPresented: $showingCorrectPopup) {
            CorrectAnswerPopup {
                nextOrRecall()
                showingCorrectPopup = false
            }
        }
        .sheet(isPresented: $showingWrongPopup) {
            WrongAnswerPopup {
                userGridAnswers = []
                showingWrongPopup = false
            }
        }
    }

    private var observePhase: some View {
        VStack(spacing: 16) {
            Text("Remember the highlighted cells")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: gridCols), spacing: 8) {
                ForEach(0..<gridRows, id: \.self) { r in
                    ForEach(0..<gridCols, id: \.self) { c in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(highlighted.contains(where: { $0.0 == r && $0.1 == c }) ? Color.orange : Color.white.opacity(0.6))
                            .frame(height: 50)
                    }
                }
            }
            .padding(8)
            .background(Color.black.opacity(0.1))
            .cornerRadius(12)

            Button("Next") {
                phase = .symmetry
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var symmetryPhase: some View {
        VStack(spacing: 16) {
            Text("Are these symmetrical?")
                .font(.headline)

            if currentPairIndex < symmetryPairs.count {
                let pair = symmetryPairs[currentPairIndex]
                HStack(spacing: 20) {
                    Text(pair.0)
                        .font(.title2)
                    Text("⇄")
                    Text(pair.1)
                        .font(.title2)
                }
                .padding()

                HStack(spacing: 20) {
                    Button("Yes") {
                        userSymmetryAnswers.append(true)
                        nextOrRecall()
                    }
                    .buttonStyle(.borderedProminent)
                    Button("No") {
                        userSymmetryAnswers.append(false)
                        nextOrRecall()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private var recallPhase: some View {
        VStack(spacing: 16) {
            Text("Tap the cells that were highlighted")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: gridCols), spacing: 8) {
                ForEach(0..<gridRows, id: \.self) { r in
                    ForEach(0..<gridCols, id: \.self) { c in
                        Button {
                            let pos = GridPos(r: r, c: c)
                            if userGridAnswers.contains(pos) {
                                userGridAnswers.remove(pos)
                            } else {
                                userGridAnswers.insert(pos)
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(userGridAnswers.contains(GridPos(r: r, c: c)) ? Color.orange : Color.white.opacity(0.6))
                                .frame(height: 50)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(8)
            .background(Color.black.opacity(0.1))
            .cornerRadius(12)

            Button("Submit") {
                let correct = Set(highlighted.map { GridPos(r: $0.0, c: $0.1) })
                let correctCount = userGridAnswers.intersection(correct).count
                let wrongCount = userGridAnswers.subtracting(correct).count
                score = max(0, correctCount * 10 - wrongCount * 5)
                
                if correctCount == highlighted.count && wrongCount == 0 {
                    showingCorrectPopup = true
                } else {
                    showingWrongPopup = true
                }
            }
            .buttonStyle(.borderedProminent)

            if showResult {
                Text("Score: \(score)")
                    .font(.title2)
                    .foregroundColor(.green)
                Button("Play Again") { startGame() }
                    .buttonStyle(.bordered)
            }
        }
    }

    private func nextOrRecall() {
        if currentPairIndex + 1 < symmetryPairs.count {
            currentPairIndex += 1
        } else {
            phase = .recall
        }
    }

    private func startGame() {
        var positions: [(Int, Int)] = []
        while positions.count < 4 {
            let pos = (Int.random(in: 0..<gridRows), Int.random(in: 0..<gridCols))
            if !positions.contains(where: { $0.0 == pos.0 && $0.1 == pos.1 }) {
                positions.append(pos)
            }
        }
        highlighted = positions
        symmetryPairs = [
            ("△", "△"),
            ("△", "▽"),
            ("□", "□"),
            ("○", "○"),
        ].shuffled()
        currentPairIndex = 0
        userSymmetryAnswers = []
        userGridAnswers = []
        showResult = false
        phase = .observe
    }
}

//
//  SameRuleView.swift
//  MindSpan
//
//  Capgemini Same Rule Challenge: Mark images that fit the same rules.
//

import SwiftUI

struct SameRuleView: View {

    @State private var examplePair: (String, String) = ("", "")
    @State private var options: [(String, String)] = []
    @State private var correctIndices: Set<Int> = []
    @State private var selectedIndices: Set<Int> = []
    @State private var showResult = false
    @State private var score = 0

    private let shapeIcons = ["square.fill", "circle.fill", "triangle.fill", "diamond.fill", "star.fill"]

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
                    Text("Same Rule")
                        .font(.title2)
                        .bold()

                    Text("Example pair (same rule):")
                        .font(.headline)

                    HStack(spacing: 20) {
                        Image(systemName: examplePair.0)
                            .font(.largeTitle)
                        Text("⇄")
                        Image(systemName: examplePair.1)
                            .font(.largeTitle)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)

                    Text("Tap all pairs that follow the same rule")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if !options.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(Array(options.enumerated()), id: \.offset) { idx, pair in
                                Button {
                                    if selectedIndices.contains(idx) {
                                        selectedIndices.remove(idx)
                                    } else {
                                        selectedIndices.insert(idx)
                                    }
                                } label: {
                                    HStack(spacing: 16) {
                                        Image(systemName: pair.0)
                                            .font(.title2)
                                        Text("⇄")
                                        Image(systemName: pair.1)
                                            .font(.title2)
                                        Spacer()
                                        if showResult {
                                            if correctIndices.contains(idx) {
                                                Image(systemName: selectedIndices.contains(idx) ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                    .foregroundColor(selectedIndices.contains(idx) ? .green : .orange)
                                            } else if selectedIndices.contains(idx) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        } else if selectedIndices.contains(idx) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    .padding()
                                    .background(selectedIndices.contains(idx) ? Color.orange.opacity(0.3) : Color.white.opacity(0.5))
                                    .cornerRadius(12)
                                }
                                .disabled(showResult)
                            }
                        }

                        Button(showResult ? "New Puzzle" : "Check") {
                            if showResult {
                                generatePuzzle()
                            } else {
                                checkAnswer()
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        if showResult {
                            Text("Score: \(score)/\(correctIndices.count)")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
            }
            .onAppear { generatePuzzle() }
        }
    }

    private func generatePuzzle() {
        // Rule: same shape (A, A)
        let s = shapeIcons.randomElement()!
        examplePair = (s, s)
        correctIndices = []
        var opts: [(String, String)] = []
        for i in 0..<4 {
            if Bool.random() {
                let a = shapeIcons.randomElement()!
                opts.append((a, a))
                correctIndices.insert(i)
            } else {
                let a = shapeIcons.randomElement()!
                var b = shapeIcons.randomElement()!
                while b == a { b = shapeIcons.randomElement()! }
                opts.append((a, b))
            }
        }
        options = opts.shuffled()
        correctIndices = Set(options.indices.filter { options[$0].0 == options[$0].1 })
        selectedIndices = []
        showResult = false
        score = 0
    }

    private func checkAnswer() {
        let correct = selectedIndices.intersection(correctIndices).count
        let wrong = selectedIndices.subtracting(correctIndices).count
        let missed = correctIndices.subtracting(selectedIndices).count
        score = max(0, correct * 10 - wrong * 5 - missed * 3)
        showResult = true
    }
}

//
//  SwitchChallengeView.swift
//  MindSpan
//
//  Capgemini Switch Challenge: Shapes run through code, predict output order.
//

import SwiftUI

struct SwitchChallengeView: View {

    enum ShapeType: String, CaseIterable {
        case square = "square.fill"
        case triangle = "triangle.fill"
        case circle = "circle.fill"
        case plus = "plus"
    }

    // Reorder operations: reverse, rotate left, rotate right, swap first two
    enum CodeType: String, CaseIterable {
        case reverse = "Reverse"
        case rotateLeft = "Rotate Left"
        case rotateRight = "Rotate Right"
        case swapFirst = "Swap First Two"
    }

    @State private var inputSequence: [ShapeType] = []
    @State private var options: [[ShapeType]] = []
    @State private var correctIndex = 0
    @State private var selectedIndex: Int? = nil
    @State private var showResult = false

    private let sequenceLength = 4

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
                    Text("Switch Challenge")
                        .font(.title2)
                        .bold()

                    Text("Input sequence ran through a code. Pick the correct output.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    if !inputSequence.isEmpty {
                        HStack(spacing: 12) {
                            Text("Input:")
                                .font(.headline)
                            HStack(spacing: 8) {
                                ForEach(Array(inputSequence.enumerated()), id: \.offset) { _, s in
                                    Image(systemName: s.rawValue)
                                        .font(.title2)
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)

                        Text("Which is the output?")
                            .font(.headline)

                        VStack(spacing: 12) {
                            ForEach(Array(options.enumerated()), id: \.offset) { idx, seq in
                                Button {
                                    selectedIndex = idx
                                    showResult = true
                                } label: {
                                    HStack(spacing: 12) {
                                        ForEach(Array(seq.enumerated()), id: \.offset) { _, s in
                                            Image(systemName: s.rawValue)
                                                .font(.title2)
                                        }
                                        Spacer()
                                        if showResult && selectedIndex == idx {
                                            Image(systemName: idx == correctIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                .foregroundColor(idx == correctIndex ? .green : .red)
                                        }
                                    }
                                    .padding()
                                    .background(selectedIndex == idx ? Color.orange.opacity(0.3) : Color.white.opacity(0.5))
                                    .cornerRadius(12)
                                }
                                .disabled(showResult)
                            }
                        }
                        .padding(.horizontal)

                        if showResult {
                            Button("New Puzzle") {
                                generatePuzzle()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .padding()
            }
            .onAppear { generatePuzzle() }
        }
    }

    private func generatePuzzle() {
        let all = ShapeType.allCases
        inputSequence = (0..<sequenceLength).map { _ in all.randomElement()! }
        let code = CodeType.allCases.randomElement()!
        let output = applyCode(code, to: inputSequence)

        var opts = Set<[ShapeType]>()
        opts.insert(output)
        while opts.count < 3 {
            opts.insert((0..<sequenceLength).map { _ in all.randomElement()! })
        }
        options = Array(opts).shuffled()
        correctIndex = options.firstIndex(where: { $0 == output }) ?? 0
        selectedIndex = nil
        showResult = false
    }

    private func applyCode(_ code: CodeType, to seq: [ShapeType]) -> [ShapeType] {
        switch code {
        case .reverse: return seq.reversed()
        case .rotateLeft: return Array(seq.dropFirst()) + [seq[0]]
        case .rotateRight: return [seq.last!] + Array(seq.dropLast())
        case .swapFirst: return seq.count >= 2 ? [seq[1], seq[0]] + Array(seq.dropFirst(2)) : seq
        }
    }
}

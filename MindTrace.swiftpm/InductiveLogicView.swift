//
//  InductiveLogicView.swift
//  MindSpan
//
//  Capgemini Inductive Logic: Find figures that do not follow the rule.
//

import SwiftUI

struct InductiveLogicView: View {

    enum ShapeRule: String, CaseIterable {
        case allSame = "All same shape"
        case allDifferent = "All different shapes"
        case alternate = "Alternating pattern"
    }

    @State private var rule: ShapeRule = .allSame
    @State private var figures: [[String]] = []
    @State private var wrongIndex = 0
    @State private var selectedIndex: Int? = nil
    @State private var showResult = false

    private let shapeIcons = ["square.fill", "circle.fill", "triangle.fill", "diamond.fill"]

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
                    Text("Inductive Logic")
                        .font(.title2)
                        .bold()

                    Text("Rule: \(rule.rawValue)")
                        .font(.headline)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)

                    Text("Tap the set that does NOT follow the rule")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if !figures.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(Array(figures.enumerated()), id: \.offset) { idx, icons in
                                Button {
                                    selectedIndex = idx
                                    showResult = true
                                } label: {
                                    HStack(spacing: 16) {
                                        ForEach(icons, id: \.self) { icon in
                                            Image(systemName: icon)
                                                .font(.title2)
                                        }
                                        Spacer()
                                        if showResult && selectedIndex == idx {
                                            Image(systemName: idx == wrongIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                .foregroundColor(idx == wrongIndex ? .green : .red)
                                        }
                                    }
                                    .padding()
                                    .background(selectedIndex == idx ? Color.orange.opacity(0.3) : Color.white.opacity(0.5))
                                    .cornerRadius(12)
                                }
                                .disabled(showResult)
                            }
                        }

                        if showResult {
                            Button("New Puzzle") { generatePuzzle() }
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
        rule = ShapeRule.allCases.randomElement()!
        wrongIndex = Int.random(in: 0..<4)
        figures = (0..<4).map { idx in
            if idx == wrongIndex {
                makeWrongSet(for: rule)
            } else {
                makeCorrectSet(for: rule)
            }
        }
        selectedIndex = nil
        showResult = false
    }

    private func makeCorrectSet(for r: ShapeRule) -> [String] {
        switch r {
        case .allSame:
            let s = shapeIcons.randomElement()!
            return [s, s, s]
        case .allDifferent:
            return Array(shapeIcons.shuffled().prefix(3))
        case .alternate:
            let a = shapeIcons.randomElement()!
            var b = shapeIcons.randomElement()!
            while b == a { b = shapeIcons.randomElement()! }
            return [a, b, a]
        }
    }

    private func makeWrongSet(for r: ShapeRule) -> [String] {
        switch r {
        case .allSame:
            return Array(shapeIcons.shuffled().prefix(3))
        case .allDifferent:
            let s = shapeIcons.randomElement()!
            return [s, s, s]
        case .alternate:
            let a = shapeIcons.randomElement()!
            return [a, a, a]
        }
    }
}

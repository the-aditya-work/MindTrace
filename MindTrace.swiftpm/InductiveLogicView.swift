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
    
    @State private var score = 0
    @State private var feedbackText: String? = nil
    @State private var showWhy = false

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
                    
                    if let fb = feedbackText {
                        Text(fb)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(fb.contains("Correct") ? .green : .red)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                    }
                    
                    HStack {
                        Text("Score: \(score)")
                            .font(.headline)
                        Spacer()
                        Button("Reset Score") {
                            score = 0
                        }
                        .buttonStyle(.bordered)
                    }

                    if !figures.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(Array(figures.enumerated()), id: \.offset) { idx, icons in
                                Button {
                                    if !showResult {
                                        selectedIndex = idx
                                        showResult = true
                                        if idx == wrongIndex {
                                            score += 10
                                            feedbackText = "Correct! +10"
                                        } else {
                                            score -= 5
                                            feedbackText = "Incorrect -5"
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                            feedbackText = nil
                                        }
                                    }
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
                            HStack(spacing: 12) {
                                Button("New Puzzle") { generatePuzzle() }
                                    .buttonStyle(.borderedProminent)
                                Button("Why?") { showWhy = true }
                                    .buttonStyle(.bordered)
                            }
                            Text("Scoring: +10 correct, -5 incorrect")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .onAppear { generatePuzzle() }
            .sheet(isPresented: $showWhy) { whySheet }
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
        feedbackText = nil
        showWhy = false
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
    
    private func ruleDescription(_ r: ShapeRule) -> String {
        switch r {
        case .allSame:
            return "All three shapes should be identical (e.g., circle, circle, circle)."
        case .allDifferent:
            return "All three shapes should be different — no repeats."
        case .alternate:
            return "Pattern should alternate like A–B–A (first and third same, middle different)."
        }
    }
    
    private func followsRule(_ set: [String], for r: ShapeRule) -> Bool {
        switch r {
        case .allSame:
            return Set(set).count == 1
        case .allDifferent:
            return Set(set).count == set.count
        case .alternate:
            guard set.count == 3 else { return false }
            return set[0] == set[2] && set[1] != set[0]
        }
    }
    
    private var whySheet: some View {
        VStack(spacing: 16) {
            Text("Why?")
                .font(.title2.bold())
            Text("Rule: \(rule.rawValue)")
                .font(.headline)
            Text(ruleDescription(rule))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Divider()
            
            Text("Correct answer: Set #\(wrongIndex + 1) breaks the rule.")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(figures.enumerated()), id: \.offset) { idx, icons in
                    HStack(spacing: 10) {
                        HStack(spacing: 8) {
                            ForEach(icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.body)
                            }
                        }
                        Spacer()
                        let ok = followsRule(icons, for: rule)
                        Text(ok ? "Follows" : "Breaks")
                            .font(.caption)
                            .foregroundColor(ok ? .green : .red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(8)
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            
            Button("Close") { showWhy = false }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

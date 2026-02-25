//
//  File.swift
//  MindSpan
//
//  Created by Aditya Rai on 16/02/26.
//  Geo-Sudo: levels 4→6→8 blanks, tap to change, skip.
//

import SwiftUI

struct DeductiveLogicGameView: View {

    @EnvironmentObject private var gameResultManager: GameResultManager
    @State private var summaryVisible = false
    @State private var runStart = Date()
    @State private var lastAccuracy: Double = 0
    @State private var lastScore: Int = 0

    // MARK: - Shape Model
    enum ShapeType: CaseIterable {
        case square, triangle, circle, plus

        var icon: String {
            switch self {
            case .square: return "square.fill"
            case .triangle: return "triangle.fill"
            case .circle: return "circle.fill"
            case .plus: return "plus"
            }
        }
    }

    // MARK: - Properties
    let gridSize = 4
    /// Level 1 = 4 blanks, Level 2 = 6, Level 3 = 8 (progressively harder)
    private static let blanksForLevel = [1: 4, 2: 6, 3: 8]

    @State private var level = 1
    @State private var grid: [[ShapeType?]] = []
    @State private var correctAnswers: [GridPos: ShapeType] = [:]
    @State private var userAnswers: [GridPos: ShapeType] = [:]
    @State private var selectedPos: GridPos?
    @State private var showResult = false
    @State private var showingCorrectPopup = false
    @State private var showingWrongPopup = false

    private struct GridPos: Hashable {
        let r: Int
        let c: Int
    }

    private var blankCountForCurrentLevel: Int {
        Self.blanksForLevel[level] ?? 8
    }

    // MARK: - Init (SAFE)
    init() {
        _grid = State(initialValue: [])
    }

    // MARK: - Body
    var body: some View {

        ZStack {
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.3),
                    Color.blue.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 25) {

                Text("Geo-Sudo Challenge")
                    .font(.title2)
                    .bold()

                Text("Level \(level) • \(blankCountForCurrentLevel) blanks")
                    .font(.headline)
                    .foregroundColor(.orange)

                Text("One shape per row & column. Tap blank to fill; tap filled to change.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                if !grid.isEmpty {
                    gridView
                }

                if selectedPos != nil {
                    Text("Tap a shape to fill → or tap cell again to deselect")
                        .font(.caption)
                        .foregroundColor(.orange)
                }

                optionsView

                HStack(spacing: 16) {
                    if !showResult {
                        Button("Skip") {
                            skipPuzzle()
                        }
                        .buttonStyle(.bordered)
                    }
                    if allFilled && !showResult {
                        Button("Check") {
                            checkAllAnswers()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                if showResult {
                    resultView
                }
            }
            .padding()
        }
        .navigationTitle("Geo-Sudo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Finish") {
                    recordAndShowSummary()
                }
            }
        }
        .onAppear {
            runStart = Date()
            generatePuzzle()
        }
        .sheet(isPresented: $summaryVisible) {
            GameSummaryView(
                gameName: "Geo-Sudo Challenge",
                levelReached: level,
                accuracy: lastAccuracy,
                avgResponseTime: Date().timeIntervalSince(runStart),
                totalTime: Date().timeIntervalSince(runStart),
                score: lastScore
            ) {
                level = 1
                generatePuzzle()
                summaryVisible = false
            } onDone: {
                summaryVisible = false
            }
        }
        .sheet(isPresented: $showingCorrectPopup) {
            CorrectAnswerPopup {
                if level < 3 { level += 1 }
                generatePuzzle()
                showingCorrectPopup = false
            }
        }
        .sheet(isPresented: $showingWrongPopup) {
            WrongAnswerPopup {
                userAnswers = [:]
                // Rebuild the grid by clearing only the originally blank cells
                grid = grid.enumerated().map { r, row in
                    row.enumerated().map { c, cell in
                        let pos = GridPos(r: r, c: c)
                        if correctAnswers.keys.contains(pos) {
                            // This cell was originally a blank; clear it
                            return nil
                        } else {
                            // This cell was a given; keep its original value
                            return cell
                        }
                    }
                }
                showingWrongPopup = false
            }
        }
    }

    private var allFilled: Bool {
        userAnswers.count == correctAnswers.count
    }
}

// MARK: - Puzzle Logic
extension DeductiveLogicGameView {

    func generatePuzzle() {

        // Valid Latin square pattern (4x4)
        let base: [[ShapeType]] = [
            [.square, .triangle, .circle, .plus],
            [.triangle, .circle, .plus, .square],
            [.circle, .plus, .square, .triangle],
            [.plus, .square, .triangle, .circle]
        ]

        grid = base.map { $0.map { Optional($0) } }

        let blankCount = blankCountForCurrentLevel
        var positions: Set<GridPos> = []
        while positions.count < blankCount {
            positions.insert(GridPos(r: Int.random(in: 0..<gridSize), c: Int.random(in: 0..<gridSize)))
        }

        correctAnswers = [:]
        for pos in positions {
            correctAnswers[pos] = grid[pos.r][pos.c]
            grid[pos.r][pos.c] = nil
        }

        userAnswers = [:]
        selectedPos = nil
        showResult = false
    }

    func skipPuzzle() {
        generatePuzzle()
    }

    func fillSelectedCell(_ shape: ShapeType) {
        guard let pos = selectedPos else { return }
        userAnswers[pos] = shape
        grid[pos.r][pos.c] = shape
        selectedPos = nil
    }

    private func clearCell(_ pos: GridPos) {
        guard correctAnswers[pos] != nil else { return }
        userAnswers[pos] = nil
        grid[pos.r][pos.c] = nil
        if selectedPos == pos { selectedPos = nil }
    }

    func checkAllAnswers() {
        let total = correctAnswers.count
        let correct = userAnswers.filter { correctAnswers[$0.key] == $0.value }.count
        lastAccuracy = total == 0 ? 0 : (Double(correct) / Double(total)) * 100
        lastScore = Int(round(lastAccuracy)) * max(1, level)
        
        if allCorrect {
            showingCorrectPopup = true
        } else {
            showingWrongPopup = true
        }
    }

    func levelUp() {
        if level < 3 { level += 1 }
    }

    var allCorrect: Bool {
        userAnswers.count == correctAnswers.count &&
        userAnswers.allSatisfy { correctAnswers[$0.key] == $0.value }
    }

    private func recordResult() {
        gameResultManager.record(
            gameName: "Geo-Sudo Challenge",
            maxLevelReached: level,
            accuracy: lastAccuracy,
            avgResponseTime: Date().timeIntervalSince(runStart),
            totalScore: lastScore
        )
    }

    private func recordAndShowSummary() {
        if lastScore == 0 {
            // If user finishes without pressing Check, approximate accuracy
            let total = correctAnswers.count
            let correct = userAnswers.filter { correctAnswers[$0.key] == $0.value }.count
            lastAccuracy = total == 0 ? 0 : (Double(correct) / Double(total)) * 100
            lastScore = Int(round(lastAccuracy)) * max(1, level)
        }
        recordResult()
        summaryVisible = true
    }
}

// MARK: - Grid View
extension DeductiveLogicGameView {

    var gridView: some View {
        VStack(spacing: 10) {

            ForEach(grid.indices, id: \.self) { row in
                HStack(spacing: 10) {

                    ForEach(grid[row].indices, id: \.self) { col in
                        let pos = GridPos(r: row, c: col)
                        let isBlank = correctAnswers[pos] != nil
                        let isEmpty = grid[row][col] == nil
                        let isSelected = selectedPos == pos

                        Button {
                            if showResult { return }
                            if !isBlank { return }
                            if isEmpty {
                                selectedPos = isSelected ? nil : pos
                            } else {
                                clearCell(pos)
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? Color.orange.opacity(0.5) : Color.white.opacity(0.85))
                                .frame(width: 65, height: 65)
                                .overlay {
                                    if let shape = grid[row][col] {
                                        Image(systemName: shape.icon)
                                            .font(.title2)
                                    } else {
                                        Text("?")
                                            .font(.title)
                                            .bold()
                                    }
                                }
                                .overlay {
                                    if isSelected {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.orange, lineWidth: 3)
                                    }
                                }
                                .overlay {
                                    if isBlank && !isEmpty {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                                    }
                                }
                                .shadow(radius: 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Options
extension DeductiveLogicGameView {

    var optionsView: some View {
        HStack(spacing: 20) {

            ForEach(ShapeType.allCases, id: \.self) { shape in

                Button {
                    if showResult {
                        return
                    }
                    if selectedPos != nil {
                        fillSelectedCell(shape)
                    }
                } label: {
                    Image(systemName: shape.icon)
                        .font(.title2)
                        .frame(width: 60, height: 60)
                        .background(selectedPos != nil ? Color.orange.opacity(0.3) : Color.white.opacity(0.5))
                        .cornerRadius(12)
                }
                .disabled(selectedPos == nil)
            }
        }
    }
}

// MARK: - Result View
extension DeductiveLogicGameView {

    var resultView: some View {
        VStack(spacing: 15) {

            if allCorrect {

                Text("Correct Deduction!")
                    .foregroundColor(.green)
                    .bold()

                if level < 3 {
                    Text("Level \(level) → \(level + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

            } else {

                Text("Incorrect. Each row & column must have all 4 shapes.")
                    .foregroundColor(.orange)
                    .bold()
                    .multilineTextAlignment(.center)
            }

            Button(allCorrect && level < 3 ? "Next Level" : "New Puzzle") {
                if allCorrect { levelUp() }
                generatePuzzle()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

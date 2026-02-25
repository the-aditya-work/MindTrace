//
//  MotionChallengeView.swift
//  MindSpan
//
//  Capgemini Motion Challenge: Navigate ball to hole in fewest moves.
//

import SwiftUI

struct MotionChallengeView: View {

    enum Cell: String {
        case empty = "."
        case ball = "●"
        case hole = "○"
        case wall = "▓"
        case movable = "□"
    }

    @State private var level: Int = 1
    private var gridSize: Int {
        min(7, 5 + (level - 1) / 2)
    }
    @State private var grid: [[Cell]] = []
    @State private var ballPos: (Int, Int) = (0, 0)
    @State private var holePos: (Int, Int) = (0, 0)
    @State private var moves = 0
    @State private var showWin = false
    @State private var showSummary = false
    @State private var runStart = Date()
    @State private var lastScore: Int = 0

    @EnvironmentObject private var gameResultManager: GameResultManager

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.indigo.opacity(0.3), Color.blue.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Motion Challenge")
                    .font(.title2)
                    .bold()

                Text("Tap direction to move the ball to the hole.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if !grid.isEmpty {
                    Text("Moves: \(moves)")
                        .font(.headline)

                    VStack(spacing: 4) {
                        ForEach(0..<gridSize, id: \.self) { r in
                            HStack(spacing: 4) {
                                ForEach(0..<gridSize, id: \.self) { c in
                                    cellView(r: r, c: c)
                                }
                            }
                        }
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.15))
                    .cornerRadius(12)

                    HStack(spacing: 16) {
                        ForEach([("arrow.up", -1, 0), ("arrow.down", 1, 0), ("arrow.left", 0, -1), ("arrow.right", 0, 1)], id: \.0) { dir in
                            Button {
                                move(dr: dir.1, dc: dir.2)
                            } label: {
                                Image(systemName: dir.0)
                                    .font(.title)
                                    .frame(width: 50, height: 50)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(12)
                            }
                        }
                    }

                    if showWin {
                        Text("You won in \(moves) moves!")
                            .foregroundColor(.green)
                            .bold()
                        Button("Play Again") {
                            level = min(level + 1, 10)
                            generateMaze()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Reset") {
                            generateMaze()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                Spacer()
            }
            .padding()
            .onAppear {
                runStart = Date()
                generateMaze()
            }
        }
        .navigationTitle("Motion Challenge")
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
                gameName: "Motion Challenge",
                levelReached: level,
                accuracy: 100,
                avgResponseTime: Date().timeIntervalSince(runStart),
                totalTime: Date().timeIntervalSince(runStart),
                score: lastScore
            ) {
                level = 1
                generateMaze()
                runStart = Date()
                showSummary = false
            } onDone: {
                showSummary = false
            }
        }
    }

    private func cellView(r: Int, c: Int) -> some View {
        let cell: Cell = (r, c) == ballPos ? .ball : (r, c) == holePos ? .hole : grid[r][c]
        return Text(cellSymbol(cell))
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(colorFor(cell))
            .frame(width: 44, height: 44)
            .background(Color.white.opacity(0.8))
            .cornerRadius(6)
    }

    private func cellSymbol(_ cell: Cell) -> String {
        switch cell {
        case .empty: return ""
        case .ball: return "●"
        case .hole: return "○"
        case .wall: return "▓"
        case .movable: return "□"
        }
    }

    private func colorFor(_ cell: Cell) -> Color {
        switch cell {
        case .empty: return .clear
        case .ball: return .red
        case .hole: return .green
        case .wall: return .gray
        case .movable: return .orange.opacity(0.6)
        }
    }

    private func generateMaze() {
        grid = (0..<gridSize).map { _ in (0..<gridSize).map { _ in .empty } }
        grid[0][0] = .empty
        grid[gridSize-1][gridSize-1] = .empty
        ballPos = (0, 0)
        holePos = (gridSize-1, gridSize-1)
        for r in 0..<gridSize {
            for c in 0..<gridSize {
                if (r, c) != ballPos && (r, c) != holePos && Bool.random() && Bool.random() {
                    grid[r][c] = .wall
                }
            }
        }
        grid[0][0] = .empty
        grid[gridSize-1][gridSize-1] = .empty
        moves = 0
        showWin = false
    }

    private func move(dr: Int, dc: Int) {
        let (r, c) = ballPos
        var nr = r + dr
        var nc = c + dc
        while nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize {
            if grid[nr][nc] == .wall { break }
            if grid[nr][nc] == .hole {
                ballPos = (nr, nc)
                moves += 1
                showWin = true
                lastScore = max(10, 200 - moves * 10)
                gameResultManager.record(
                    gameName: "Motion Challenge",
                    maxLevelReached: level,
                    accuracy: 100,
                    avgResponseTime: Date().timeIntervalSince(runStart),
                    totalScore: lastScore
                )
                return
            }
            if grid[nr][nc] == .empty || grid[nr][nc] == .movable {
                ballPos = (nr, nc)
                moves += 1
                return
            }
            nr += dr
            nc += dc
        }
    }

    private func finishRun() {
        if lastScore == 0 {
            lastScore = max(0, 150 - moves * 10)
        }
        gameResultManager.record(
            gameName: "Motion Challenge",
            maxLevelReached: level,
            accuracy: 100,
            avgResponseTime: Date().timeIntervalSince(runStart),
            totalScore: lastScore
        )
        showSummary = true
    }
}


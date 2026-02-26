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
    @State private var showSuccessModal = false
    @State private var showWrongModal = false
    @State private var runStart = Date()
    @State private var lastScore: Int = 0
    @State private var gamePlayed: Bool = false
    @State private var minimumMoves: Int = 0
    @State private var completedMoves: Int = 0
    @State private var completionTime: Date = Date()

    @EnvironmentObject private var gameResultManager: GameResultManager

    private var timeBonus: Double {
        // Provide a simple time-based bonus: faster completions yield higher bonus up to 1.0
        // If game hasn't been played, neutral bonus of 1.0
        guard gamePlayed else { return 1.0 }
        let elapsed = completionTime.timeIntervalSince(runStart)
        // Target time window: 5 to 60 seconds; map to 1.2 .. 0.8 range and clamp
        let maxBonus: Double = 1.2
        let minBonus: Double = 0.8
        let fast: Double = 5
        let slow: Double = 60
        let t = max(min((elapsed - fast) / (slow - fast), 1.0), 0.0)
        return max(minBonus, min(maxBonus, maxBonus - (maxBonus - minBonus) * t))
    }

    var body: some View {
        ZStack {
            let backgroundGradient = LinearGradient(colors: [Color.indigo.opacity(0.3), Color.blue.opacity(0.2)], startPoint: .top, endPoint: .bottom)
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Let's start Motion Challenge...")
                    .font(.subheadline)
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
        .overlay(
            // Success Modal
            Group {
                if showSuccessModal {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showSuccessModal = false
                        }
                    
                    successModalView
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Wrong Answer Modal
                if showWrongModal {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showWrongModal = false
                        }
                    
                    wrongModalView
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
        .animation(.easeInOut(duration: 0.3), value: showSuccessModal)
        .animation(.easeInOut(duration: 0.3), value: showWrongModal)
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
                accuracy: calculateAccuracy(),
                avgResponseTime: gamePlayed ? completionTime.timeIntervalSince(runStart) : Date().timeIntervalSince(runStart),
                totalTime: gamePlayed ? completionTime.timeIntervalSince(runStart) : Date().timeIntervalSince(runStart),
                score: min(100, calculateScore())
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
        minimumMoves = calculateMinimumMoves()
        gamePlayed = false
        completedMoves = 0
        print("🔄 New maze generated: minimumMoves = \(minimumMoves)")
    }

    private func move(dr: Int, dc: Int) {
        if !gamePlayed {
            gamePlayed = true
            runStart = Date()
        }
        let (r, c) = ballPos
        var nr = r + dr
        var nc = c + dc
        while nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize {
            if grid[nr][nc] == .wall { break }
            if grid[nr][nc] == .hole || (nr, nc) == holePos {
                ballPos = (nr, nc)
                moves += 1
                completedMoves = moves // Use current moves count
                showWin = true
                completionTime = Date()
                print("🎯 Ball reached hole! moves = \(moves), completedMoves = \(completedMoves)")
                return
            }
            if grid[nr][nc] == .empty || grid[nr][nc] == .movable {
                ballPos = (nr, nc)
                moves += 1
                completedMoves = moves // Keep completedMoves in sync with moves
                return
            }
            nr += dr
            nc += dc
        }
    }

    private func finishRun() {
        print("🏁 Finish clicked: gamePlayed = \(gamePlayed), completedMoves = \(completedMoves)")
        
        if !gamePlayed || completedMoves == 0 {
            lastScore = 0
        } else {
            lastScore = calculateScore()
        }
        
        let accuracy = calculateAccuracy()
        let avgTime = gamePlayed ? completionTime.timeIntervalSince(runStart) : Date().timeIntervalSince(runStart)
        
        print("📊 Final: accuracy = \(accuracy)%, score = \(lastScore)")
        
        gameResultManager.record(
            gameName: "Motion Challenge",
            maxLevelReached: level,
            accuracy: accuracy,
            avgResponseTime: avgTime,
            totalScore: lastScore
        )
        showSummary = true
    }
    
    private func calculateMinimumMoves() -> Int {
        // Simple BFS to find minimum moves from ball to hole
        var queue: [(Int, Int, Int)] = [(ballPos.0, ballPos.1, 0)]
        var visited = Set<String>()
        visited.insert("\(ballPos.0),\(ballPos.1)")
        
        while !queue.isEmpty {
            let (r, c, dist) = queue.removeFirst()
            if (r, c) == holePos {
                return dist
            }
            
            for (dr, dc) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                var nr = r + dr
                var nc = c + dc
                while nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize {
                    if grid[nr][nc] == .wall { break }
                    let key = "\(nr),\(nc)"
                    if !visited.contains(key) {
                        visited.insert(key)
                        queue.append((nr, nc, dist + 1))
                    }
                    nr += dr
                    nc += dc
                }
            }
        }
        return gridSize * 2 // fallback
    }
    
    private func calculateAccuracy() -> Double {
        if !gamePlayed || completedMoves == 0 {
            return 0.0
        }
        
        // Simple logic: Compare your moves with shortest possible moves
        let efficiency = minimumMoves > 0 ? Double(minimumMoves) / Double(completedMoves) : 1.0
        let accuracy = efficiency * 100.0
        
        print("🎯 Simple Logic: Your moves = \(completedMoves), Shortest = \(minimumMoves), Accuracy = \(accuracy)%")
        return min(100.0, accuracy)
    }
    
    private func calculateScore() -> Int {
        if !gamePlayed || completedMoves == 0 {
            return 0
        }
        
        // Simple logic: Score based on how close to shortest path
        let efficiency = minimumMoves > 0 ? Double(minimumMoves) / Double(completedMoves) : 1.0
        let score = Int(min(100.0, efficiency * 100.0 * timeBonus))
        
        print(" Simple Score: Your moves = \(completedMoves), Shortest = \(minimumMoves), Score = \(score)")
        return min(100, score)
    }
    
    private var wrongModalView: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Wrong Icon
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "xmark.octagon.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.red)
                }
                .scaleEffect(showSuccessModal ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuccessModal)
                
                VStack(spacing: 8) {
                    Text("Try again")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text("Not quite there. Keep going!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 16) {
                    Button("Try Again") {
                        showSuccessModal = false
                        generateMaze()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Move Next") {
                        showSuccessModal = false
                        level = min(level + 1, 10)
                        generateMaze()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.3), Color.clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .frame(maxWidth: 320)
        }
    }

    private var successModalView: some View {
        ZStack {
            Color.clear // background handled by overlay dimmer
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.green)
                }
                .scaleEffect(showSuccessModal ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuccessModal)

                VStack(spacing: 8) {
                    Text("You are right!")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    Text("Target reached in \(moves) moves!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Score: \(calculateScore())")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.blue)
                }

                HStack(spacing: 16) {
                    Button("Try Again") {
                        showSuccessModal = false
                        generateMaze()
                    }
                    .buttonStyle(.bordered)

                    Button("Move Next") {
                        showSuccessModal = false
                        level = min(level + 1, 10)
                        generateMaze()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.3), Color.clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .frame(maxWidth: 320)
        }
    }
}


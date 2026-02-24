import SwiftUI

struct BFSPathGameView: View {
    private let rows = 7
    private let cols = 9

    @State private var grid: [[Cell]] = []
    @State private var start: Point = Point(r: 0, c: 0)
    @State private var goal: Point = Point(r: 6, c: 8)
    @State private var userPath: [Point] = []
    @State private var showResult = false
    @State private var showExplanation = false
    @State private var explanation = ""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.indigo.opacity(0.35), Color.purple.opacity(0.25), Color.blue.opacity(0.20)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("BFS vs DFS Explorer")
                    .font(.title2.bold())

                Text("Draw a path from start to goal avoiding walls. Then compare with BFS shortest path.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                gridView

                HStack(spacing: 12) {
                    Button(showResult ? "New Maze" : "Check") {
                        if showResult { seedMaze() } else { evaluate() }
                    }
                    .buttonStyle(.borderedProminent)

                    if showResult {
                        Button("Why?") { showExplanation = true }
                            .buttonStyle(.bordered)
                            .popover(isPresented: $showExplanation) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("BFS vs DFS")
                                        .font(.headline)
                                    Text(explanation)
                                        .font(.subheadline)
                                    Text("Concepts:")
                                        .font(.subheadline.weight(.semibold))
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("• BFS explores in waves and finds a shortest path in an unweighted grid")
                                        Text("• DFS dives deep first and does not guarantee shortest path")
                                        Text("• Traversal order changes which path you get")
                                    }
                                    Button("Close") { showResult = false }
                                        .buttonStyle(.borderedProminent)
                                }
                                .padding()
                                .frame(maxWidth: 360)
                            }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .onAppear { seedMaze() }
        }
    }

    private var gridView: some View {
        VStack(spacing: 6) {
            ForEach(0..<rows, id: \.self) { r in
                HStack(spacing: 6) {
                    ForEach(0..<cols, id: \.self) { c in
                        cellView(r, c)
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15))
        )
    }

    private func cellView(_ r: Int, _ c: Int) -> some View {
        let p = Point(r: r, c: c)
        let isStart = p == start
        let isGoal = p == goal
        let isWall = grid[safe: r]?[safe: c] == .wall
        let inPath = userPath.contains(p)
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(isWall ? Color.gray.opacity(0.6) : Color.white.opacity(0.85))
                .frame(width: 32, height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(inPath ? Color.orange : Color.white.opacity(0.4), lineWidth: inPath ? 3 : 1)
                )
                .onTapGesture {
                    togglePath(p)
                }

            if isStart {
                Image(systemName: "play.circle.fill")
                    .foregroundStyle(.green)
            }
            if isGoal {
                Image(systemName: "flag.checkered")
                    .foregroundStyle(.purple)
            }
        }
    }

    private func seedMaze() {
        grid = (0..<rows).map { _ in (0..<cols).map { _ in Bool.random() && Bool.random() ? Cell.wall : Cell.empty } }
        start = Point(r: Int.random(in: 0..<rows), c: 0)
        goal = Point(r: Int.random(in: 0..<rows), c: cols - 1)
        grid[start.r][start.c] = .empty
        grid[goal.r][goal.c] = .empty
        userPath = []
        showResult = false
        showExplanation = false
        explanation = ""
    }

    private func togglePath(_ p: Point) {
        guard grid[p.r][p.c] != .wall else { return }
        if let idx = userPath.firstIndex(of: p) {
            userPath.remove(at: idx)
        } else {
            userPath.append(p)
        }
    }

    private func evaluate() {
        // Validate user's path connectivity from start to goal (4-neighbors)
        guard !userPath.isEmpty else {
            explanation = "Draw a path by tapping cells from start to goal."
            showResult = true
            return
        }
        guard userPath.first == start && userPath.last == goal else {
            explanation = "Start your path at the green start and end at the checkered flag."
            showResult = true
            return
        }
        for i in 1..<userPath.count {
            let a = userPath[i-1], b = userPath[i]
            let dr = abs(a.r - b.r), dc = abs(a.c - b.c)
            if dr + dc != 1 { explanation = "Move one step at a time (up/down/left/right)."; showResult = true; return }
            if grid[b.r][b.c] == .wall { explanation = "Avoid walls (gray cells)."; showResult = true; return }
        }

        let bfs = bfsShortestPath()
        if bfs.isEmpty {
            explanation = "There is no path in this maze. BFS also couldn't find one."
        } else {
            if bfs.count == userPath.count {
                explanation = "Nice! Your path length (\(userPath.count)) matches the BFS shortest path. BFS explores in waves to guarantee minimal steps. DFS may find longer paths."
            } else if bfs.count < userPath.count {
                explanation = "Close. Your path has \(userPath.count) steps; BFS found a shorter one with \(bfs.count). BFS guarantees a shortest path in an unweighted grid."
            } else {
                explanation = "Interesting—your path (\(userPath.count)) is shorter than our BFS result (\(bfs.count)). Double-check; typically BFS gives a shortest path."
            }
        }
        showResult = true
    }

    private func bfsShortestPath() -> [Point] {
        var visited = Array(repeating: Array(repeating: false, count: cols), count: rows)
        var parent: [Point: Point] = [:]
        var queue: [Point] = [start]
        visited[start.r][start.c] = true
        let dirs = [(-1,0),(1,0),(0,-1),(0,1)]
        var head = 0
        while head < queue.count {
            let cur = queue[head]; head += 1
            if cur == goal { break }
            for d in dirs {
                let nr = cur.r + d.0, nc = cur.c + d.1
                if nr < 0 || nr >= rows || nc < 0 || nc >= cols { continue }
                if visited[nr][nc] { continue }
                if grid[nr][nc] == .wall { continue }
                visited[nr][nc] = true
                let np = Point(r: nr, c: nc)
                parent[np] = cur
                queue.append(np)
            }
        }
        // Reconstruct
        var path: [Point] = []
        var cur: Point? = goal
        while let p = cur {
            path.append(p)
            if p == start { break }
            cur = parent[p]
        }
        path.reverse()
        if path.first != start || path.last != goal { return [] }
        return path
    }
}

fileprivate enum Cell { case empty, wall }
fileprivate struct Point: Hashable, Equatable { let r: Int; let c: Int }

private extension Array {
    subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil }
}

#Preview {
    BFSPathGameView()
}

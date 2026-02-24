import SwiftUI

// MARK: - Disjoint Set Union (Union-Find)
fileprivate struct DSU {
    private var parent: [Int]
    private var rank: [Int]

    init(n: Int) {
        parent = Array(0..<n)
        rank = Array(repeating: 0, count: n)
    }

    mutating func find(_ x: Int) -> Int {
        if parent[x] == x { return x }
        parent[x] = find(parent[x])
        return parent[x]
    }

    mutating func union(_ a: Int, _ b: Int) -> Bool {
        var ra = find(a), rb = find(b)
        if ra == rb { return false }
        if rank[ra] < rank[rb] { swap(&ra, &rb) }
        parent[rb] = ra
        if rank[ra] == rank[rb] { rank[ra] += 1 }
        return true
    }
}

// MARK: - Edge Model
fileprivate struct Edge: Identifiable, Hashable {
    let id = UUID()
    let u: Int
    let v: Int
    let w: Int
}

struct MSTBuilderView: View {
    @State private var nodes: [CGPoint] = []
    @State private var edges: [Edge] = []
    @State private var selected: Set<Edge> = []
    @State private var targetWeight: Int = 0
    @State private var userWeight: Int = 0
    @State private var showResult = false
    @State private var showExplanation = false
    @State private var explanation: String = ""

    private let nodeCount = 6

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.indigo.opacity(0.35), Color.purple.opacity(0.25), Color.blue.opacity(0.20)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Build the MST")
                    .font(.title2.bold())

                Text("Select edges with minimum total weight that keep the graph connected without cycles.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                graphCanvas
                    .frame(height: 320)

                HStack(spacing: 12) {
                    Text("Your total: \(userWeight)")
                        .font(.headline)
                    Spacer()
                    if showResult {
                        Text("Optimal: \(targetWeight)")
                            .font(.headline)
                            .foregroundStyle(.green)
                    }
                }

                HStack(spacing: 12) {
                    Button(showResult ? "New Graph" : "Check") {
                        if showResult {
                            seedGraph()
                        } else {
                            evaluate()
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    if showResult {
                        Button("Why?") { showExplanation = true }
                        .buttonStyle(.bordered)
                        .popover(isPresented: $showExplanation) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Kruskal + DSU (Union-Find)")
                                    .font(.headline)
                                Text(explanation)
                                    .font(.subheadline)
                                Text("Concepts:")
                                    .font(.subheadline.weight(.semibold))
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("• Greedy choice: pick smallest edge that doesn't form a cycle")
                                    Text("• DSU detects cycles using union & find with path compression")
                                    Text("• Minimum Spanning Tree connects all nodes with minimal total weight")
                                }
                                Button("Close") { showExplanation = false }
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
            .onAppear { seedGraph() }
        }
    }

    private var graphCanvas: some View {
        GeometryReader { proxy in
            ZStack {
                // Draw edges
                ForEach(edges) { e in
                    let p1 = nodes[e.u]
                    let p2 = nodes[e.v]
                    Path { path in
                        path.move(to: p1)
                        path.addLine(to: p2)
                    }
                    .stroke(selected.contains(e) ? Color.orange : Color.white.opacity(0.6), lineWidth: selected.contains(e) ? 4 : 2)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleEdge(e)
                    }

                    // Weight label
                    let mid = CGPoint(x: (p1.x + p2.x)/2, y: (p1.y + p2.y)/2)
                    Text("\(e.w)")
                        .font(.caption.bold())
                        .padding(4)
                        .background(.ultraThinMaterial, in: Capsule())
                        .position(mid)
                }

                // Draw nodes
                ForEach(nodes.indices, id: \.self) { i in
                    Circle()
                        .fill(Color.mint)
                        .frame(width: 24, height: 24)
                        .overlay(Text("\(i)").font(.caption2.bold()).foregroundColor(.black.opacity(0.7)))
                        .position(nodes[i])
                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15))
            )
            .onAppear {
                if nodes.isEmpty { layout(in: proxy.size) }
            }
        }
    }

    private func layout(in size: CGSize) {
        var pts: [CGPoint] = []
        let w = size.width, h = size.height
        for i in 0..<nodeCount {
            let angle = Double(i) / Double(nodeCount) * 2 * Double.pi
            let r = min(w, h) * 0.36
            let cx = w/2 + CGFloat(cos(angle)) * r
            let cy = h/2 + CGFloat(sin(angle)) * r
            pts.append(CGPoint(x: cx, y: cy))
        }
        nodes = pts
    }

    private func seedGraph() {
        // Create a connected graph with random weights
        var es: Set<Edge> = []
        func add(_ u: Int, _ v: Int, _ w: Int) { es.insert(Edge(u: min(u,v), v: max(u,v), w: w)) }
        // base cycle
        for i in 0..<nodeCount { add(i, (i+1)%nodeCount, Int.random(in: 1...9)) }
        // chords
        add(0, 3, Int.random(in: 2...9))
        add(1, 4, Int.random(in: 2...9))
        add(2, 5, Int.random(in: 2...9))
        edges = Array(es)
        selected = []
        userWeight = 0
        showResult = false
        explanation = ""
        showExplanation = false
        targetWeight = computeMSTWeight()
    }

    private func toggleEdge(_ e: Edge) {
        if selected.contains(e) {
            selected.remove(e)
            userWeight -= e.w
        } else {
            selected.insert(e)
            userWeight += e.w
        }
    }

    private func evaluate() {
        // Check connectivity and acyclicity via DSU
        var dsu = DSU(n: nodeCount)
        var count = 0
        for e in selected.sorted(by: { $0.w < $1.w }) {
            if dsu.union(e.u, e.v) {
                count += 1
            } else {
                // formed a cycle
                explanation = "You formed a cycle. In Kruskal's algorithm, we skip edges that connect nodes already in the same set."
                showResult = true
                return
            }
        }
        if count != nodeCount - 1 {
            explanation = "Your selection doesn't connect all nodes. An MST must connect all nodes with exactly n-1 edges."
            showResult = true
            return
        }

        if userWeight == targetWeight {
            explanation = "Perfect! You matched the optimal total weight using the greedy choice + DSU cycle checks."
        } else if userWeight < targetWeight {
            explanation = "Interesting—you found a tree lighter than our computed MST. Double-check weights; typically MST has minimal possible weight."
        } else {
            explanation = "Close! There's a lighter combination. Kruskal picks edges from smallest to largest, skipping those that make cycles."
        }
        showResult = true
    }

    private func computeMSTWeight() -> Int {
        // Kruskal
        var dsu = DSU(n: nodeCount)
        var total = 0
        var used = 0
        for e in edges.sorted(by: { $0.w < $1.w }) {
            if dsu.union(e.u, e.v) {
                total += e.w
                used += 1
                if used == nodeCount - 1 { break }
            }
        }
        return total
    }
}

#Preview {
    MSTBuilderView()
}

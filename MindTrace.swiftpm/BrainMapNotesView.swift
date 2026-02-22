import SwiftUI

struct BrainMapNotesView: View {
    // MARK: - Phases
    private enum Phase { case header, display, hide, recall, result }

    // MARK: - Node/Edge Models
    private struct Node: Identifiable, Equatable {
        let id = UUID()
        let label: String
        var position: CGPoint
        var color: Color
    }
    private struct Edge: Identifiable, Equatable, Hashable {
        let id = UUID()
        let a: Int // index in nodes array
        let b: Int // index in nodes array
    }

    // MARK: - State
    @State private var phase: Phase = .header

    // Map state
    @State private var nodes: [Node] = []
    @State private var edges: [Edge] = []
    @State private var displayTimer: Timer? = nil
    @State private var displaySeconds: Int = 8 // short observation
    @State private var mapOpacity: Double = 1.0

    // Recall state (tap-based answers on pairs)
    @State private var recallPairs: [(String, String)] = []
    @State private var correctPairs: Set<Set<String>> = []
    @State private var selectedPairs: Set<Set<String>> = []

    // Result state
    @State private var associationPercent: Int = 0
    @State private var supportiveMessage: String = ""

    // Palette (soft nodes)
    private let palette: [Color] = [
        Color.mint.opacity(0.9),
        Color.blue.opacity(0.75),
        Color.purple.opacity(0.75),
        Color.cyan.opacity(0.8),
        Color.orange.opacity(0.8),
        Color.pink.opacity(0.75)
    ]

    var body: some View {
        ZStack {
            // Calm gradient background
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.35),
                    Color.purple.opacity(0.25),
                    Color.blue.opacity(0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                header

                switch phase {
                case .header:
                    introCard
                case .display:
                    mapDisplay
                case .hide:
                    mapHide
                case .recall:
                    recallPhase
                case .result:
                    resultPhase
                }

                Spacer(minLength: 12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .animation(.easeInOut(duration: 0.25), value: phase)
        .onDisappear { invalidateTimers() }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 6) {
            Text("Brain Map")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
            Text("How ideas connect in your mind.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Intro
    private var introCard: some View {
        VStack(spacing: 16) {
            Text("Neural‑style note mapping")
                .font(.title3.weight(.semibold))
            Text("Observe a simple brain‑map: soft nodes and light lines. Then the map fades, and you'll recall which nodes were connected. No pressure—just learning.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: startDisplay) {
                Text("Begin")
                    .font(.headline)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15))
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }

    // MARK: - Map Display
    private var mapDisplay: some View {
        VStack(spacing: 12) {
            Text("Observe the connections")
                .font(.headline)
                .opacity(0.9)
            Text("Soft nodes • light lines")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            mapCanvas

            VStack(spacing: 8) {
                Text("Map will hide soon…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                ProgressView(value: Double(8 - displaySeconds), total: 8)
                    .tint(.indigo)
            }
        }
        .onAppear { runDisplayTimer() }
    }

    private var mapHide: some View {
        VStack(spacing: 12) {
            Text("Let the image settle")
                .font(.headline)
                .opacity(0.9)
            Text("The map fades gently.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            mapCanvas
                .opacity(mapOpacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        mapOpacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        startRecall()
                    }
                }
        }
    }

    private var mapCanvas: some View {
        GeometryReader { proxy in
            ZStack {
                // Edges first (light lines)
                Canvas { context, size in
                    let stroke = StrokeStyle(lineWidth: 1.5, lineCap: .round)
                    for e in edges {
                        guard e.a < nodes.count, e.b < nodes.count else { continue }
                        let p1 = nodes[e.a].position
                        let p2 = nodes[e.b].position
                        var path = Path()
                        path.move(to: p1)
                        path.addLine(to: p2)
                        context.stroke(path, with: .color(Color.white.opacity(0.55)), style: stroke)
                    }
                }
                // Nodes (soft circles)
                ForEach(nodes) { node in
                    VStack(spacing: 6) {
                        Circle()
                            .fill(node.color)
                            .frame(width: 26, height: 26)
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
                        Text(node.label)
                            .font(.caption2)
                            .foregroundStyle(.primary)
                            .opacity(0.85)
                    }
                    .position(node.position)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(height: min(300, proxy.size.height * 0.6))
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15))
            )
            .onAppear {
                if nodes.isEmpty { seedMap(in: proxy.size) }
            }
        }
        .frame(height: 320)
    }

    // MARK: - Recall
    private var recallPhase: some View {
        VStack(spacing: 16) {
            Text("Which nodes were connected?")
                .font(.headline)
            Text("Tap all pairs you remember.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(recallPairs.indices, id: \.self) { i in
                    let pair = recallPairs[i]
                    let key: Set<String> = [pair.0, pair.1]
                    Button {
                        togglePair(key)
                    } label: {
                        HStack(spacing: 12) {
                            Text("\(pair.0)  ↔︎  \(pair.1)")
                                .foregroundStyle(.primary)
                            Spacer()
                            if selectedPairs.contains(key) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.indigo)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.35))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.2))
                        )
                    }
                    .buttonStyle(.plain)
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15))
            )

            Button(action: computeResult) {
                Text("See result")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Result
    private var resultPhase: some View {
        VStack(spacing: 16) {
            Text("Association Memory %")
                .font(.headline)
            Text("\(associationPercent)%")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .padding(.bottom, 4)

            Text(supportiveMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: resetAll) {
                Text("Try again")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15))
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }

    // MARK: - Flow
    private func startDisplay() {
        phase = .display
        displaySeconds = 8
        mapOpacity = 1.0
        nodes = []
        edges = []
        recallPairs = []
        correctPairs = []
        selectedPairs = []
    }

    private func runDisplayTimer() {
        invalidateTimers()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if displaySeconds > 0 {
                displaySeconds -= 1
                // subtle node drift
                withAnimation(.easeInOut(duration: 0.9)) {
                    nodes = nodes.map { n in
                        var m = n
                        let dx = CGFloat.random(in: -8...8)
                        let dy = CGFloat.random(in: -6...6)
                        m.position.x = max(30, min(m.position.x + dx, 320))
                        m.position.y = max(30, min(m.position.y + dy, 240))
                        return m
                    }
                }
            } else {
                invalidateTimers()
                withAnimation { phase = .hide }
            }
        }
    }

    private func startRecall() {
        // Build tap options: include all true edges + a few decoys
        let labels = nodes.map { $0.label }
        var truePairs: [(String, String)] = []
        for e in edges {
            guard e.a < labels.count, e.b < labels.count else { continue }
            let p = orderedPair(labels[e.a], labels[e.b])
            truePairs.append(p)
            correctPairs.insert([p.0, p.1])
        }
        // Decoys from random non-edges
        var decoys: [(String, String)] = []
        let allPairs = allUnorderedPairs(labels)
        let nonEdges = allPairs.filter { !correctPairs.contains([$0.0, $0.1]) }
        decoys.append(contentsOf: nonEdges.shuffled().prefix(max(0, 6 - truePairs.count)))

        recallPairs = (truePairs + decoys).shuffled()
        selectedPairs = []
        withAnimation { phase = .recall }
    }

    private func computeResult() {
        let correct = correctPairs
        let chosen = selectedPairs
        let intersection = correct.intersection(chosen).count
        let union = correct.union(chosen).count
        let jaccard = union == 0 ? 1.0 : Double(intersection) / Double(union)
        associationPercent = Int(round(jaccard * 100))

        if associationPercent >= 85 {
            supportiveMessage = "Great associative recall. Keep exploring connections."
        } else if associationPercent >= 65 {
            supportiveMessage = "Nice mapping. Connections grow clearer with practice."
        } else {
            supportiveMessage = "Learning is gradual. Each map strengthens memory."
        }
        withAnimation { phase = .result }
    }

    private func resetAll() {
        invalidateTimers()
        nodes = []
        edges = []
        recallPairs = []
        correctPairs = []
        selectedPairs = []
        associationPercent = 0
        supportiveMessage = ""
        phase = .header
    }

    private func invalidateTimers() {
        displayTimer?.invalidate(); displayTimer = nil
    }

    // MARK: - Map Seeding
    private func seedMap(in available: CGSize) {
        // Seed a small labeled map
        let width = min(available.width, 340)
        let height = min(available.height, 260)

        let labels = ["Idea A", "Idea B", "Idea C", "Idea D", "Idea E"]
        var seededNodes: [Node] = []

        func randomPoint() -> CGPoint {
            CGPoint(x: CGFloat.random(in: 30...(width - 30)), y: CGFloat.random(in: 30...(height - 30)))
        }

        for label in labels {
            let color = palette.randomElement() ?? .mint
            let node = Node(label: label, position: randomPoint(), color: color)
            seededNodes.append(node)
        }

        // Create a few edges between nodes
        var seededEdges: [Edge] = []
        let count = seededNodes.count
        if count >= 5 {
            // Build a simple connected shape + an extra link
            seededEdges.append(Edge(a: 0, b: 1))
            seededEdges.append(Edge(a: 1, b: 2))
            seededEdges.append(Edge(a: 2, b: 3))
            seededEdges.append(Edge(a: 3, b: 4))
            seededEdges.append(Edge(a: 0, b: 2)) // extra
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            nodes = seededNodes
            edges = seededEdges
        }
    }

    // MARK: - Helpers
    private func orderedPair(_ a: String, _ b: String) -> (String, String) {
        return a < b ? (a, b) : (b, a)
    }

    private func allUnorderedPairs(_ labels: [String]) -> [(String, String)] {
        var result: [(String, String)] = []
        for i in 0..<labels.count {
            for j in (i+1)..<labels.count {
                result.append(orderedPair(labels[i], labels[j]))
            }
        }
        return result
    }

    private func togglePair(_ pair: Set<String>) {
        if selectedPairs.contains(pair) {
            selectedPairs.remove(pair)
        } else {
            selectedPairs.insert(pair)
        }
    }
}

#Preview {
    BrainMapNotesView()
}

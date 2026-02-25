//
//  MentalDeclutterView.swift
//  MindSpan
//
//  UNUSED FILE - Commented out on 2025-02-26
//  This file is not referenced anywhere in the project
//

/*
import SwiftUI

struct MentalDeclutterView: View {
    // MARK: - Phases
    private enum Phase { case header, clutter, cleanup, recall, result }

    // MARK: - Item Model
    private struct Item: Identifiable, Equatable {
        let id = UUID()
        let isImportant: Bool
        let symbol: String
        let color: Color
        var position: CGPoint
        var size: CGFloat
    }

    // MARK: - State
    @State private var phase: Phase = .header

    // Clutter/Cleanup state
    @State private var items: [Item] = []
    @State private var clutterTimer: Timer? = nil
    @State private var clutterSeconds: Int = 10

    // Recall state
    @State private var importantSymbolsShown: Set<String> = []
    @State private var recallOptions: [String] = []
    @State private var selectedRecall: Set<String> = []

    // Result state
    @State private var focusPercent: Int = 0
    @State private var supportiveMessage: String = ""

    // Design palette (calm, playful)
    private let palette: [Color] = [
        Color.mint.opacity(0.9),
        Color.purple.opacity(0.75),
        Color.blue.opacity(0.75),
        Color.cyan.opacity(0.8),
        Color.orange.opacity(0.8),
        Color.pink.opacity(0.75)
    ]

    // Important symbols that matter
    private let importantPool = [
        "heart.fill", "book.fill", "calendar", "bookmark.fill", "star.fill"
    ]
    // Noise symbols to ignore
    private let noisePool = [
        "cloud", "bolt", "leaf", "paperplane", "cart", "tag", "scissors", "paintbrush", "umbrella", "gift"
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
                case .clutter:
                    clutterPhase
                case .cleanup:
                    cleanupPhase
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
            Text("Mental Declutter")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
            Text("Focus on what matters.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Intro
    private var introCard: some View {
        VStack(spacing: 16) {
            Text("Visual cleanup")
                .font(.title3.weight(.semibold))
            Text("You'll see a gentle mix of items. Some are meaningful – remember them. Others are just clutter – let them go. Then you'll tidy the screen and answer a simple question.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: startClutter) {
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

    // MARK: - Clutter Phase (observe only)
    private var clutterPhase: some View {
        VStack(spacing: 12) {
            Text("Notice what's meaningful")
                .font(.headline)
                .opacity(0.9)
            Text("No pressure. Just observe.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            clutterCanvas(interactive: false)

            VStack(spacing: 8) {
                Text("Preparing cleanup…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                ProgressView(value: Double(10 - clutterSeconds), total: 10)
                    .tint(.indigo)
            }
        }
        .onAppear { runClutterTimer() }
    }

    // MARK: - Cleanup Phase (tap to remove clutter; important items stay)
    private var cleanupPhase: some View {
        VStack(spacing: 12) {
            Text("Gently clear the clutter")
                .font(.headline)
                .opacity(0.9)
            Text("Tap to remove noise. Important items stay.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            clutterCanvas(interactive: true)

            Button(action: startRecall) {
                Text("I'm done")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .opacity(0.95)
        }
    }

    // Shared canvas for clutter/cleanup
    private func clutterCanvas(interactive: Bool) -> some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(items) { item in
                    let view = ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.18))
                        Image(systemName: item.symbol)
                            .font(.system(size: item.size * 0.6, weight: .semibold))
                            .foregroundStyle(item.color)
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    .frame(width: item.size * 2.0, height: item.size * 1.6)
                    .position(item.position)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                    .transition(.scale.combined(with: .opacity))

                    if interactive {
                        view
                            .onTapGesture { removeIfNoise(item) }
                    } else {
                        view
                    }
                }
            }
            .frame(height: min(280, proxy.size.height * 0.55))
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15))
            )
            .onAppear {
                // Seed items once when entering clutter
                if items.isEmpty {
                    seedItems(in: proxy.size)
                }
            }
        }
        .frame(height: 300)
    }

    // MARK: - Recall Phase
    private var recallPhase: some View {
        VStack(spacing: 16) {
            Text("Which important items were shown?")
                .font(.headline)
            Text("Select all that apply.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(recallOptions, id: \.self) { symbol in
                    Button {
                        toggleRecall(symbol)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: symbol)
                                .font(.title3)
                                .foregroundStyle(.primary)
                            Text(readableName(for: symbol))
                                .foregroundStyle(.primary)
                            Spacer()
                            if selectedRecall.contains(symbol) {
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

    // MARK: - Result Phase
    private var resultPhase: some View {
        VStack(spacing: 16) {
            Text("Focus Memory %")
                .font(.headline)
            Text("\(focusPercent)%")
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
    private func startClutter() {
        phase = .clutter
        clutterSeconds = 10
        selectedRecall = []
        importantSymbolsShown = []
        recallOptions = []
    }

    private func runClutterTimer() {
        invalidateTimers()
        clutterTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if clutterSeconds > 0 {
                clutterSeconds -= 1
                // Gentle drift animation for a few items
                withAnimation(.easeInOut(duration: 0.9)) {
                    items = items.map { item in
                        var moved = item
                        let dx = CGFloat.random(in: -12...12)
                        let dy = CGFloat.random(in: -10...10)
                        moved.position.x = max(30, min(moved.position.x + dx, 320))
                        moved.position.y = max(30, min(moved.position.y + dy, 240))
                        return moved
                    }
                }
            } else {
                invalidateTimers()
                withAnimation { phase = .cleanup }
            }
        }
    }

    private func startRecall() {
        // Build recall options: all important symbols + a few noise decoys
        var options = Array(importantSymbolsShown)
        let decoys = noisePool.shuffled().prefix(max(0, 5 - options.count))
        options.append(contentsOf: decoys)
        recallOptions = Array(Set(options)).shuffled()
        withAnimation { phase = .recall }
    }

    private func computeResult() {
        // Correct set is the important symbols shown
        let correctSet = importantSymbolsShown
        let chosen = selectedRecall
        let intersection = correctSet.intersection(chosen).count
        let union = correctSet.union(chosen).count
        let jaccard = union == 0 ? 1.0 : Double(intersection) / Double(union)
        var percent = Int(round(jaccard * 100))
        // Encourage gentle play with a small bonus if most clutter was cleared
        let noiseCountInitial = items.filter { !$0.isImportant }.count
        let noiseRemaining = items.filter { !$0.isImportant }.count
        if noiseCountInitial > 0 && noiseRemaining == 0 { percent = min(100, percent + 5) }
        focusPercent = percent

        if focusPercent >= 85 {
            supportiveMessage = "Clear focus. You noticed what matters."
        } else if focusPercent >= 65 {
            supportiveMessage = "Nice attention. With calm, clarity grows."
        } else {
            supportiveMessage = "No rush. Each pause supports clearer recall."
        }

        withAnimation { phase = .result }
    }

    private func resetAll() {
        invalidateTimers()
        items = []
        importantSymbolsShown = []
        recallOptions = []
        selectedRecall = []
        focusPercent = 0
        supportiveMessage = ""
        phase = .header
    }

    private func invalidateTimers() {
        clutterTimer?.invalidate(); clutterTimer = nil
    }

    // MARK: - Items
    private func seedItems(in available: CGSize) {
        var seeded: [Item] = []
        importantSymbolsShown.removeAll()

        let width = min(available.width, 340)
        let height = min(available.height, 260)

        let importantCount = 4
        let noiseCount = 10

        func randomPoint() -> CGPoint {
            CGPoint(x: CGFloat.random(in: 30...(width - 30)), y: CGFloat.random(in: 30...(height - 30)))
        }

        // Important items
        let chosenImportant = importantPool.shuffled().prefix(importantCount)
        for sym in chosenImportant {
            let size = CGFloat.random(in: 36...48)
            let color = palette.randomElement() ?? .mint
            let item = Item(isImportant: true, symbol: sym, color: color, position: randomPoint(), size: size)
            seeded.append(item)
            importantSymbolsShown.insert(sym)
        }
        // Noise items
        let chosenNoise = noisePool.shuffled().prefix(noiseCount)
        for sym in chosenNoise {
            let size = CGFloat.random(in: 28...44)
            let color = palette.randomElement() ?? .cyan
            let item = Item(isImportant: false, symbol: sym, color: color, position: randomPoint(), size: size)
            seeded.append(item)
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            items = seeded.shuffled()
        }
    }

    private func removeIfNoise(_ item: Item) {
        guard !item.isImportant else { return } // important items stay
        withAnimation(.easeInOut(duration: 0.25)) {
            items.removeAll { $0.id == item.id }
        }
    }

    private func toggleRecall(_ symbol: String) {
        if selectedRecall.contains(symbol) {
            selectedRecall.remove(symbol)
        } else {
            selectedRecall.insert(symbol)
        }
    }

    private func readableName(for symbol: String) -> String {
        switch symbol {
        case "heart.fill": return "Heart"
        case "book.fill": return "Book"
        case "calendar": return "Calendar"
        case "bookmark.fill": return "Bookmark"
        case "star.fill": return "Star"
        default:
            return symbol.replacingOccurrences(of: ".fill", with: "")
        }
    }
}

*/

//#Preview {
//    MentalDeclutterView()
//}

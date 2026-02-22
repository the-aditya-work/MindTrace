//
//  File.swift
//  MindSpan
//
//  Created by Aditya Rai on 29/01/26.
//

//import SwiftUI
//
//// ColorMemoryArtView
//// Calm, palette-based memory experience
//// Phases: display → distraction → recall → result
//// Design: pastel colors, soft rounded cards, calm gradient, native animations
//
//struct ColorMemoryArtView: View {
//    // MARK: - Phases
//    private enum Phase { case display, distraction, recall, result }
//
//    // MARK: - Pastel palette (mint, lavender, peach, sky blue)
//    private let pastelPalette: [Color] = [
//        Color.mint.opacity(0.9),      // mint
//        Color.purple.opacity(0.7),    // lavender
//        Color.orange.opacity(0.8),    // peach
//        Color.blue.opacity(0.7)       // sky blue
//    ]
//
//    // MARK: - State
//    @State private var hasStarted: Bool = false
//    @State private var phase: Phase = .display
//
//    // Display sequence
//    @State private var sequence: [Color] = []
//    @State private var revealIndex: Int = -1
//    @State private var displayTimer: Timer? = nil
//
//    // Distraction
//    @State private var distractionTimer: Timer? = nil
//    @State private var distractionRemaining: Int = 15
//    @State private var floatingDots: [FloatingDot] = []
//    @State private var tapCount: Int = 0
//
//    // Recall
//    @State private var recallOptions: [Color] = []
//    @State private var userOrder: [Color] = []
//    @State private var slotsCount: Int = 5
//
//    // Result
//    @State private var percent: Int = 0
//    @State private var message: String = ""
//
//    var body: some View {
//        ZStack {
//            // Calm gradient background
//            LinearGradient(
//                colors: [
//                    Color.indigo.opacity(0.35),
//                    Color.purple.opacity(0.25),
//                    Color.blue.opacity(0.20)
//                ],
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//
//            VStack(spacing: 20) {
//                header
//
//                if !hasStarted {
//                    landingView
//                } else {
//                    switch phase {
//                    case .display:
//                        paletteDisplay
//                    case .distraction:
//                        gentleDistraction
//                    case .recall:
//                        paletteRecall
//                    case .result:
//                        resultView
//                    }
//                }
//
//                Spacer(minLength: 12)
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 24)
//        }
//        .onAppear { /* wait for user to begin */ }
//        .onDisappear { invalidateTimers() }
//        .animation(.easeInOut(duration: 0.3), value: phase)
//    }
//
//    // MARK: - Header
//    private var header: some View {
//        VStack(spacing: 6) {
//            Text("Color Memory Art")
//                .font(.largeTitle.bold())
//                .foregroundStyle(.primary)
//                .accessibilityAddTraits(.isHeader)
//            Text("Memories as palettes.")
//                .font(.callout)
//                .foregroundStyle(.secondary)
//                .multilineTextAlignment(.center)
//        }
//    }
//
//    // MARK: - Landing
//    private var landingView: some View {
//        VStack(spacing: 20) {
//            Text("A calm, palette-based memory check.")
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//
//            Button(action: beginTest) {
//                Text("Begin Test")
//                    .font(.headline)
//                    .padding(.horizontal, 24)
//                    .padding(.vertical, 12)
//                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
//            }
//            .buttonStyle(.plain)
//            .accessibilityLabel("Begin Color Memory Test")
//        }
//    }
//
//    // MARK: - Palette Display Phase
//    private var paletteDisplay: some View {
//        VStack(spacing: 16) {
//            Text("Observe the palette")
//                .font(.headline)
//                .foregroundStyle(.primary)
//                .opacity(0.85)
//
//            // Soft rounded cards revealed one-by-one
//            HStack(spacing: 12) {
//                ForEach(sequence.indices, id: \.self) { idx in
//                    RoundedRectangle(cornerRadius: 18, style: .continuous)
//                        .fill(sequence[idx])
//                        .frame(height: 80)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 18, style: .continuous)
//                                .strokeBorder(Color.white.opacity(0.18))
//                        )
//                        .scaleEffect(revealIndex >= idx ? 1.0 : 0.85)
//                        .opacity(revealIndex >= idx ? 1.0 : 0.0)
//                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: revealIndex)
//                }
//            }
//            .frame(maxWidth: .infinity)
//
//            ProgressView(value: Double(max(revealIndex + 1, 0)), total: Double(max(sequence.count, 1)))
//                .tint(.indigo)
//                .padding(.horizontal)
//        }
//        .onAppear { runDisplayTimer() }
//    }
//
//    // MARK: - Distraction Phase
//    private var gentleDistraction: some View {
//        VStack(spacing: 16) {
//            Text("Tap the floating dots")
//                .font(.headline)
//                .foregroundStyle(.primary)
//                .opacity(0.85)
//
//            ZStack {
//                ForEach(floatingDots) { dot in
//                    Circle()
//                        .fill(dot.color)
//                        .frame(width: dot.size, height: dot.size)
//                        .position(dot.position)
//                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
//                        .onTapGesture { tapDot(dot) }
//                        .transition(.scale.combined(with: .opacity))
//                }
//            }
//            .frame(height: 220)
//            .background(
//                RoundedRectangle(cornerRadius: 22, style: .continuous)
//                    .fill(.regularMaterial)
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 22, style: .continuous)
//                    .strokeBorder(Color.white.opacity(0.15))
//            )
//            .clipped()
//
//            VStack(spacing: 8) {
//                Text("Time: \(distractionRemaining)s")
//                    .font(.footnote)
//                    .foregroundStyle(.secondary)
//                ProgressView(value: Double(15 - distractionRemaining), total: 15)
//                    .tint(.indigo)
//            }
//        }
//        .onAppear { startDistraction() }
//    }
//
//    // MARK: - Recall Phase
//    private var paletteRecall: some View {
//        VStack(spacing: 16) {
//            Text("Recreate the palette")
//                .font(.headline)
//                .foregroundStyle(.primary)
//                .opacity(0.85)
//
//            // Empty slots
//            HStack(spacing: 12) {
//                ForEach(0..<slotsCount, id: \.self) { idx in
//                    RoundedRectangle(cornerRadius: 16, style: .continuous)
//                        .fill(idx < userOrder.count ? userOrder[idx] : Color.white.opacity(0.35))
//                        .frame(height: 60)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 16, style: .continuous)
//                                .strokeBorder(Color.white.opacity(0.2))
//                        )
//                        .animation(.easeInOut(duration: 0.25), value: userOrder)
//                }
//            }
//
//            // Color choices (same colors used in sequence, shuffled)
//            let options = recallOptions
//            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
//                ForEach(options.indices, id: \.self) { idx in
//                    Button {
//                        selectColor(options[idx])
//                    } label: {
//                        RoundedRectangle(cornerRadius: 16, style: .continuous)
//                            .fill(options[idx])
//                            .frame(height: 48)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 16, style: .continuous)
//                                    .strokeBorder(Color.white.opacity(0.18))
//                            )
//                    }
//                    .buttonStyle(.plain)
//                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
//                    .disabled(userOrder.count >= slotsCount)
//                    .opacity(userOrder.count >= slotsCount ? 0.6 : 1)
//                }
//            }
//
//            Button(action: computeResult) {
//                Text("See result")
//                    .font(.headline)
//                    .padding(.horizontal, 24)
//                    .padding(.vertical, 10)
//                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
//            }
//            .buttonStyle(.plain)
//            .disabled(userOrder.count < slotsCount)
//            .opacity(userOrder.count < slotsCount ? 0.6 : 1)
//        }
//    }
//
//    // MARK: - Result
//    private var resultView: some View {
//        VStack(spacing: 16) {
//            Text("Color Memory %")
//                .font(.headline)
//            Text("\(percent)%")
//                .font(.system(size: 56, weight: .bold, design: .rounded))
//                .foregroundStyle(.primary)
//                .padding(.bottom, 4)
//            Text(message)
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//
//            Button(action: restart) {
//                Text("Try again")
//                    .font(.headline)
//                    .padding(.horizontal, 24)
//                    .padding(.vertical, 10)
//                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
//            }
//            .buttonStyle(.plain)
//        }
//        .padding(20)
//        .background(
//            RoundedRectangle(cornerRadius: 22, style: .continuous)
//                .fill(.regularMaterial)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 22, style: .continuous)
//                .strokeBorder(Color.white.opacity(0.15))
//        )
//        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
//    }
//
//    // MARK: - Logic
//    private func beginTest() {
//        invalidateTimers()
//        userOrder = []
//        percent = 0
//        message = ""
//        phase = .display
//        hasStarted = true
//        startExperience()
//    }
//
//    private func startExperience() {
//        // Build a sequence of 5 or 6 colors from the pastel palette
//        slotsCount = Int.random(in: 5...6)
//        var seq: [Color] = []
//        let pool = pastelPalette
//        var idxs = Array(0..<pool.count).shuffled()
//        while seq.count < slotsCount {
//            if idxs.isEmpty { idxs = Array(0..<pool.count).shuffled() }
//            let i = idxs.removeFirst()
//            seq.append(pool[i])
//        }
//        sequence = seq
//        revealIndex = -1
//        userOrder = []
//        recallOptions = Array(Set(sequence)).shuffled()
//    }
//
//    private func runDisplayTimer() {
//        invalidateTimers()
//        // Reveal each color every ~2.7s
//        displayTimer = Timer.scheduledTimer(withTimeInterval: 2.7, repeats: true) { _ in
//            let next = revealIndex + 1
//            if next < sequence.count {
//                revealIndex = next
//            } else {
//                invalidateTimers()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                    phase = .distraction
//                }
//            }
//        }
//        // start with first
//        revealIndex = 0
//    }
//
//    private func startDistraction() {
//        // Seed floating dots for gentle taps
//        floatingDots = makeDots()
//        distractionRemaining = 15
//        tapCount = 0
//        invalidateTimers()
//        distractionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            if distractionRemaining > 0 {
//                // Drift dots a bit for a playful feel
//                withAnimation(.easeInOut(duration: 0.9)) {
//                    floatingDots = floatingDots.map { $0.jitter(in: CGSize(width: 320, height: 220)) }
//                }
//                distractionRemaining -= 1
//            } else {
//                invalidateTimers()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                    phase = .recall
//                }
//            }
//        }
//    }
//
//    private func tapDot(_ dot: FloatingDot) {
//        tapCount += 1
//        // Replace tapped dot with a new one softly
//        withAnimation(.easeInOut(duration: 0.25)) {
//            if let idx = floatingDots.firstIndex(where: { $0.id == dot.id }) {
//                floatingDots[idx] = FloatingDot.random(in: CGSize(width: 320, height: 220))
//            }
//        }
//    }
//
//    private func selectColor(_ color: Color) {
//        guard userOrder.count < slotsCount else { return }
//        userOrder.append(color)
//    }
//
//    private func computeResult() {
//        // Compare user order to original sequence (first slotsCount elements)
//        let target = Array(sequence.prefix(slotsCount))
//        var correct = 0
//        for (a, b) in zip(userOrder, target) {
//            if a.matches(b) { correct += 1 }
//        }
//        let base = Int((Double(correct) / Double(max(slotsCount, 1))) * 100.0)
//        // Gentle encouragement; small bonus for playful taps (max +5)
//        let bonus = min(tapCount, 5)
//        percent = min(100, base + bonus)
//        message = percent >= 80 ?
//            "Your visual memory is gently improving." :
//            "Awareness grows with each calm pause."
//        phase = .result
//    }
//
//    private func restart() {
//        invalidateTimers()
//        userOrder = []
//        percent = 0
//        message = ""
//        hasStarted = true
//        phase = .display
//        startExperience()
//    }
//
//    private func invalidateTimers() {
//        displayTimer?.invalidate(); displayTimer = nil
//        distractionTimer?.invalidate(); distractionTimer = nil
//    }
//
//    // MARK: - Dots
//    private func makeDots() -> [FloatingDot] {
//        (0..<8).map { _ in FloatingDot.random(in: CGSize(width: 320, height: 220)) }
//    }
//}
//
//// MARK: - Helpers
//private struct FloatingDot: Identifiable, Equatable {
//    let id = UUID()
//    var position: CGPoint
//    var size: CGFloat
//    var color: Color
//
//    static func random(in bounds: CGSize) -> FloatingDot {
//        FloatingDot(
//            position: CGPoint(x: CGFloat.random(in: 24...(bounds.width - 24)),
//                              y: CGFloat.random(in: 24...(bounds.height - 24))),
//            size: CGFloat.random(in: 16...32),
//            color: [.mint.opacity(0.9), .purple.opacity(0.7), .orange.opacity(0.8), .blue.opacity(0.7)].randomElement()!
//        )
//    }
//
//    func jitter(in bounds: CGSize) -> FloatingDot {
//        let dx = CGFloat.random(in: -16...16)
//        let dy = CGFloat.random(in: -12...12)
//        var nx = position.x + dx
//        var ny = position.y + dy
//        nx = min(max(24, nx), bounds.width - 24)
//        ny = min(max(24, ny), bounds.height - 24)
//        return FloatingDot(position: CGPoint(x: nx, y: ny), size: size, color: color)
//    }
//}
//
//private extension Color {
//    // Light equality by comparing description (sufficient for palette set here)
//    func matches(_ other: Color) -> Bool { String(describing: self) == String(describing: other) }
//}
//
//#Preview {
//    ColorMemoryArtView()
//}

import SwiftUI

struct ColorMemoryArtView: View {

    var body: some View {

        ZStack {
            LinearGradient(
                colors: [
                    Color.pink.opacity(0.3),
                    Color.purple.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {

                Text("Color Memory Art")
                    .font(.largeTitle)
                    .bold()

                NavigationLink(destination: ActualMemoryTestView()) {
                    VStack(spacing: 10) {
                        Text("Basic Color Sequence")
                            .font(.headline)

                        Text("Play the calming color recall game.")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
                }

                NavigationLink(destination: BasicColorMemoryGameView()) {
 
                    VStack(spacing: 10) {
                        Text("Advanced Palette Mode")
                            .font(.headline)

                        Text("Complex artistic memory challenge.")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
                }

            }
            .padding()
        }
    }
}


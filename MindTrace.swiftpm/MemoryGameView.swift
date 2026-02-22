//
//  File.swift
//  MindSpan
//
//  Created by Aditya Rai on 29/01/26.
//

//import SwiftUI
//
//struct MemoryGameView: View {
//
//    @StateObject private var controller = MemoryDataController()
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("MindSpan")
//                .font(.largeTitle)
//                .bold()
//
//            Text("Measure how your mind remembers.")
//                .foregroundColor(.secondary)
//
//            Button("Start Memory Test") {
//                controller.generateSequence()
//            }
//        }
//        .padding()
//    }
//}

//import SwiftUI
//
//// MARK: - MemoryGameView
//// Implements the "Memory Test" experience entirely within this file as requested.
//// Phases: Header → Sequence → Distraction → Recall → Result
//// Design: Soothing gradient background, pastel cards, subtle shadows, smooth animations.
//
//struct MemoryGameView: View {
//    // MARK: - Game Phase
//    private enum Phase {
//        case idle, sequence, distraction, recall, result
//    }
//
//    // MARK: - Recall Question Model (lightweight, view-local)
//    private struct RecallQuestion: Identifiable, Equatable {
//        let id = UUID()
//        let prompt: String
//        let options: [String]
//        let correctIndex: Int
//    }
//
//    // MARK: - Pastel palette for items
//    private let itemColors: [Color] = [
//        Color.mint.opacity(0.9),
//        Color.orange.opacity(0.8), // peach-like
//        Color.purple.opacity(0.7), // lavender-like
//        Color.blue.opacity(0.7),   // sky blue
//        Color.cyan.opacity(0.8),
//        Color.pink.opacity(0.75)
//    ]
//
//    // MARK: - State
//    @State private var phase: Phase = .idle
//
//    // Sequence state
//    @State private var sequenceItems: [Int] = [] // store color indices
//    @State private var currentSequenceIndex: Int = -1
//    @State private var sequenceProgress: Double = 0
//
//    // Distraction state
//    @State private var distractionTimeRemaining: Int = 18 // between 15–20 seconds
//    @State private var distractionScore: Int = 0
//    @State private var targetColorIndex: Int = 0
//
//    // Recall state
//    @State private var questions: [RecallQuestion] = []
//    @State private var currentQuestion: Int = 0
//    @State private var answers: [Int?] = Array(repeating: nil, count: 6)
//
//    // Result state
//    @State private var rememberingPercent: Int = 0
//    @State private var supportiveMessage: String = ""
//
//    // Timers
//    @State private var sequenceTimer: Timer? = nil
//    @State private var distractionTimer: Timer? = nil
//
//    var body: some View {
//        ZStack {
//            // Background gradient: indigo/purple to pastel blue
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color.indigo.opacity(0.35),
//                    Color.purple.opacity(0.25),
//                    Color.blue.opacity(0.20)
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//
//            VStack(spacing: 20) {
//                header
//
//                switch phase {
//                case .idle:
//                    introCard
//                case .sequence:
//                    sequencePhase
//                case .distraction:
//                    distractionPhase
//                case .recall:
//                    recallPhase
//                case .result:
//                    resultPhase
//                }
//
//                // Footer spacing
//                Spacer(minLength: 12)
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 24)
//        }
//        .animation(.easeInOut(duration: 0.25), value: phase)
//        .onDisappear { invalidateTimers() }
//    }
//
//    // MARK: - Header
//    private var header: some View {
//        VStack(spacing: 6) {
//            Text("MindSpan")
//                .font(.largeTitle.bold())
//                .foregroundStyle(.primary)
//                .accessibilityAddTraits(.isHeader)
//            Text("Measure how your mind remembers.")
//                .font(.callout)
//                .foregroundStyle(.secondary)
//                .multilineTextAlignment(.center)
//        }
//    }
//
//    // MARK: - Intro / Idle
//    private var introCard: some View {
//        VStack(spacing: 16) {
//            Text("Memory Test")
//                .font(.title3.weight(.semibold))
//            Text("You'll see a sequence of calming colors. Try to remember them. You'll then do a short, playful task, and answer a few simple questions.")
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//                .multilineTextAlignment(.center)
//
//            Button(action: startSequence) {
//                Text("Begin")
//                    .font(.headline)
//                    .padding(.horizontal, 28)
//                    .padding(.vertical, 12)
//                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
//            }
//            .buttonStyle(.plain)
//            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
//        }
//        .padding(24)
//        .background(
//            RoundedRectangle(cornerRadius: 20, style: .continuous)
//                .fill(.regularMaterial)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 20, style: .continuous)
//                .strokeBorder(Color.white.opacity(0.15))
//        )
//        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
//    }
//
//    // MARK: - Sequence Phase
//    private var sequencePhase: some View {
//        VStack(spacing: 16) {
//            Text("Watch the sequence")
//                .font(.headline)
//            Text("6 items · ~3 seconds each")
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//
//            ZStack {
//                RoundedRectangle(cornerRadius: 24, style: .continuous)
//                    .fill(currentColor())
//                    .frame(height: 220)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 24, style: .continuous)
//                            .strokeBorder(Color.white.opacity(0.20))
//                    )
//                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)
//                    .animation(.easeInOut(duration: 0.35), value: currentSequenceIndex)
//
//                Text(currentSequenceLabel())
//                    .font(.title3.weight(.semibold))
//                    .foregroundStyle(.primary)
//                    .padding(12)
//                    .background(.ultraThinMaterial, in: Capsule())
//                    .opacity(currentSequenceIndex >= 0 ? 1 : 0)
//                    .animation(.easeInOut(duration: 0.25), value: currentSequenceIndex)
//            }
//            .accessibilityElement(children: .ignore)
//            .accessibilityLabel("Sequence item \(currentSequenceIndex + 1) of \(sequenceItems.count)")
//
//            ProgressView(value: sequenceProgress)
//                .tint(.indigo)
//                .padding(.horizontal)
//        }
//        .onAppear { runSequenceTimer() }
//    }
//
//    private func currentColor() -> Color {
//        guard currentSequenceIndex >= 0, currentSequenceIndex < sequenceItems.count else {
//            return Color.clear.opacity(0.0001) // keeps layout
//        }
//        return itemColors[sequenceItems[currentSequenceIndex]]
//    }
//
//    private func currentSequenceLabel() -> String {
//        guard currentSequenceIndex >= 0 else { return "" }
//        return "Item \(currentSequenceIndex + 1)"
//    }
//
//    private func runSequenceTimer() {
//        invalidateTimers()
//        // Show each of 6 items for ~3 seconds
//        sequenceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
//            let next = currentSequenceIndex + 1
//            if next < sequenceItems.count {
//                currentSequenceIndex = next
//                sequenceProgress = Double(next + 1) / Double(sequenceItems.count)
//            } else {
//                // End of sequence → move to distraction
//                invalidateTimers()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//                    startDistraction()
//                }
//            }
//        }
//        // Immediately show first item
//        currentSequenceIndex = 0
//        sequenceProgress = 1.0 / Double(sequenceItems.count)
//    }
//
//    private func startSequence() {
//        // Generate a sequence of 6 unique color indices (0..itemColors.count-1)
//        let pool = Array(0..<min(itemColors.count, 6))
//        sequenceItems = Array(pool.shuffled().prefix(6))
//        currentSequenceIndex = -1
//        sequenceProgress = 0
//        phase = .sequence
//    }
//
//    // MARK: - Distraction Phase
//    private var distractionPhase: some View {
//        VStack(spacing: 16) {
//            Text("Quick distraction")
//                .font(.headline)
//            Text("Tap the matching color chip. Stay relaxed.")
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//
//            // Target color display
//            VStack(spacing: 10) {
//                Text("Find this color")
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//                RoundedRectangle(cornerRadius: 18, style: .continuous)
//                    .fill(itemColors[targetColorIndex])
//                    .frame(height: 80)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 18, style: .continuous)
//                            .strokeBorder(Color.white.opacity(0.2))
//                    )
//                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
//            }
//            .padding(.bottom, 6)
//
//            // Grid of tappable chips (lightweight, playful)
//            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
//                ForEach(Array(0..<6), id: \.self) { idx in
//                    Button {
//                        handleDistractionTap(idx)
//                    } label: {
//                        RoundedRectangle(cornerRadius: 16, style: .continuous)
//                            .fill(itemColors[idx])
//                            .frame(height: 58)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 16, style: .continuous)
//                                    .strokeBorder(Color.white.opacity(0.18))
//                            )
//                    }
//                    .buttonStyle(.plain)
//                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
//                }
//            }
//            .padding(.horizontal, 6)
//
//            // Timer + gentle progress
//            VStack(spacing: 8) {
//                Text("Time remaining: \(distractionTimeRemaining)s")
//                    .font(.footnote)
//                    .foregroundStyle(.secondary)
//                ProgressView(value: Double(18 - distractionTimeRemaining), total: 18)
//                    .tint(.indigo)
//            }
//        }
//        .onAppear { runDistractionTimer() }
//    }
//
//    private func startDistraction() {
//        phase = .distraction
//        distractionTimeRemaining = 18
//        distractionScore = 0
//        targetColorIndex = Int.random(in: 0..<6)
//    }
//
//    private func runDistractionTimer() {
//        invalidateTimers()
//        distractionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            if distractionTimeRemaining > 0 {
//                distractionTimeRemaining -= 1
//            } else {
//                invalidateTimers()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                    startRecall()
//                }
//            }
//        }
//    }
//
//    private func handleDistractionTap(_ idx: Int) {
//        if idx == targetColorIndex {
//            distractionScore += 1
//            // Change target to keep it playful
//            targetColorIndex = Int.random(in: 0..<6)
//        } else {
//            // Small, non-judgmental vibration could be added in full app; here we stay minimal.
//        }
//    }
//
//    // MARK: - Recall Phase
//    private var recallPhase: some View {
//        VStack(spacing: 16) {
//            Text("What do you remember?")
//                .font(.headline)
//            Text("Answer a few quick questions.")
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//
//            if currentQuestion < questions.count {
//                let q = questions[currentQuestion]
//                VStack(spacing: 14) {
//                    Text(q.prompt)
//                        .font(.body.weight(.semibold))
//                        .multilineTextAlignment(.center)
//                        .padding(.bottom, 4)
//
//                    ForEach(q.options.indices, id: \.self) { idx in
//                        Button {
//                            selectAnswer(idx)
//                        } label: {
//                            HStack {
//                                Text(q.options[idx])
//                                    .foregroundStyle(.primary)
//                                Spacer()
//                                if answers[currentQuestion] == idx {
//                                    Image(systemName: "checkmark.circle.fill")
//                                        .foregroundStyle(.indigo)
//                                }
//                            }
//                            .padding()
//                            .background(
//                                RoundedRectangle(cornerRadius: 14, style: .continuous)
//                                    .fill(Color.white.opacity(0.35))
//                            )
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 14, style: .continuous)
//                                    .strokeBorder(Color.white.opacity(0.2))
//                            )
//                        }
//                        .buttonStyle(.plain)
//                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
//                    }
//                }
//                .padding(16)
//                .background(
//                    RoundedRectangle(cornerRadius: 20, style: .continuous)
//                        .fill(.regularMaterial)
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20, style: .continuous)
//                        .strokeBorder(Color.white.opacity(0.15))
//                )
//
//                Button(action: nextQuestion) {
//                    Text(currentQuestion == questions.count - 1 ? "See result" : "Next")
//                        .font(.headline)
//                        .padding(.horizontal, 24)
//                        .padding(.vertical, 10)
//                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
//                }
//                .buttonStyle(.plain)
//                .disabled(answers[currentQuestion] == nil)
//                .opacity(answers[currentQuestion] == nil ? 0.6 : 1)
//            }
//        }
//    }
//
//    private func startRecall() {
//        phase = .recall
//        // Build 5 questions derived from the 6-item sequence
//        var qs: [RecallQuestion] = []
//
//        // Q1: Which color appeared first?
//        if let first = sequenceItems.first {
//            qs.append(makeColorQuestion(prompt: "Which color appeared first?", correctIndex: first))
//        }
//        // Q2: Which color appeared last?
//        if let last = sequenceItems.last {
//            qs.append(makeColorQuestion(prompt: "Which color appeared last?", correctIndex: last))
//        }
//        // Q3: Which color appeared third? (if exists)
//        if sequenceItems.indices.contains(2) {
//            qs.append(makeColorQuestion(prompt: "Which color appeared third?", correctIndex: sequenceItems[2]))
//        }
//        // Q4: Did this color appear? (Yes/No)
//        let randomFromPalette = Int.random(in: 0..<6)
//        let didAppear = sequenceItems.contains(randomFromPalette)
//        qs.append(RecallQuestion(
//            prompt: "Did this color appear?",
//            options: ["Yes", "No"],
//            correctIndex: didAppear ? 0 : 1
//        ))
//        // Q5: Which set appeared earlier? (pairwise)
//        if sequenceItems.count >= 4 {
//            let a = sequenceItems[1]
//            let b = sequenceItems[3]
//            qs.append(RecallQuestion(
//                prompt: "Which appeared earlier?",
//                options: [colorName(for: a), colorName(for: b)],
//                correctIndex: 0 // index 1 vs 3 → first in options is earlier
//            ))
//        }
//
//        questions = Array(qs.prefix(6))
//        currentQuestion = 0
//        answers = Array(repeating: nil, count: questions.count)
//    }
//
//    private func makeColorQuestion(prompt: String, correctIndex: Int) -> RecallQuestion {
//        // Build 4-option MCQ: 1 correct + 3 distractors from palette
//        var options = Set([correctIndex])
//        while options.count < 4 {
//            options.insert(Int.random(in: 0..<6))
//        }
//        let shuffled = Array(options).shuffled()
//        let correctPos = shuffled.firstIndex(of: correctIndex) ?? 0
//        return RecallQuestion(
//            prompt: prompt,
//            options: shuffled.map { colorName(for: $0) },
//            correctIndex: correctPos
//        )
//    }
//
//    private func colorName(for index: Int) -> String {
//        // Friendly, simple names matching the palette theme
//        switch index {
//        case 0: return "Mint"
//        case 1: return "Peach"
//        case 2: return "Lavender"
//        case 3: return "Sky Blue"
//        case 4: return "Cyan"
//        case 5: return "Pink"
//        default: return "Color"
//        }
//    }
//
//    private func selectAnswer(_ idx: Int) {
//        answers[currentQuestion] = idx
//    }
//
//    private func nextQuestion() {
//        if currentQuestion < questions.count - 1 {
//            withAnimation { currentQuestion += 1 }
//        } else {
//            computeResult()
//        }
//    }
//
//    // MARK: - Result Phase
//    private var resultPhase: some View {
//        VStack(spacing: 16) {
//            Text("Mind Remembering %")
//                .font(.headline)
//            Text("\(rememberingPercent)%")
//                .font(.system(size: 56, weight: .bold, design: .rounded))
//                .foregroundStyle(.primary)
//                .padding(.bottom, 4)
//
//            Text(supportiveMessage)
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//
//            Button(action: resetAll) {
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
//    private func computeResult() {
//        // Score based on recall answers + small influence from distraction participation
//        var correct = 0
//        for (i, ans) in answers.enumerated() {
//            if let a = ans, i < questions.count, a == questions[i].correctIndex {
//                correct += 1
//            }
//        }
//        // Normalize to percentage (recall questions are primary signal)
//        let recallPercent = Int((Double(correct) / Double(max(questions.count, 1))) * 100.0)
//        // Add a small bonus up to +5% for engaging with the distraction to keep it encouraging
//        let bonus = min(distractionScore, 5)
//        rememberingPercent = min(100, recallPercent + bonus)
//
//        // Supportive, non-judgmental message
//        if rememberingPercent >= 85 {
//            supportiveMessage = "Great focus and gentle recall. Notice how it feels when your mind is clear."
//        } else if rememberingPercent >= 65 {
//            supportiveMessage = "Nice work. Your memory found helpful patterns. Breathe and stay curious."
//        } else {
//            supportiveMessage = "Every mind has rhythms. With a calm pause, recall often grows."
//        }
//
//        phase = .result
//    }
//
//    // MARK: - Utilities
//    private func resetAll() {
//        invalidateTimers()
//        sequenceItems = []
//        currentSequenceIndex = -1
//        sequenceProgress = 0
//        distractionTimeRemaining = 18
//        distractionScore = 0
//        targetColorIndex = 0
//        questions = []
//        currentQuestion = 0
//        answers = []
//        rememberingPercent = 0
//        supportiveMessage = ""
//        phase = .idle
//    }
//
//    private func invalidateTimers() {
//        sequenceTimer?.invalidate()
//        sequenceTimer = nil
//        distractionTimer?.invalidate()
//        distractionTimer = nil
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    MemoryGameView()
//}

import SwiftUI

struct MemoryGameView: View {

    var body: some View {
        NavigationStack {

            ZStack {
                // Soft Gradient Background
                LinearGradient(
                    colors: [
                        Color.indigo.opacity(0.4),
                        Color.purple.opacity(0.3),
                        Color.blue.opacity(0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // MARK: Header
                        VStack(spacing: 8) {
                            Text("MindSpan")
                                .font(.largeTitle)
                                .bold()

                            Text("Measure how your mind remembers.")
                                .foregroundColor(.secondary)
                        }
                        .padding(.top)

                        // MARK: Main Memory Test Card
                        memoryCard(
                            title: "Memory Test",
                            description: "Test your recall through calming sequences and playful distraction.",
                            icon: "brain.head.profile",
                            destination: AnyView(MemoryTestMenuView())
                        )

                        // MARK: Color Memory Art Card
                        memoryCard(
                            title: "Color Memory Art",
                            description: "Remember beautiful pastel palettes and recreate them.",
                            icon: "paintpalette.fill",
                            destination: AnyView(ColorMemoryArtView())
                        )

                        // MARK: Mental Declutter Card
                        memoryCard(
                            title: "Mental Declutter",
                            description: "Focus on what matters while ignoring visual noise.",
                            icon: "sparkles",
                            destination: AnyView(MentalDeclutterView())
                        )

                    }
                    .padding()
                }
            }
        }
    }

    // MARK: Reusable iOS Native Card
    func memoryCard(title: String,
                    description: String,
                    icon: String,
                    destination: AnyView) -> some View {

        NavigationLink(destination: destination) {

            VStack(alignment: .leading, spacing: 12) {

                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.orange)

                    Spacer()
                }

                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}


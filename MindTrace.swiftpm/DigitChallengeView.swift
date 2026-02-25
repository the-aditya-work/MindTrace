//
//  DigitChallengeView.swift
//  MindSpan
//
//  Capgemini Digit Challenge: 1–9 keypad, level-wise time, dynamic questions.
//

import SwiftUI

struct DigitChallengeView: View {

    struct Puzzle {
        let left: String
        let op: String
        let right: String
        let result: Int
    }

    @State private var currentPuzzle: Puzzle?
    @State private var slot1: Int? = nil
    @State private var slot2: Int? = nil
    @State private var selectedSlot = 1
    @State private var timeLeft = 15
    @State private var timer: Timer?
    @State private var message: String = ""
    @State private var messageColor: Color = .primary
    @State private var score = 0
    @State private var level = 1
    @State private var runStart = Date()
    @State private var showSummary = false
    @State private var lastAccuracy: Double = 0
    @State private var lastScore: Int = 0
    @State private var showingCorrectPopup = false
    @State private var showingWrongPopup = false

    @EnvironmentObject private var gameResultManager: GameResultManager

    /// Level 1 = 15s, 2 = 12s, 3 = 10s, 4 = 8s, 5 = 6s (simple → hard)
    private static let timeForLevel = [1: 15, 2: 12, 3: 10, 4: 8, 5: 6]
    private var maxLevel: Int { 5 }

    private let allDigits = [1, 2, 3, 4, 5, 6, 7, 8, 9]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.indigo.opacity(0.3), Color.blue.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {

                Text("Digit Challenge")
                    .font(.title2)
                    .bold()

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Score: \(score)")
                            .font(.headline)
                        Text("Level \(level)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(timeString)
                        .font(.title2.monospacedDigit())
                        .foregroundColor(timeLeft <= 5 ? .red : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                if let p = currentPuzzle {

                    Text("Use each digit at most once. Level \(level): \(Self.timeForLevel[level] ?? 15)s")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    equationBox(puzzle: p)

                    keypadView()

                    if !message.isEmpty {
                        Text(message)
                            .font(.headline)
                            .foregroundColor(messageColor)
                    }

                    Button("Check") {
                        checkAnswer()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
            }
            .padding()
        }
        .onAppear {
            nextQuestion()
            runStart = Date()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .navigationTitle("Digit Challenge")
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
                gameName: "Digit Challenge",
                levelReached: level,
                accuracy: lastAccuracy,
                avgResponseTime: Date().timeIntervalSince(runStart),
                totalTime: Date().timeIntervalSince(runStart),
                score: lastScore
            ) {
                score = 0
                level = 1
                nextQuestion()
                runStart = Date()
                showSummary = false
            } onDone: {
                showSummary = false
            }
        }
        .sheet(isPresented: $showingCorrectPopup) {
            CorrectAnswerPopup {
                nextQuestion()
                showingCorrectPopup = false
            }
        }
        .sheet(isPresented: $showingWrongPopup) {
            WrongAnswerPopup {
                // Reset for retry
                slot1 = nil
                slot2 = nil
                selectedSlot = 1
                startTimer()
                showingWrongPopup = false
            }
        }
    }

    private var timeString: String {
        let m = timeLeft / 60
        let s = timeLeft % 60
        return String(format: "%d:%02d", m, s)
    }

    private func equationBox(puzzle: Puzzle) -> some View {
        HStack(spacing: 8) {
            slotButton(value: slot1, slot: 1)
            Text(puzzle.op)
                .font(.title)
                .frame(width: 32)
            slotButton(value: slot2, slot: 2)
            Text("=")
                .font(.title)
            Text("\(puzzle.result)")
                .font(.title.bold())
                .frame(minWidth: 44)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green, lineWidth: 3)
        )
        .padding(.horizontal)
    }

    private func slotButton(value: Int?, slot: Int) -> some View {
        let isSelected = selectedSlot == slot
        return Button {
            selectedSlot = slot
        } label: {
            Text(value == nil ? "?" : "\(value!)")
                .font(.title.bold())
                .frame(width: 56, height: 56)
                .background(isSelected ? Color.green.opacity(0.3) : Color.gray.opacity(0.2))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.green : Color.clear, lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
    }

    /// Keypad: hamesha 1 se 9 tak sab digits dikhe; use kiye hue grey
    private func keypadView() -> some View {
        VStack(spacing: 10) {
            Text("Tap a digit to put in selected box")
                .font(.caption)
                .foregroundColor(.secondary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(allDigits, id: \.self) { d in
                    let used = (slot1 == d || slot2 == d)
                    Button {
                        if used { return }
                        if selectedSlot == 1 {
                            slot1 = d
                            selectedSlot = 2
                        } else {
                            slot2 = d
                        }
                    } label: {
                        Text("\(d)")
                            .font(.title.bold())
                            .frame(width: 56, height: 56)
                            .background(used ? Color.gray.opacity(0.4) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .disabled(used)
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    private func startTimer() {
        timer?.invalidate()
        timeLeft = Self.timeForLevel[level] ?? 15
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                if self.timeLeft > 0 {
                    self.timeLeft -= 1
                } else {
                    self.timer?.invalidate()
                    self.message = "Time's up!"
                    self.messageColor = .orange
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.nextQuestion()
                    }
                }
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func checkAnswer() {
        guard let p = currentPuzzle,
              let a = slot1,
              let b = slot2 else {
            message = "Fill both boxes"
            messageColor = .orange
            return
        }
        if a == b {
            message = "Use each digit only once"
            messageColor = .orange
            return
        }

        let correct: Bool
        switch p.op {
        case "+": correct = (a + b) == p.result
        case "−": correct = (a - b) == p.result
        case "×": correct = (a * b) == p.result
        case "/": correct = b != 0 && (a / b) == p.result
        default: correct = false
        }

        timer?.invalidate()

        if correct {
            score += 1
            message = "Correct!"
            messageColor = .green
            if level < maxLevel { level += 1 }
            lastAccuracy = 100
            lastScore = score * 100
            showingCorrectPopup = true
        } else {
            message = "Try again"
            messageColor = .red
            showingWrongPopup = true
        }
    }

    /// Dynamic question: level ke hisaab se alag-alag equation har baar
    private func nextQuestion() {
        message = ""
        currentPuzzle = generatePuzzleForLevel(level)
        slot1 = nil
        slot2 = nil
        selectedSlot = 1
        startTimer()
    }

    private func finishRun() {
        timer?.invalidate() // Stop the timer when finish is clicked
        if lastScore == 0 {
            lastAccuracy = score > 0 ? 100 : 0
            lastScore = score * 100
        }
        gameResultManager.record(
            gameName: "Digit Challenge",
            maxLevelReached: level,
            accuracy: lastAccuracy,
            avgResponseTime: Date().timeIntervalSince(runStart),
            totalScore: lastScore
        )
        showSummary = true
    }

    private func generatePuzzleForLevel(_ lvl: Int) -> Puzzle {
        switch lvl {
        case 1:
            let result = Int.random(in: 10...14)
            return Puzzle(left: "A", op: "+", right: "B", result: result)
        case 2:
            if Bool.random() {
                let result = Int.random(in: 12...16)
                return Puzzle(left: "A", op: "+", right: "B", result: result)
            } else {
                let result = Int.random(in: 2...6)
                return Puzzle(left: "A", op: "−", right: "B", result: result)
            }
        case 3:
            let ops = ["+", "−", "×"]
            let op = ops.randomElement()!
            if op == "×" {
                let results = [6, 8, 10, 12, 14, 16, 18, 20, 24]
                return Puzzle(left: "A", op: op, right: "B", result: results.randomElement()!)
            } else if op == "+" {
                return Puzzle(left: "A", op: op, right: "B", result: Int.random(in: 14...18))
            } else {
                return Puzzle(left: "A", op: op, right: "B", result: Int.random(in: 1...5))
            }
        case 4:
            let ops = ["+", "−", "×", "/"]
            let op = ops.randomElement()!
            if op == "×" {
                let results = [12, 15, 18, 20, 24, 28, 30]
                return Puzzle(left: "A", op: op, right: "B", result: results.randomElement()!)
            } else if op == "/" {
                let results = [2, 3, 4, 5, 6]
                return Puzzle(left: "A", op: op, right: "B", result: results.randomElement()!)
            } else if op == "+" {
                return Puzzle(left: "A", op: op, right: "B", result: Int.random(in: 15...20))
            } else {
                return Puzzle(left: "A", op: op, right: "B", result: Int.random(in: 2...7))
            }
        default:
            let ops = ["+", "−", "×", "/"]
            let op = ops.randomElement()!
            if op == "×" {
                let results = [18, 24, 28, 30, 32, 36, 40]
                return Puzzle(left: "A", op: op, right: "B", result: results.randomElement()!)
            } else if op == "/" {
                let results = [3, 4, 5, 6, 7, 8]
                return Puzzle(left: "A", op: op, right: "B", result: results.randomElement()!)
            } else if op == "+" {
                return Puzzle(left: "A", op: op, right: "B", result: Int.random(in: 17...22))
            } else {
                return Puzzle(left: "A", op: op, right: "B", result: Int.random(in: 3...8))
            }
        }
    }
}


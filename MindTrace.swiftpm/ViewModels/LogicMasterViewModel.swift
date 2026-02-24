import Foundation
import SwiftUI

@MainActor
final class LogicMasterViewModel: ObservableObject {

    enum PuzzleKind {
        case simplePattern
        case ruleDetection
        case toggleSwitch
    }

    @Published var level: Int = 1
    @Published var question: String = ""
    @Published var options: [String] = []
    @Published var correctIndex: Int = 0
    @Published var selectedIndex: Int? = nil
    @Published var showFeedback: Bool = false
    @Published var isTimed: Bool = false
    @Published var timeLeft: TimeInterval = 0
    @Published var timeTotal: TimeInterval = 0

    @Published var lastAccuracy: Double = 0
    @Published var lastAvgResponseTime: Double = 0
    @Published var lastScore: Int = 0

    private var startTime: Date = Date()
    private var timer: Timer?

    func configureForCurrentLevel() {
        let kind = puzzleKind(for: level)
        buildPuzzle(of: kind)

        selectedIndex = nil
        showFeedback = false
        startTime = Date()

        let timed = level >= 4
        isTimed = timed
        if timed {
            timeTotal = 15
            timeLeft = 15
            startTimer()
        } else {
            timer?.invalidate()
        }
    }

    func submitOption(at index: Int) {
        guard selectedIndex == nil else { return }
        selectedIndex = index
        showFeedback = true
        timer?.invalidate()

        let correct = index == correctIndex
        lastAccuracy = correct ? 100 : 0
        lastAvgResponseTime = Date().timeIntervalSince(startTime)
        lastScore = correct ? 100 * max(1, level) : 0

        if correct {
            level += 1
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            // This view model is @MainActor and the timer runs on the main run loop,
            // so perform state mutations directly without hopping actors.
            guard self.isTimed else {
                self.timer?.invalidate()
                return
            }
            if self.timeLeft > 0 {
                self.timeLeft -= 1
            } else {
                self.timer?.invalidate()
                self.selectedIndex = nil
                self.showFeedback = true
                self.lastAccuracy = 0
                self.lastAvgResponseTime = self.timeTotal
                self.lastScore = 0
            }
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func puzzleKind(for level: Int) -> PuzzleKind {
        switch level {
        case 1: return .simplePattern
        case 2: return .ruleDetection
        case 3: return .toggleSwitch
        default:
            let kinds: [PuzzleKind] = [.simplePattern, .ruleDetection, .toggleSwitch]
            return kinds.randomElement() ?? .simplePattern
        }
    }

    private func buildPuzzle(of kind: PuzzleKind) {
        switch kind {
        case .simplePattern:
            // e.g. 2, 4, 6, ?
            question = "2, 4, 6, ?  – What comes next?"
            options = ["7", "8", "10", "12"]
            correctIndex = 1
        case .ruleDetection:
            question = "Which option follows the same rule as:  ■, ●, ■, ● ?"
            options = [
                "▲, ▲, ▲, ▲",
                "◆, ●, ◆, ●",
                "■, ■, ●, ●",
                "●, ◆, ◆, ●"
            ]
            correctIndex = 1
        case .toggleSwitch:
            question = "A toggle starts OFF. Switch A flips every time, B flips only if currently ON. After A, B, A – state?"
            options = [
                "Always OFF",
                "Always ON",
                "Ends ON",
                "Ends OFF"
            ]
            correctIndex = 2
        }
    }
}


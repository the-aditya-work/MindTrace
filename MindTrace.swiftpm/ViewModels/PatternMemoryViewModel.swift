import Foundation
import SwiftUI

@MainActor
final class PatternMemoryViewModel: ObservableObject {

    enum Phase {
        case preview
        case input
    }

    @Published var level: Int = 1
    @Published var gridSize: Int = 3
    @Published var pattern: [Int] = []
    @Published var taps: [Int] = []
    @Published var phase: Phase = .preview
    @Published var previewTimeTotal: TimeInterval = 4
    @Published var previewTimeRemaining: TimeInterval = 4

    @Published var isShowingPattern: Bool = true

    // Summary stats for last run
    @Published var lastAccuracy: Double = 0
    @Published var lastAvgResponseTime: Double = 0
    @Published var lastScore: Int = 0

    private var displayTimer: Timer?
    private var tapTimestamps: [Date] = []
    private var previewStart: Date = Date()

    func configureForCurrentLevel() {
        let config = levelConfig(for: level)
        gridSize = config.gridSize
        let cellCount = gridSize * gridSize

        var chosen: Set<Int> = []
        while chosen.count < config.patternLength && chosen.count < cellCount {
            chosen.insert(Int.random(in: 0..<cellCount))
        }
        pattern = Array(chosen)
        taps = []
        phase = .preview
        previewTimeTotal = config.previewSeconds
        previewTimeRemaining = config.previewSeconds
        isShowingPattern = true
        previewStart = Date()
        startPreviewTimer()
    }

    func startPreviewTimer() {
        displayTimer?.invalidate()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self else { return }
            // Ensure we're executing on the main run loop/actor for UI-bound state
            if self.phase != .preview {
                // Invalidate via the stored property to avoid sending the non-Sendable `timer`
                self.displayTimer?.invalidate()
                self.displayTimer = nil
                return
            }

            if self.previewTimeRemaining > 0 {
                self.previewTimeRemaining = max(0, self.previewTimeRemaining - 0.1)
            } else {
                // Stop timer updates and transition to input phase entirely on the main actor
                self.displayTimer?.invalidate()
                self.displayTimer = nil
                self.isShowingPattern = false
                self.phase = .input
                self.tapTimestamps = []
            }
        }
        RunLoop.main.add(displayTimer!, forMode: .common)
    }

    func handleTap(on index: Int) {
        guard phase == .input else { return }
        guard !taps.contains(index) else { return }
        taps.append(index)
        tapTimestamps.append(Date())

        if taps.count == pattern.count {
            computeStatsAndScore()
        }
    }

    func computeStatsAndScore() {
        let required = pattern
        let comparedCount = min(required.count, taps.count)
        var correctCount = 0
        for i in 0..<comparedCount {
            if taps[i] == required[i] {
                correctCount += 1
            }
        }
        let accuracy = required.isEmpty ? 0 : (Double(correctCount) / Double(required.count)) * 100.0

        var avgTime: Double = 0
        if tapTimestamps.count > 1 {
            let total = tapTimestamps.last!.timeIntervalSince(previewStart)
            avgTime = total / Double(tapTimestamps.count)
        }

        let baseScore = Int(round(accuracy)) * max(1, level)

        lastAccuracy = accuracy
        lastAvgResponseTime = avgTime
        lastScore = baseScore
    }

    func advanceLevelIfSuccessful() {
        if lastAccuracy >= 70 {
            level += 1
        }
        configureForCurrentLevel()
    }

    private func levelConfig(for level: Int) -> (gridSize: Int, patternLength: Int, previewSeconds: TimeInterval) {
        switch level {
        case 1:
            return (3, 3, 4)
        case 2:
            return (3, 4, 3)
        case 3:
            return (4, 4, 3)
        case 4:
            return (4, 5, 2.5)
        default:
            let extra = level - 4
            let grid = min(6, 4 + (extra / 2))
            let length = min(grid * grid, 5 + extra)
            let preview = max(1.5, 2.5 - Double(extra) * 0.2)
            return (grid, length, preview)
        }
    }
}


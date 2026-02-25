//
//  LogicMasterViewModel.swift
//  MindSpan
//
//  UNUSED FILE - Commented out on 2025-02-26
//  This file is not referenced anywhere in the project
//  LogicMasterChallengeView is already commented out
//

/*
import Foundation
import SwiftUI

@MainActor
final class LogicMasterViewModel: ObservableObject {

    enum PuzzleKind {
        case numberPattern
        case shapeSequence
        case logicalReasoning
        case wordPattern
        case mathematicalPuzzle
        case codeBreaker
        case spatialReasoning
        case analogy
        case syllogism
        case probability
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
        let allKinds: [PuzzleKind] = [
            .numberPattern, .shapeSequence, .logicalReasoning, .wordPattern,
            .mathematicalPuzzle, .codeBreaker, .spatialReasoning, .analogy,
            .syllogism, .probability
        ]
        
        // Early levels get easier puzzles
        if level <= 3 {
            let easyKinds: [PuzzleKind] = [.numberPattern, .shapeSequence, .logicalReasoning]
            return easyKinds.randomElement() ?? .numberPattern
        } else if level <= 6 {
            let mediumKinds: [PuzzleKind] = [.numberPattern, .shapeSequence, .logicalReasoning, .wordPattern, .mathematicalPuzzle]
            return mediumKinds.randomElement() ?? .numberPattern
        } else {
            return allKinds.randomElement() ?? .numberPattern
        }
    }

    private func buildPuzzle(of kind: PuzzleKind) {
        switch kind {
        case .numberPattern:
            buildNumberPatternPuzzle()
        case .shapeSequence:
            buildShapeSequencePuzzle()
        case .logicalReasoning:
            buildLogicalReasoningPuzzle()
        case .wordPattern:
            buildWordPatternPuzzle()
        case .mathematicalPuzzle:
            buildMathematicalPuzzle()
        case .codeBreaker:
            buildCodeBreakerPuzzle()
        case .spatialReasoning:
            buildSpatialReasoningPuzzle()
        case .analogy:
            buildAnalogyPuzzle()
        case .syllogism:
            buildSyllogismPuzzle()
        case .probability:
            buildProbabilityPuzzle()
        }
    }
    
    private func buildNumberPatternPuzzle() {
        let patterns = [
            // Arithmetic sequences
            (question: "3, 7, 11, 15, ?", options: ["17", "19", "21", "23"], answer: 1),
            (question: "1, 4, 9, 16, ?", options: ["20", "25", "30", "36"], answer: 1),
            (question: "2, 6, 18, 54, ?", options: ["108", "162", "216", "324"], answer: 1),
            (question: "100, 81, 64, 49, ?", options: ["25", "36", "42", "45"], answer: 1),
            // Geometric sequences
            (question: "5, 15, 45, 135, ?", options: ["270", "405", "540", "810"], answer: 1),
            (question: "128, 64, 32, 16, ?", options: ["4", "8", "12", "24"], answer: 1),
            // Fibonacci-like
            (question: "1, 1, 2, 3, 5, ?", options: ["6", "7", "8", "9"], answer: 2),
            (question: "2, 3, 5, 8, 13, ?", options: ["18", "19", "21", "23"], answer: 2)
        ]
        
        let selected = patterns.randomElement!
        question = selected.question + "  – What comes next?"
        options = selected.options
        correctIndex = selected.answer
    }
    
    private func buildShapeSequencePuzzle() {
        let patterns = [
            (question: "▲, ●, ■, ▲, ●, ?", options: ["▲", "●", "■", "◆"], answer: 2),
            (question: "○, □, ○, □, ○, ?", options: ["○", "□", "△", "◇"], answer: 1),
            (question: "★, ★, ☆, ★, ★, ☆, ?", options: ["★", "☆", "◆", "●"], answer: 0),
            (question: "⬟, ⬢, ⬟, ⬢, ⬟, ?", options: ["⬟", "⬢", "⬡", "⬠"], answer: 1),
            (question: "◆, ◆, ●, ◆, ◆, ●, ?", options: ["◆", "●", "■", "▲"], answer: 0)
        ]
        
        let selected = patterns.randomElement!
        question = selected.question + "  – Which shape comes next?"
        options = selected.options
        correctIndex = selected.answer
    }
    
    private func buildLogicalReasoningPuzzle() {
        let puzzles = [
            (question: "All roses are flowers. Some flowers fade quickly. Therefore:", options: [
                "All roses fade quickly",
                "Some roses fade quickly", 
                "No roses fade quickly",
                "Cannot determine"
            ], answer: 3),
            (question: "If A = 1, B = 2, C = 3... then CAB = ?", options: ["312", "123", "321", "213"], answer: 0),
            (question: "If 2 cats catch 2 mice in 2 minutes, how many cats to catch 10 mice in 10 minutes?", options: ["2", "5", "10", "20"], answer: 0),
            (question: "Monday + Wednesday = Friday. Tuesday + Thursday = ?", options: ["Saturday", "Sunday", "Monday", "Tuesday"], answer: 0)
        ]
        
        let selected = puzzles.randomElement!
        question = selected.question
        options = selected.options
        correctIndex = selected.answer
    }
    
    private func buildWordPatternPuzzle() {
        let patterns = [
            (question: "Apple, Banana, Cherry, Date, ?", options: ["Elderberry", "Fig", "Grape", "Honeydew"], answer: 0),
            (question: "Cat, Dog, Elephant, Fox, ?", options: ["Goat", "Horse", "Lion", "Zebra"], answer: 0),
            (question: "Red, Orange, Yellow, Green, ?", options: ["Blue", "Purple", "Pink", "Brown"], answer: 0),
            (question: "Spring, Summer, Autumn, Winter, ?", options: ["Spring", "Rain", "Sun", "Snow"], answer: 0),
            (question: "2, 4, 8, 16, 32, ?", options: ["48", "64", "96", "128"], answer: 1)
        ]
        
        let selected = patterns.randomElement!
        question = selected.question + "  – What comes next in the pattern?"
        options = selected.options
        correctIndex = selected.answer
    }
    
    private func buildMathematicalPuzzle() {
        let puzzles = [
            (question: "If 5 + 3 = 28, 9 + 1 = 810, then 6 + 2 = ?", options: ["48", "64", "82", "124"], answer: 0),
            (question: "What is 15% of 80?", options: ["8", "12", "15", "20"], answer: 1),
            (question: "If x + 7 = 12 and y - 3 = 5, then x + y = ?", options: ["10", "12", "14", "16"], answer: 1),
            (question: "A rectangle has perimeter 24 and area 32. Find its length.", options: ["4", "6", "8", "12"], answer: 2),
            (question: "If 3^2 = 9 and 4^2 = 16, then 5^3 = ?", options: ["25", "75", "125", "225"], answer: 2)
        ]
        
        let selected = puzzles.randomElement!
        question = selected.question
        options = selected.options
        correctIndex = selected.answer
    }
    
    private func buildCodeBreakerPuzzle() {
        let codes = [
            (question: "If A=Z, B=Y, C=X... then HELLO = ?", options: ["SVOOL", "OLLEH", "JHOOP", "KHOOR"], answer: 0),
            (question: "If 1=A, 2=B, 3=C... then 19-5-12-12-15 = ?", options: ["HELLO", "WORLD", "BRAIN", "MINDS"], answer: 0),
            (question: "If CAT = 3+1+20 = 24, then DOG = ?", options: ["26", "27", "28", "29"], answer: 0),
            (question: "If Monday=1, Tuesday=2... then Sunday = ?", options: ["5", "6", "7", "8"], answer: 2)
        ]
        
        let selected = codes.randomElement!
        question = selected.question
        options = selected.options
        correctIndex = selected.answer
    }
    
    private func buildSpatialReasoningPuzzle() {
        let puzzles = [
            (question: "A cube has 6 faces. If 3 faces are painted, how many faces remain unpainted?", options: ["1", "2", "3", "4"], answer: 2),
            (question: "How many triangles are in a star (pentagram)?", options: ["5", "10", "15", "20"], answer: 1),
            (question: "If you fold this net: □□□□, what 3D shape do you get?", options: ["Cube", "Pyramid", "Cylinder", "Sphere"], answer: 0),
            (question: "A clock shows 3:15. What's the angle between hour and minute hands?", options: ["0°", "7.5°", "15°", "30°"], answer: 1)
        ]
        
        let selected = puzzles.randomElement!
        question = selected.question
        options = selected.options
        correctIndex = selected.answer
    }
    
    private func buildAnalogyPuzzle() {
        let analogies = [
            (question: "Doctor is to Patient as Teacher is to ?", options: ["Student", "Book", "Classroom", "Principal"], answer: 0),
            (question: "Pen is to Write as Knife is to ?", options: ["Cut", "Food", "Kitchen", "Sharp"], answer: 0),
            (question: "Car is to Road as Boat is to ?", options: ["Water", "Dock", "Sail", "Engine"], answer: 0),
            (question: "Book is to Library as Painting is to ?", options: ["Museum", "Artist", "Canvas", "Frame"], answer: 0),
            (question: "Seed is to Tree as Kitten is to ?", options: ["Cat", "Milk", "Meow", "Paws"], answer: 0)
        ]
        
        let selected = analogies.randomElement!
        question = selected.question
        options = selected.options
        correctIndex = selected.answer
    }
    
    private func buildSyllogismPuzzle() {
        let syllogisms = [
            (question: "All mammals are warm-blooded. Whales are mammals. Therefore:", options: [
                "Whales are cold-blooded",
                "Whales are warm-blooded",
                "All warm-blooded are whales",
                "Cannot determine"
            ], answer: 1),
            (question: "No birds are mammals. Some bats are mammals. Therefore:", options: [
                "Some bats are birds",
                "No bats are birds",
                "All bats are birds",
                "Cannot determine"
            ], answer: 1),
            (question: "Some students are athletes. All athletes are fit. Therefore:", options: [
                "All students are fit",
                "Some students are fit",
                "No students are fit",
                "Cannot determine"
            ], answer: 1)
        ]
        
        let selected = syllogisms.randomElement!
        question = selected.question
        options = selected.options
        correctIndex = selected.answer
    }
    
    private func buildProbabilityPuzzle() {
        let probabilities = [
            (question: "A coin is tossed 3 times. Probability of getting exactly 2 heads?", options: ["1/8", "3/8", "1/2", "3/4"], answer: 1),
            (question: "A die is rolled. Probability of getting an even number?", options: ["1/6", "1/3", "1/2", "2/3"], answer: 2),
            (question: "From 52 cards, probability of drawing a heart?", options: ["1/4", "1/13", "1/52", "3/4"], answer: 0),
            (question: "Two dice rolled. Probability of sum = 7?", options: ["1/6", "1/12", "1/36", "5/36"], answer: 0)
        ]
        
        let selected = probabilities.randomElement!
        question = selected.question
        options = selected.options
        correctIndex = selected.answer
    }
}

*/


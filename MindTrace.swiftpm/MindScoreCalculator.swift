//
//  File.swift
//  MindSpan
//
//  Created by Aditya Rai on 29/01/26.
//

struct MindScoreCalculator {

    static func calculate(result: MemoryResult) -> Double {
        let accuracy = Double(result.correctAnswers) / Double(result.totalQuestions)
        let distractionPenalty = Double(result.distractionLevel) * 0.05
        return max((accuracy - distractionPenalty) * 100, 0)
    }
}

//
//  File.swift
//  MindSpan
//
//  Created by Aditya Rai on 29/01/26.
//

import Foundation

final class MemoryDataController: ObservableObject {

    @Published var memoryItems: [MemoryItem] = []
    @Published var results: [MemoryResult] = []

    func generateSequence() {
        memoryItems = [
            MemoryItem(type: .color, value: "Red", displayTime: 3),
            MemoryItem(type: .shape, value: "Circle", displayTime: 3),
            MemoryItem(type: .word, value: "Tree", displayTime: 3),
            MemoryItem(type: .symbol, value: "★", displayTime: 3),
            MemoryItem(type: .pattern, value: "ZigZag", displayTime: 3),
            MemoryItem(type: .color, value: "Blue", displayTime: 3)
        ]
    }

    func saveResult(_ result: MemoryResult) {
        results.append(result)
    }
}

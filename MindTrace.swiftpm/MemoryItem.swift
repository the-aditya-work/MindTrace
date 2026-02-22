//
//  File.swift
//  MindSpan
//
//  Created by Aditya Rai on 29/01/26.
//

import SwiftUI

enum MemoryType {
    case color
    case shape
    case word
    case symbol
    case pattern
}

struct MemoryItem: Identifiable {
    let id = UUID()
    let type: MemoryType
    let value: String
    let displayTime: Double
}

import Foundation

struct GameResult: Identifiable, Codable {
    let id: UUID
    let gameName: String
    let maxLevelReached: Int
    let accuracy: Double
    let avgResponseTime: Double
    let totalScore: Int
    let date: Date
}


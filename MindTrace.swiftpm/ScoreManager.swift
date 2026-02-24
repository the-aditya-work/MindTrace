import Foundation

/// Central score manager shared across Map and Test tabs.
/// Persists lightweight game sessions locally so Mind% can show analytics.
final class ScoreManager: ObservableObject {

    @MainActor static let shared = ScoreManager()

    @Published private(set) var sessions: [GameSession] = []

    private let storageKey = "mindtrace.score.sessions.v1"

    init() {
        load()
    }

    // MARK: - Public API

    struct GameSession: Identifiable, Codable {
        let id: UUID
        let date: Date
        let topic: String
        let source: GameSource
        let score: Int   // 0–100
    }

    enum GameSource: String, Codable {
        case map
        case test
    }

    func record(topic: String, source: GameSource, score: Int) {
        let clamped = max(0, min(score, 100))
        let session = GameSession(
            id: UUID(),
            date: Date(),
            topic: topic,
            source: source,
            score: clamped
        )
        sessions.append(session)
        save()
    }

    // MARK: - Aggregates

    var totalGamesPlayed: Int {
        sessions.count
    }

    var bestScore: Int {
        sessions.map(\.score).max() ?? 0
    }

    var averageScore: Int {
        guard !sessions.isEmpty else { return 0 }
        let total = sessions.map(\.score).reduce(0, +)
        return Int(round(Double(total) / Double(sessions.count)))
    }

    var lastPlayedTopic: String? {
        sessions.sorted { $0.date > $1.date }.first?.topic
    }

    /// Average score per topic.
    var topicAverages: [(topic: String, average: Int)] {
        let grouped = Dictionary(grouping: sessions, by: { $0.topic })
        let pairs = grouped.map { (topic, sessions) -> (String, Int) in
            let total = sessions.map(\.score).reduce(0, +)
            let avg = Int(round(Double(total) / Double(sessions.count)))
            return (topic, avg)
        }
        return pairs.sorted { $0.0 < $1.0 }
    }

    // MARK: - Persistence

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([GameSession].self, from: data)
            sessions = decoded
        } catch {
            // If decoding fails, start fresh but don't crash the app.
            sessions = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Ignore write errors for now; analytics are non-critical.
        }
    }
}


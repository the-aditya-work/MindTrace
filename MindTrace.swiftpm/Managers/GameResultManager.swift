import Foundation

final class GameResultManager: ObservableObject {

    @MainActor static let shared = GameResultManager()

    @Published private(set) var results: [GameResult] = []

    private let storageKey = "mindtrace.gameResults.v1"

    private init() {
        load()
    }

    // MARK: - Public API

    func record(
        gameName: String,
        maxLevelReached: Int,
        accuracy: Double,
        avgResponseTime: Double,
        totalScore: Int
    ) {
        let clampedAccuracy = max(0, min(accuracy, 100))
        let safeScore = max(0, totalScore)

        let result = GameResult(
            id: UUID(),
            gameName: gameName,
            maxLevelReached: maxLevelReached,
            accuracy: clampedAccuracy,
            avgResponseTime: max(0, avgResponseTime),
            totalScore: safeScore,
            date: Date()
        )
        results.append(result)
        save()
    }

    // MARK: - Aggregates

    var totalGames: Int {
        results.count
    }

    var bestScore: Int {
        results.map(\.totalScore).max() ?? 0
    }

    var averageScore: Int {
        guard !results.isEmpty else { return 0 }
        let total = results.map(\.totalScore).reduce(0, +)
        return Int(round(Double(total) / Double(results.count)))
    }

    var lastGameName: String? {
        results.sorted { $0.date > $1.date }.first?.gameName
    }

    /// Average totalScore per gameName.
    var gameAverages: [(gameName: String, average: Int)] {
        let grouped = Dictionary(grouping: results, by: { $0.gameName })
        let pairs = grouped.map { (name, items) -> (String, Int) in
            let total = items.map(\.totalScore).reduce(0, +)
            let avg = Int(round(Double(total) / Double(items.count)))
            return (name, avg)
        }
        return pairs.sorted { $0.0 < $1.0 }
    }

    // MARK: - Persistence

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([GameResult].self, from: data)
            results = decoded
        } catch {
            results = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(results)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Non‑critical
        }
    }
}


import SwiftUI

@main
struct MindSpanApp: App {

    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var gameResultManager = GameResultManager.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(scoreManager)
                .environmentObject(gameResultManager)
        }
    }
}



import SwiftUI

@main
struct MindSpanApp: App {

    @StateObject private var scoreManager = ScoreManager.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(scoreManager)
        }
    }
}



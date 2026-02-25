import SwiftUI

@main
struct MindSpanApp: App {

    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var gameResultManager = GameResultManager.shared
    @StateObject private var onboardingViewModel = OnboardingViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingViewModel.isOnboardingComplete || OnboardingViewModel.hasCompletedOnboarding() {
                    MainTabView()
                        .environmentObject(scoreManager)
                        .environmentObject(gameResultManager)
                } else {
                    OnboardingView(viewModel: onboardingViewModel)
                        .environmentObject(onboardingViewModel)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: onboardingViewModel.isOnboardingComplete)
        }
    }
}



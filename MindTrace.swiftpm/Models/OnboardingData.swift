import Foundation

struct OnboardingFeature {
    let id: Int
    let title: String
    let description: String
    let iconName: String
    let benefit: String
    let color: String
}

class OnboardingData: ObservableObject {
    static let features: [OnboardingFeature] = [
        OnboardingFeature(
            id: 0,
            title: "Memory Games",
            description: "Challenge your brain with 9 different cognitive games designed to improve memory, logic, and problem-solving skills.",
            iconName: "brain.head.profile",
            benefit: "Enhances memory, concentration, and logical thinking abilities",
            color: "blue"
        ),
        OnboardingFeature(
            id: 1,
            title: "Eyesight Challenge",
            description: "Progressive number memorization game that tests and improves your visual memory and recall speed.",
            iconName: "eye.circle.fill",
            benefit: "Sharpens visual memory and increases processing speed",
            color: "purple"
        ),
        OnboardingFeature(
            id: 2,
            title: "Performance Dashboard",
            description: "Track your progress with detailed analytics, scores, and mastery levels across all games.",
            iconName: "chart.bar.fill",
            benefit: "Monitor improvement and identify areas for growth",
            color: "green"
        )
    ]
    
    static let welcomeTitle = "Welcome to MindTrace"
    static let welcomeSubtitle = "Your personal brain training companion"
    static let welcomeDescription = "Train your mind with scientifically designed games that enhance memory, logic, and cognitive abilities."
    
    static let completionTitle = "Ready to Start!"
    static let completionSubtitle = "Your brain training journey begins now"
    static let completionDescription = "Begin exploring all features and track your progress as you improve."
}

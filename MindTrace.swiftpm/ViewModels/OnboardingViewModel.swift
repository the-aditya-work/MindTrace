import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var isOnboardingComplete: Bool = false
    
    private let totalSteps = 5 // Welcome + 3 features + Completion
    
    var progress: Double {
        Double(currentStep) / Double(totalSteps - 1)
    }
    
    var isWelcomeStep: Bool {
        currentStep == 0
    }
    
    var isCompletionStep: Bool {
        currentStep == totalSteps - 1
    }
    
    var currentFeature: OnboardingFeature? {
        guard currentStep > 0 && currentStep < totalSteps - 1 else { return nil }
        return OnboardingData.features[currentStep - 1]
    }
    
    func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep -= 1
            }
        }
    }
    
    func skipOnboarding() {
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isOnboardingComplete = true
        }
        
        // Save onboarding completion status
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    static func hasCompletedOnboarding() -> Bool {
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        currentStep = 0
        isOnboardingComplete = false
    }
}

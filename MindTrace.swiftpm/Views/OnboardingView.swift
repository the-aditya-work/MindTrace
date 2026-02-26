import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var viewModel: OnboardingViewModel
    @State private var animateIcon: Bool = false
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.primary.opacity(0.1),
                        Color.blue.opacity(0.3),
                        Color.purple.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Content area
                    VStack(spacing: 30) {
                        contentView
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Progress indicator
                    progressIndicator
                    
                    // Bottom controls
                    bottomControls
                        .padding(.horizontal, 24)
                        .padding(.bottom, 60)
                }
            }
        .edgesIgnoringSafeArea(.top)
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index == viewModel.currentStep ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == viewModel.currentStep ? 1.2 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentStep)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isWelcomeStep {
            welcomeView
        } else if let feature = viewModel.currentFeature {
            featureView(feature)
        } else if viewModel.isCompletionStep {
            completionView
        }
    }
    
    // MARK: - Welcome View
    
    private var welcomeView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App icon
            Image("AppIcon1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .cornerRadius(20)
            
            // Welcome text
            VStack(spacing: 20) {
                Text(OnboardingData.welcomeTitle)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text(OnboardingData.welcomeSubtitle)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Feature View
    
    private func featureView(_ feature: OnboardingFeature) -> some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Feature icon
            Image(systemName: feature.iconName)
                .font(.system(size: 60, weight: .medium))
                .foregroundStyle(colorForFeature(feature.color))
            
            // Feature content
            VStack(spacing: 16) {
                Text(feature.title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text(feature.description)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Completion View
    
    private var completionView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60, weight: .medium))
                .foregroundStyle(.green)
            
            // Completion text
            VStack(spacing: 16) {
                Text(OnboardingData.completionTitle)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text(OnboardingData.completionSubtitle)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Primary action button
            Button {
                viewModel.nextStep()
            } label: {
                HStack(spacing: 12) {
                    Text(primaryButtonText)
                        .font(.headline.weight(.semibold))
                    
                    if !viewModel.isCompletionStep {
                        Image(systemName: "arrow.right")
                            .font(.headline.weight(.semibold))
                    }
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.regularMaterial)
                )
            }
            .buttonStyle(.scaleOnPress)
            
            // Secondary actions
            HStack(spacing: 16) {
                // Back button
                if viewModel.currentStep > 0 {
                    Button("Back") {
                        viewModel.previousStep()
                    }
                    .foregroundColor(.primary)
                    .font(.subheadline.weight(.medium))
                    .buttonStyle(.scaleOnPress)
                }
                
                Spacer()
                
                // Skip button
                if !viewModel.isCompletionStep {
                    Button("Skip") {
                        viewModel.skipOnboarding()
                    }
                    .foregroundColor(.secondary)
                    .font(.subheadline.weight(.medium))
                    .buttonStyle(.scaleOnPress)
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var primaryButtonText: String {
        if viewModel.isCompletionStep {
            return "Get Started"
        } else {
            return "Next"
        }
    }
    
    private func colorForFeature(_ colorName: String) -> LinearGradient {
        switch colorName {
        case "blue":
            return LinearGradient(
                colors: [.blue, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "purple":
            return LinearGradient(
                colors: [.purple, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "green":
            return LinearGradient(
                colors: [.green, .mint],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [.white, .gray],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(viewModel: OnboardingViewModel())
}

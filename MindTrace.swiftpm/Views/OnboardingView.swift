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
                        Color.black.opacity(0.8),
                        Color.blue.opacity(0.6),
                        Color.purple.opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicator
                    progressIndicator
                    
                    // Content area
                    ScrollView {
                        VStack(spacing: 30) {
                            contentView
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 40)
                    }
                    
                    // Bottom controls
                    bottomControls
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
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
                        .fill(index == viewModel.currentStep ? Color.white : Color.white.opacity(0.3))
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
            // App icon
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateIcon)
            }
            
            // Welcome text
            VStack(spacing: 16) {
                Text(OnboardingData.welcomeTitle)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text(OnboardingData.welcomeSubtitle)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                Text(OnboardingData.welcomeDescription)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
        .onAppear {
            animateIcon = true
        }
    }
    
    // MARK: - Feature View
    
    private func featureView(_ feature: OnboardingFeature) -> some View {
        VStack(spacing: 30) {
            // Feature icon
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                
                Image(systemName: feature.iconName)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(colorForFeature(feature.color))
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateIcon)
            }
            
            // Feature content
            VStack(spacing: 20) {
                Text(feature.title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text(feature.description)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                // Benefit card
                HStack(spacing: 12) {
                    Image(systemName: "star.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Key Benefit")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Text(feature.benefit)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
        .onAppear {
            animateIcon = true
        }
    }
    
    // MARK: - Completion View
    
    private var completionView: some View {
        VStack(spacing: 30) {
            // Success icon
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(.green)
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateIcon)
            }
            
            // Completion text
            VStack(spacing: 16) {
                Text(OnboardingData.completionTitle)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text(OnboardingData.completionSubtitle)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                Text(OnboardingData.completionDescription)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
        .onAppear {
            animateIcon = true
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
                        .fill(.white)
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
                    .foregroundColor(.white)
                    .font(.subheadline.weight(.medium))
                    .buttonStyle(.scaleOnPress)
                }
                
                Spacer()
                
                // Skip button
                if !viewModel.isCompletionStep {
                    Button("Skip") {
                        viewModel.skipOnboarding()
                    }
                    .foregroundColor(.white.opacity(0.8))
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

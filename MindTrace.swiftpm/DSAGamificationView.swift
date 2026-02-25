import SwiftUI

struct DSAGamificationView: View {

    @EnvironmentObject private var scoreManager: ScoreManager

    private let accent = Color.blue

    private enum Phase { case intro, playing }

    @State private var phase: Phase = .intro
    @State private var level: Int = 1
    @State private var generatedDigits: [Int] = []
    @State private var inputDigits: [Int] = []
    @State private var showingDigits: Bool = true
    @State private var statusText: String = "Memorize the number"

    @State private var totalDisplayTime: Double = 5
    @State private var remainingDisplayTime: Double = 5
    @State private var inputTimeLimit: Double = 10
    @State private var remainingInputTime: Double = 10
    @State private var inputStartTime: Date?
    @State private var totalInputTime: Double = 0
    @State private var showingFeedback: Bool = false
    @State private var isCorrectAnswer: Bool = false
    @State private var levelScores: [Int] = []
    @State private var showingResult: Bool = false
    @State private var averageScore: Int = 0

    @State private var isAnimatingSuccess: Bool = false

    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.white,
                        Color.blue.opacity(0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    if phase == .intro {
                        introSection
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        topSection
                            .transition(.opacity)
                        inputSection
                        numberPad
                    }
                    Spacer(minLength: 12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
            .navigationTitle("Eyesight Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(phase == .intro)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if phase == .playing && !showingDigits {
                        Button("Finish") {
                            finishGame()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                prepareLevel()
            }
            .onReceive(timer) { _ in
                guard phase == .playing else { return }
                
                if showingDigits {
                    guard remainingDisplayTime > 0 else {
                        showingDigits = false
                        statusText = "Enter the number"
                        inputStartTime = Date()
                        remainingInputTime = inputTimeLimit
                        return
                    }
                    remainingDisplayTime = max(0, remainingDisplayTime - 0.1)
                } else {
                    guard remainingInputTime > 0 else {
                        statusText = "Time's up! Try again"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            startLevel(resetLevel: false)
                        }
                        return
                    }
                    remainingInputTime = max(0, remainingInputTime - 0.1)
                }
            }
            .overlay {
                if showingFeedback {
                    feedbackPopUp
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1000)
                }
                
                if showingResult {
                    resultPopUp
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1000)
                }
            }
        }
    }

    // MARK: - Sections

    private var introSection: some View {
        VStack(spacing: 24) {
            // Header Card
            VStack(spacing: 12) {
                Image(systemName: "eye.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [accent, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Eyesight Challenge")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)

                Text("Memory + eyesight training in quick levels.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.5))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [accent.opacity(0.3), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)

            // Instructions Card
            VStack(alignment: .leading, spacing: 14) {
                Text("How to Play")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                VStack(alignment: .leading, spacing: 12) {
                    instructionRow(
                        icon: "eye.circle.fill",
                        title: "Memorize",
                        description: "A number flashes for a few seconds"
                    )
                    
                    instructionRow(
                        icon: "number.circle.fill",
                        title: "Recall",
                        description: "It hides — you re‑enter it using the keypad"
                    )
                    
                    instructionRow(
                        icon: "arrow.triangle.2.circlepath.circle.fill",
                        title: "Progress",
                        description: "Correct = next level, Wrong = retry"
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)

            // Level Info Card
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "star.circle.fill")
                        .foregroundStyle(accent)
                    Text("Level \(level) • \(targetDigitCount) digits • \(Int(levelConfig(for: level).seconds))s")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                }
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        phase = .playing
                    }
                    startLevel(resetLevel: true)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Begin")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [accent, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                    .shadow(color: accent.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.scaleOnPress)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(accent.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private func instructionRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(accent)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }

    private var topSection: some View {
        VStack(spacing: 12) {
            Text("Eyesight Challenge")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text("Level \(level)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(accent.opacity(0.8))

            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.white.opacity(0.7))
                            .blur(radius: 12)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 10)

                VStack(spacing: 14) {
                    Text(displayDigitsText)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .kerning(4)
                        .foregroundStyle(.primary)
                        .opacity(showingDigits ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: showingDigits)
                        .scaleEffect(isAnimatingSuccess ? 1.05 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isAnimatingSuccess)

                    VStack(spacing: 6) {
                        Text(statusText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        if showingDigits {
                            ProgressView(value: remainingDisplayTime, total: totalDisplayTime)
                                .tint(accent)
                        } else {
                            VStack(spacing: 4) {
                                HStack {
                                    Text("Time: \(String(format: "%.1f", remainingInputTime))s")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(remainingInputTime <= 3 ? .red : .secondary)
                                    Spacer()
                                }
                                ProgressView(value: remainingInputTime, total: inputTimeLimit)
                                    .tint(remainingInputTime <= 3 ? .red : accent)
                            }
                        }
                    }
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
        }
    }

    private var inputSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                ForEach(0..<targetDigitCount, id: \.self) { index in
                    let filled = index < inputDigits.count
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(
                                borderColor(for: index),
                                lineWidth: 2
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white.opacity(0.9))
                            )

                        Text(filled ? "\(inputDigits[index])" : "")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    .frame(height: 52)
                }
            }
        }
    }

    private var numberPad: some View {
        VStack(spacing: 14) {
            VStack(spacing: 12) {
                numberRow([1, 2, 3])
                numberRow([4, 5, 6])
                numberRow([7, 8, 9])
            }

            HStack(spacing: 14) {
                Spacer()
                keypadButton(label: "0") { handleDigitTap(0) }
                keypadDeleteButton
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Components

    private func numberRow(_ digits: [Int]) -> some View {
        HStack(spacing: 14) {
            ForEach(digits, id: \.self) { digit in
                keypadButton(label: "\(digit)") {
                    handleDigitTap(digit)
                }
            }
        }
    }

    private func keypadButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                )
        }
        .buttonStyle(.scaleOnPress)
        .disabled(showingDigits || phase != .playing)
        .opacity((showingDigits || phase != .playing) ? 0.4 : 1.0)
    }

    private var keypadDeleteButton: some View {
        Button {
            guard !showingDigits, !inputDigits.isEmpty else { return }
            inputDigits.removeLast()
        } label: {
            Image(systemName: "delete.left")
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                )
        }
        .buttonStyle(.scaleOnPress)
        .disabled(showingDigits || inputDigits.isEmpty || phase != .playing)
        .opacity((showingDigits || phase != .playing) ? 0.3 : 1.0)
    }

    // MARK: - Logic

    private var targetDigitCount: Int {
        let config = levelConfig(for: level)
        return config.digits
    }

    private var displayDigitsText: String {
        generatedDigits.map(String.init).joined()
    }

    private func borderColor(for index: Int) -> Color {
        let isActive = index == inputDigits.count && !showingDigits
        return isActive ? accent : Color.gray.opacity(0.2)
    }

    private func handleDigitTap(_ digit: Int) {
        guard phase == .playing else { return }
        guard !showingDigits else { return }
        guard inputDigits.count < targetDigitCount else { return }

        inputDigits.append(digit)

        if inputDigits.count == targetDigitCount {
            checkAnswer()
        }
    }

    private func checkAnswer() {
        let required = Array(generatedDigits.prefix(targetDigitCount))
        let correct = inputDigits == required
        
        // Calculate input time for scoring
        if let startTime = inputStartTime {
            totalInputTime = Date().timeIntervalSince(startTime)
        }
        
        // Calculate score
        let timeBonus = calculateTimeBonus()
        let totalScore = 100 + timeBonus
        
        // Store score for this level
        levelScores.append(totalScore)
        
        // Record score
        scoreManager.record(
            topic: "Eyesight Level \(level)",
            source: .map,
            score: totalScore
        )
        
        // Show feedback pop-up
        isCorrectAnswer = correct
        showingFeedback = true
    }
    
    private func calculateTimeBonus() -> Int {
        guard totalInputTime > 0 else { return 0 }
        
        let timeRatio = remainingInputTime / inputTimeLimit
        let bonus = Int(timeRatio * 50) // Max 50 bonus points
        return max(0, bonus)
    }
    
    private func finishGame() {
        // Calculate average score
        if !levelScores.isEmpty {
            averageScore = levelScores.reduce(0, +) / levelScores.count
        } else {
            averageScore = 0
        }
        
        // Show result pop-up
        showingResult = true
        
        // Record final score
        scoreManager.record(
            topic: "Eyesight Challenge (Finished)",
            source: .map,
            score: averageScore
        )
    }

    private func startLevel(resetLevel: Bool) {
        let config = levelConfig(for: level)
        generatedDigits = (0..<config.digits).map { _ in Int.random(in: 0...9) }
        inputDigits = []
        showingDigits = true
        totalDisplayTime = config.seconds
        remainingDisplayTime = config.seconds
        inputTimeLimit = max(8, config.seconds * 2) // Input time based on display time
        remainingInputTime = inputTimeLimit
        inputStartTime = nil
        totalInputTime = 0
        statusText = "Memorize the number"
    }

    private func prepareLevel() {
        let config = levelConfig(for: level)
        generatedDigits = (0..<config.digits).map { _ in Int.random(in: 0...9) }
        inputDigits = []
        showingDigits = false
        totalDisplayTime = config.seconds
        remainingDisplayTime = config.seconds
        inputTimeLimit = max(8, config.seconds * 2)
        remainingInputTime = inputTimeLimit
        inputStartTime = nil
        totalInputTime = 0
        statusText = "Tap Begin to start"
    }

    private func levelConfig(for level: Int) -> (digits: Int, seconds: Double) {
        switch level {
        case 1:
            return (4, 5)
        case 2:
            return (4, 4)
        case 3:
            return (5, 4)
        case 4:
            return (5, 3)
        default:
            let extra = level - 4
            let digits = 5 + extra / 2
            let seconds = max(1.5, 3 - Double(extra) * 0.3)
            return (digits, seconds)
        }
    }
}

// MARK: - Pop-up Views

extension DSAGamificationView {
    
    private var feedbackPopUp: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Prevent dismissing by tapping outside
                }
            
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: isCorrectAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(isCorrectAnswer ? .green : .red)
                    
                    Text(isCorrectAnswer ? "You are right!" : "Wrong")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    if isCorrectAnswer {
                        Text("Great job! Ready for next level?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Let's try again")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                HStack(spacing: 12) {
                    if isCorrectAnswer {
                        Button("Move Next") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingFeedback = false
                                level += 1
                                startLevel(resetLevel: false)
                            }
                        }
                        .buttonStyle(.prominentButtonStyle)
                        .tint(.green)
                        
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingFeedback = false
                                phase = .intro
                            }
                        }
                        .buttonStyle(.secondaryButtonStyle)
                    } else {
                        Button("Try Again") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingFeedback = false
                                startLevel(resetLevel: false)
                            }
                        }
                        .buttonStyle(.prominentButtonStyle)
                        .tint(.orange)
                        
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingFeedback = false
                                phase = .intro
                            }
                        }
                        .buttonStyle(.secondaryButtonStyle)
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.9))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
    
    private var resultPopUp: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Prevent dismissing by tapping outside
                }
            
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)
                    
                    Text("Game Finished!")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Text("Your Average Score")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("\(averageScore)%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Levels completed: \(levelScores.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Button("Back to Menu") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingResult = false
                        phase = .intro
                        levelScores = []
                        level = 1
                    }
                }
                .buttonStyle(.prominentButtonStyle)
                .tint(.blue)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.9))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

// MARK: - Custom Button Styles

struct ProminentButtonStyle: ButtonStyle {
    let tint: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [tint, tint.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.secondary)
            .font(.headline.weight(.medium))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ProminentButtonStyle {
    static var prominentButtonStyle: ProminentButtonStyle { ProminentButtonStyle(tint: .blue) }
    static func prominentButtonStyle(tint: Color) -> ProminentButtonStyle { ProminentButtonStyle(tint: tint) }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondaryButtonStyle: SecondaryButtonStyle { SecondaryButtonStyle() }
}

// MARK: - Button Style

struct ScaleOnPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ScaleOnPressStyle {
    static var scaleOnPress: ScaleOnPressStyle { ScaleOnPressStyle() }
}

#Preview {
    DSAGamificationView()
        .environmentObject(ScoreManager.shared)
}


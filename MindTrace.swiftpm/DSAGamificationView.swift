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
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                prepareLevel()
            }
            .onReceive(timer) { _ in
                guard phase == .playing else { return }
                guard showingDigits else { return }
                guard remainingDisplayTime > 0 else {
                    showingDigits = false
                    statusText = "Enter the number"
                    return
                }
                remainingDisplayTime = max(0, remainingDisplayTime - 0.1)
            }
        }
    }

    // MARK: - Sections

    private var introSection: some View {
        VStack(spacing: 18) {
            VStack(spacing: 8) {
                Text("Eyesight Challenge")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)

                Text("Memory + eyesight training in quick levels.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 10) {
                Label("A number flashes for a few seconds", systemImage: "eye")
                Label("It hides — you re‑enter it using the keypad", systemImage: "number")
                Label("Correct = next level, Wrong = retry", systemImage: "arrow.triangle.2.circlepath")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.18))
            )
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)

            VStack(spacing: 10) {
                Text("Level \(level) • \(targetDigitCount) digits • \(Int(levelConfig(for: level).seconds))s")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(accent.opacity(0.9))

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        phase = .playing
                    }
                    startLevel(resetLevel: true)
                } label: {
                    HStack(spacing: 10) {
                        Text("Begin")
                            .font(.headline)
                        Image(systemName: "play.circle.fill")
                            .font(.title3)
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [accent, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 10)
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
                            ProgressView(value: 0, total: 1)
                                .tint(accent.opacity(0.15))
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

        if correct {
            statusText = "Correct! Moving to next level"
            isAnimatingSuccess = true
            scoreManager.record(
                topic: "Eyesight Level \(level)",
                source: .map,
                score: 100
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                level += 1
                isAnimatingSuccess = false
                startLevel(resetLevel: false)
            }
        } else {
            statusText = "Try Again"
            isAnimatingSuccess = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                startLevel(resetLevel: false)
            }
        }
    }

    private func startLevel(resetLevel: Bool) {
        let config = levelConfig(for: level)
        generatedDigits = (0..<config.digits).map { _ in Int.random(in: 0...9) }
        inputDigits = []
        showingDigits = true
        totalDisplayTime = config.seconds
        remainingDisplayTime = config.seconds
        statusText = "Memorize the number"
    }

    private func prepareLevel() {
        let config = levelConfig(for: level)
        generatedDigits = (0..<config.digits).map { _ in Int.random(in: 0...9) }
        inputDigits = []
        showingDigits = false
        totalDisplayTime = config.seconds
        remainingDisplayTime = config.seconds
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


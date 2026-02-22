//
//  File.swift
//  MindSpan
//
//  Created by Aditya Rai on 16/02/26.
//

import SwiftUI

struct BasicColorMemoryGameView: View {

    enum GamePhase {
        case sequence
        case recall
        case result
    }

    @State private var phase: GamePhase = .sequence
    @State private var colors: [Color] = []
    @State private var currentIndex = 0
    @State private var showColor = false
    @State private var score = 0

    let totalRounds = 5

    var body: some View {

        ZStack {
            LinearGradient(
                colors: [
                    Color.pink.opacity(0.3),
                    Color.purple.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {

                switch phase {

                case .sequence:
                    sequenceView

                case .recall:
                    recallView

                case .result:
                    resultView
                }
            }
            .padding()
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            startGame()
        }
    }
}

// MARK: - Logic
extension BasicColorMemoryGameView {

    func startGame() {
        colors = generateColors()
        currentIndex = 0
        score = 0
        phase = .sequence
        playSequence()
    }

    func generateColors() -> [Color] {
        let palette: [Color] = [.mint, .orange, .blue, .purple, .pink, .teal]
        return Array(palette.shuffled().prefix(totalRounds))
    }

    func playSequence() {
        guard currentIndex < colors.count else {
            phase = .recall
            return
        }

        showColor = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            showColor = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentIndex += 1
                playSequence()
            }
        }
    }

    func calculatePercentage() -> Int {
        Int((Double(score) / Double(totalRounds)) * 100)
    }
}

// MARK: - Views
extension BasicColorMemoryGameView {

    var sequenceView: some View {
        VStack(spacing: 20) {

            Text("Observe the Colors")
                .font(.headline)

            if showColor {
                RoundedRectangle(cornerRadius: 24)
                    .fill(colors[currentIndex])
                    .frame(height: 220)
                    .shadow(radius: 12)
                    .transition(.scale)
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 220)
            }
        }
    }

    var recallView: some View {
        VStack(spacing: 20) {

            Text("Which color did you see?")
                .font(.headline)

            ForEach(colors.shuffled(), id: \.self) { color in
                Button {
                    if color == colors[score] {
                        score += 1
                    }

                    if score >= totalRounds {
                        phase = .result
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color)
                        .frame(height: 50)
                }
            }
        }
    }

    var resultView: some View {
        VStack(spacing: 20) {

            Text("Color Memory %")
                .font(.headline)

            Text("\(calculatePercentage())%")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.orange)

            Button("Play Again") {
                startGame()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

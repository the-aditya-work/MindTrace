//
//  File.swift
//  MindSpan
//
//  Created by Aditya Rai on 29/01/26.
//

//import SwiftUI
//
//struct MindDashboardView: View {
//    var body: some View {
//        VStack(spacing: 16) {
//            Text("Your MindSpan")
//                .font(.title)
//
//            Text("Overall Memory Strength")
//                .foregroundColor(.secondary)
//
//            Text("78%")
//                .font(.system(size: 48, weight: .bold))
//        }
//    }
//}

import SwiftUI

struct MindDashboardView: View {
    // MARK: - Mock metrics (bind to real model later)
    @State private var visualMemory: Int = 72
    @State private var focusMemory: Int = 64
    @State private var associationMemory: Int = 81

    // Computed overall (simple average for now)
    private var overallMindSpan: Int {
        let values = [visualMemory, focusMemory, associationMemory].map(Double.init)
        let avg = values.reduce(0, +) / Double(values.count)
        return Int(round(avg))
    }

    // Animation state
    @State private var animatePulse: Bool = false

    var body: some View {
        ZStack {
            // Gentle gradient background
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.25),
                    Color.purple.opacity(0.20),
                    Color.blue.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    summaryCards
                    overallCard
                    reflection
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            // Soft pulse for overall number
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                animatePulse = true
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 6) {
            Text("Your MindSpan")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
            Text("A calm overview of your memory patterns")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Summary Cards
    private var summaryCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                summaryCard(title: "Visual Memory %", value: visualMemory, color: .mint)
                summaryCard(title: "Focus Memory %", value: focusMemory, color: .cyan)
            }
            HStack(spacing: 12) {
                summaryCard(title: "Association Memory %", value: associationMemory, color: .purple)
            }
        }
    }

    private func summaryCard(title: String, value: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(value)%")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15))
        )
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(color.opacity(0.35))
                .frame(width: 18, height: 18)
                .padding(10)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text("\(value) percent"))
    }

    // MARK: - Overall MindSpan
    private var overallCard: some View {
        VStack(spacing: 12) {
            Text("Overall MindSpan %")
                .font(.headline)
                .foregroundStyle(.primary)

            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.15))
                    )
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)

                VStack(spacing: 8) {
                    Text("\(overallMindSpan)%")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .scaleEffect(animatePulse ? 1.02 : 0.98)
                        .animation(.easeInOut(duration: 1.4), value: animatePulse)
                    Text("A friendly snapshot today")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(26)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
        }
    }

    // MARK: - Reflection
    private var reflection: some View {
        VStack(spacing: 10) {
            Text("Reflection")
                .font(.headline)
            Text("Your mind adapts with attention and rest.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Privacy-first reminder (no comparisons, no ranks)
            Text("This view is private to you. There’s no ranking or comparison—only gentle awareness.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15))
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    MindDashboardView()
}

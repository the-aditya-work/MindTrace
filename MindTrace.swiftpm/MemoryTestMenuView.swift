//
//  File.swift
//  MindSpan
//
//  Created by Aditya Rai on 16/02/26.
//  Capgemini Exceller Game Based Aptitude – matching games from PrepInsta
//

//import SwiftUI
//
//struct MemoryTestMenuView: View {
//
//    var body: some View {
//
//        ZStack {
//            LinearGradient(
//                colors: [
//                    Color.indigo.opacity(0.4),
//                    Color.purple.opacity(0.3),
//                    Color.blue.opacity(0.2)
//                ],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
//
//            ScrollView {
//                VStack(spacing: 24) {
//
//                    Text("Memory Games")
//                        .font(.largeTitle)
//                        .bold()
//
//                    // Capgemini: Deductive-Logical (GeoStudio / Geo-Sudo)
//                    gameCard(
//                        title: "Geo-Sudo Challenge",
//                        description: "Find the missing symbol in a 4×4 grid. One shape per row and column.",
//                        icon: "square.grid.3x3.fill",
//                        destination: AnyView(DeductiveLogicGameView())
//                    )
//
//                    // Capgemini: Switch Challenge
//                    gameCard(
//                        title: "Switch Challenge",
//                        description: "Shapes run through a code. Predict the output order.",
//                        icon: "arrow.triangle.swap",
//                        destination: AnyView(SwitchChallengeView())
//                    )
//
//                    // Capgemini: Digit Challenge
//                    gameCard(
//                        title: "Digit Challenge",
//                        description: "Use limited digits to make LHS = RHS. Each digit once.",
//                        icon: "function",
//                        destination: AnyView(DigitChallengeView())
//                    )
//
//                    // Capgemini: Motion Challenge
//                    gameCard(
//                        title: "Motion Challenge",
//                        description: "Navigate the ball to the hole in fewest moves.",
//                        icon: "circle.hexagonpath.fill",
//                        destination: AnyView(MotionChallengeView())
//                    )
//
//                    // Capgemini: Grid Challenge
////                    gameCard(
////                        title: "Grid Challenge",
////                        description: "Remember highlighted grid positions while checking symmetry.",
////                        icon: "square.grid.2x2.fill",
////                        destination: AnyView(GridChallengeView())
////                    )
//
//                    // Capgemini: Inductive Logic (Spacio)
//                    gameCard(
//                        title: "Inductive Logic",
//                        description: "Find figures that do not follow the given rule.",
//                        icon: "brain.head.profile",
//                        destination: AnyView(InductiveLogicView())
//                    )
//
//                    // Capgemini: Same Rule Challenge
//                    gameCard(
//                        title: "Same Rule",
//                        description: "Mark images that fit the same rules as the example.",
//                        icon: "checkmark.circle.fill",
//                        destination: AnyView(SameRuleView())
//                    )
//
//                    // Capgemini: Colour the Grid
//                    gameCard(
//                        title: "Colour the Grid",
//                        description: "Learn rules from 6 tables, then color 4 tables accordingly.",
//                        icon: "paintpalette.fill",
//                        destination: AnyView(ColourTheGridView())
//                    )
//
//                    // Existing: Sequence Recall (memory)
//                    gameCard(
//                        title: "Sequence Recall",
//                        description: "Remember a sequence of visual elements with distraction.",
//                        icon: "rectangle.stack.fill",
//                        destination: AnyView(ActualMemoryTestView())
//                    )
//                }
//                .padding()
//            }
//        }
//    }
//
//    func gameCard(title: String,
//                  description: String,
//                  icon: String,
//                  destination: AnyView) -> some View {
//
//        NavigationLink(destination: destination) {
//
//            VStack(alignment: .leading, spacing: 10) {
//
//                HStack {
//                    Image(systemName: icon)
//                        .font(.title2)
//                        .foregroundColor(.orange)
//                    Spacer()
//                }
//
//                Text(title)
//                    .font(.headline)
//
//                Text(description)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            .padding()
//            .background(.ultraThinMaterial)
//            .cornerRadius(24)
//            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 6)
//        }
//        .buttonStyle(.plain)
//    }
//}

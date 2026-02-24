import SwiftUI

struct DSAGamificationView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient to match app style
                LinearGradient(
                    colors: [
                        Color.indigo.opacity(0.35),
                        Color.purple.opacity(0.25),
                        Color.blue.opacity(0.20)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        header

                        // Graph Algorithms
                        sectionHeader("Graph Algorithms")
                        gameCard(
                            title: "Build the MST",
                            subtitle: "Pick edges to form a minimum spanning tree.",
                            icon: "link",
                            tag: "Kruskal + DSU",
                            destination: AnyView(MSTBuilderView())
                        )
                        gameCard(
                            title: "BFS vs DFS Explorer",
                            subtitle: "Find a path in a maze and compare algorithms.",
                            icon: "arrow.triangle.merge",
                            tag: "Traversal",
                            destination: AnyView(BFSPathGameView())
                        )

                        // Future sections (placeholders for expansion)
                        sectionHeader("Advanced Data Structures")
                        placeholderCard(title: "Trie Word Hunt", subtitle: "Prefix search with a playful twist.")
                        placeholderCard(title: "Segment Tree Rush", subtitle: "Answer range-sum queries fast.")

                        sectionHeader("Design Paradigms & Theory")
                        placeholderCard(title: "Greedy Scheduler", subtitle: "Pick tasks to maximize reward.")
                        placeholderCard(title: "DP Puzzle", subtitle: "Solve with overlapping subproblems.")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("Algorithm Arcade")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
            Text("Gamified DSA on your Map tab")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(.top, 4)
        .padding(.bottom, -4)
    }

    private func gameCard(title: String, subtitle: String, icon: String, tag: String, destination: AnyView) -> some View {
        NavigationLink(destination: destination) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.orange.opacity(0.25))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(.orange)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                        Spacer()
                        Text(tag)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.35), in: Capsule())
                    }
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15))
            )
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    private func placeholderCard(title: String, subtitle: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(.gray)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Text("Soon")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.25), in: Capsule())
                }
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 5)
        .opacity(0.9)
    }
}

#Preview {
    DSAGamificationView()
}

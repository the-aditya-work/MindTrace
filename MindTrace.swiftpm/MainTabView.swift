//
//  File.swift
//  MindSpan
//
//  Created by Aditya Rai on 29/01/26.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var gameResultManager = GameResultManager.shared
    
    var body: some View {
        TabView {

            MemoryGameView()
                .tabItem {
                    Label("Test", systemImage: "brain.head.profile")
                }

            DSAGamificationView()
                .environmentObject(scoreManager)
                .environmentObject(gameResultManager)
                .tabItem {
                    Label("Map", systemImage: "circle.grid.cross")
                }

            MindDashboardView()
                .environmentObject(gameResultManager)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
        }
    }
}


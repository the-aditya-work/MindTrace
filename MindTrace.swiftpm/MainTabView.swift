//
//  File.swift
//  MindSpan
//
//  Created by Aditya Rai on 29/01/26.
//

//import SwiftUI
//
//struct MainTabView: View {
//
//    var body: some View {
//        TabView {
//
//            MemoryGameView()
//                .tabItem {
//                    Label("Test", systemImage: "brain.head.profile")
//                }
//
//            ColorMemoryArtView()
//                .tabItem {
//                    Label("Color", systemImage: "paintpalette")
//                }
//
//            MentalDeclutterView()
//                .tabItem {
//                    Label("Declutter", systemImage: "sparkles")
//                }
//
//            BrainMapNotesView()
//                .tabItem {
//                    Label("Map", systemImage: "circle.grid.cross")
//                }
//
//            MindDashboardView()
//                .tabItem {
//                    Label("Mind %", systemImage: "chart.bar")
//                }
//        }
//    }
//}

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {

            MemoryGameView()
                .tabItem {
                    Label("Test", systemImage: "brain.head.profile")
                }

            BrainMapNotesView()
                .tabItem {
                    Label("Map", systemImage: "circle.grid.cross")
                }

            MindDashboardView()
                .tabItem {
                    Label("Mind %", systemImage: "chart.bar")
                }
        }
    }
}


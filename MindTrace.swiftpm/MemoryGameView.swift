import SwiftUI

struct MemoryGameView: View {

    var body: some View {
        NavigationStack {
            MemoryTestMenuView()
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}


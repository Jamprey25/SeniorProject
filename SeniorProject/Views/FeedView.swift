import SwiftUI

struct FeedView: View {
    var body: some View {
        NavigationView {
            List {
                Text("Feed Item 1")
                Text("Feed Item 2")
                Text("Feed Item 3")
            }
            .navigationTitle("Feed")
        }
    }
}

#Preview {
    FeedView()
} 
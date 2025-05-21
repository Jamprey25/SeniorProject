import SwiftUI

struct ExploreView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(1...12, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 150)
                            .overlay(
                                Text("Club")
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .padding()
            }
            .navigationTitle("Explore")
        }
    }
}

#Preview {
    ExploreView()
} 

import SwiftUI

struct ExploreView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(MockData.clubs) { club in
                        NavigationLink(destination: Text(club.name)) {
                            VStack(alignment: .leading, spacing: 8) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 100)
                                    .overlay(
                                        Image(club.logo)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .clipped()
                                    )
                                
                                Text(club.name)
                                    .font(.headline)
                                    .lineLimit(1)
                                
                                Text(club.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                
                                HStack {
                                    ForEach(club.tags.prefix(2), id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption2)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
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

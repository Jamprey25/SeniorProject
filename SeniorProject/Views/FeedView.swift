import SwiftUI

struct FeedView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(MockData.announcements) { announcement in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(announcement.title)
                                .font(.headline)
                            if announcement.isPinned {
                                Image(systemName: "pin.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text(announcement.content)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(announcement.creationDate, style: .relative)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                ForEach(Announcement.ReactionType.allCases, id: \.self) { reaction in
                                    Button(action: {
                                        // Handle reaction
                                    }) {
                                        Text(reaction.rawValue)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Feed")
        }
    }
}

#Preview {
    FeedView()
} 
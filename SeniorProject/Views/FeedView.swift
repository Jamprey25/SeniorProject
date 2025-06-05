import SwiftUI

struct FeedView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            List {
                // Featured Clubs Section
                Section(header: Text("Featured Clubs")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.spacingMedium) {
                            ForEach(MockData.clubs.prefix(5)) { club in
                                NavigationLink(destination: ClubDetailView(club: club)) {
                                    VStack {
                                        Circle()
                                            .fill(AppTheme.primary.opacity(0.1))
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                Image(systemName: "person.3.fill")
                                                    .foregroundColor(AppTheme.primary)
                                            )
                                        
                                        Text(club.name)
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textPrimary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .listRowInsets(EdgeInsets())
                }
                
                // Upcoming Events Section
                Section(header: Text("Upcoming Events")) {
                    ForEach(MockData.events.sorted { $0.startTime < $1.startTime }) { event in
                        NavigationLink(destination: ClubDetailView(club: MockData.clubs.first(where: { $0.id == event.clubID }) ?? MockData.clubs[0])) {
                            HStack {
                                Circle()
                                    .fill(AppTheme.primary.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "calendar")
                                            .foregroundColor(AppTheme.primary)
                                    )
                                
                                VStack(alignment: .leading) {
                                    Text(event.name)
                                        .font(.headline)
                                    Text(event.startTime, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                // Recent Announcements Section
                Section(header: Text("Recent Announcements")) {
                    ForEach(MockData.announcements.sorted { $0.creationDate > $1.creationDate }) { announcement in
                        NavigationLink(destination: ClubDetailView(club: MockData.clubs.first(where: { $0.id == announcement.clubID }) ?? MockData.clubs[0])) {
                            HStack {
                                Circle()
                                    .fill(AppTheme.primary.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: announcement.isPinned ? "pin.fill" : "bell.fill")
                                            .foregroundColor(AppTheme.primary)
                                    )
                                
                                VStack(alignment: .leading) {
                                    Text(announcement.title)
                                        .font(.headline)
                                    Text(announcement.content)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Feed")
            .refreshable {
                // TODO: Implement refresh functionality
            }
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(AuthenticationViewModel())
} 
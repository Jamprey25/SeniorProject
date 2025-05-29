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
                
                // Recent Activity Section
                Section(header: Text("Recent Activity")) {
                    ForEach(1...5, id: \.self) { _ in
                        HStack {
                            Circle()
                                .fill(AppTheme.primary.opacity(0.1))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(AppTheme.primary)
                                )
                            
                            VStack(alignment: .leading) {
                                Text("Club Announcement")
                                    .font(.headline)
                                Text("New event scheduled for next week")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
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
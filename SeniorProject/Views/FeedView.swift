import SwiftUI

struct FeedView: View {
    @State private var isRefreshing = false
    @State private var announcements = MockData.announcements
    @State private var selectedReaction: Announcement.ReactionType?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: AppTheme.spacingMedium) {
                    ForEach(announcements) { announcement in
                        AnnouncementCard(
                            announcement: announcement,
                            selectedReaction: $selectedReaction
                        )
                        .padding(.horizontal, AppTheme.spacingMedium)
                    }
                }
                .padding(.vertical, AppTheme.spacingMedium)
            }
            .refreshable {
                // Simulate refresh
                isRefreshing = true
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                isRefreshing = false
            }
            .background(AppTheme.background)
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.large)
        }
        .id("FeedView") // Add a stable ID to maintain state
    }
}

// Announcement Card
struct AnnouncementCard: View {
    let announcement: Announcement
    @Binding var selectedReaction: Announcement.ReactionType?
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
            // Header
            HStack(alignment: .top) {
                // Club Icon
                Circle()
                    .fill(AppTheme.primary.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.3.fill")
                            .foregroundColor(AppTheme.primary)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    // Title and Pin
                    HStack {
                        Text(announcement.title)
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        if announcement.isPinned {
                            Image(systemName: "pin.fill")
                                .foregroundColor(AppTheme.primary)
                                .font(.system(size: 14))
                        }
                    }
                    
                    // Time
                    Text(announcement.creationDate, style: .relative)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                // Expand/Collapse Button
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppTheme.textSecondary)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            
            // Content
            Text(announcement.content)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(isExpanded ? nil : 2)
                .padding(.top, 4)
            
            // Reactions
            HStack(spacing: AppTheme.spacingMedium) {
                ForEach(Announcement.ReactionType.allCases, id: \.self) { reaction in
                    ReactionButton(
                        reaction: reaction,
                        isSelected: selectedReaction == reaction,
                        count: announcement.reactions.filter { $0.value == reaction }.count
                    ) {
                        withAnimation(.spring()) {
                            if selectedReaction == reaction {
                                selectedReaction = nil
                            } else {
                                selectedReaction = reaction
                            }
                        }
                    }
                }
            }
            .padding(.top, AppTheme.spacingSmall)
        }
        .padding(AppTheme.spacingMedium)
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .shadow(
            color: AppTheme.shadowSmall.color,
            radius: AppTheme.shadowSmall.radius,
            x: AppTheme.shadowSmall.x,
            y: AppTheme.shadowSmall.y
        )
    }
}

// Reaction Button
struct ReactionButton: View {
    let reaction: Announcement.ReactionType
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(reaction.rawValue)
                    .font(.system(size: 16))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                isSelected ?
                AppTheme.primary.opacity(0.2) :
                AppTheme.background
            )
            .cornerRadius(AppTheme.cornerRadiusSmall)
        }
    }
}

#Preview {
    FeedView()
} 
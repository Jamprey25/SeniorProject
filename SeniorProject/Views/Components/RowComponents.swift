import SwiftUI

struct MemberRow: View {
    let member: User
    
    var body: some View {
        HStack(spacing: AppTheme.spacingMedium) {
            Circle()
                .fill(AppTheme.primary.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(AppTheme.primary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(member.username)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(member.role.rawValue.capitalized)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
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

struct AnnouncementRow: View {
    let announcement: Announcement
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
            HStack {
                Text(announcement.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                if announcement.isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundColor(AppTheme.primary)
                }
            }
            
            Text(announcement.content)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
            
            HStack {
                Text(announcement.creationDate, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                // Reaction counts
                ForEach(announcement.getReactionCounts().sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { reaction, count in
                    if count > 0 {
                        Text("\(reaction.rawValue) \(count)")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
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
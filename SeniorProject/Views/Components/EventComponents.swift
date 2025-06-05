import SwiftUI

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
            Text(event.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(AppTheme.primary)
                Text(event.startTime, style: .date)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                Image(systemName: "clock")
                    .foregroundColor(AppTheme.primary)
                Text(event.startTime, style: .time)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Text(event.description)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(2)
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(AppTheme.primary)
                Text(event.location)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                Text("\(event.attendeeIDs.count) attending")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.primary)
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
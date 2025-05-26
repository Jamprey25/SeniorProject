import SwiftUI

struct ClubDetailView: View {
    let club: Club
    @State private var selectedTab = 0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLarge) {
                // Header
                VStack(spacing: AppTheme.spacingMedium) {
                    // Club Image
                    ZStack {
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                            .fill(AppTheme.primary.opacity(0.1))
                            .frame(height: 200)
                            .overlay(
                                Image(club.logo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipped()
                            )
                        
                        if club.requiresApplicationToJoin {
                            Text("Application Required")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.secondary)
                                .cornerRadius(AppTheme.cornerRadiusSmall)
                                .padding(12)
                        }
                    }
                    
                    // Club Info
                    VStack(spacing: AppTheme.spacingSmall) {
                        Text(club.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(club.description)
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.spacingMedium)
                        
                        // Tags
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.spacingSmall) {
                                ForEach(club.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppTheme.primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.primary.opacity(0.1))
                                        .cornerRadius(AppTheme.cornerRadiusSmall)
                                }
                            }
                            .padding(.horizontal, AppTheme.spacingMedium)
                        }
                    }
                }
                
                // Quick Info Cards
                HStack(spacing: AppTheme.spacingMedium) {
                    InfoCard(
                        title: "Schedule",
                        value: club.meetingSchedule,
                        icon: "clock.fill"
                    )
                    
                    InfoCard(
                        title: "Location",
                        value: club.meetingLocation,
                        icon: "location.fill"
                    )
                }
                .padding(.horizontal, AppTheme.spacingMedium)
                
                // Segmented Control
                CustomSegmentedControl(
                    selectedTab: $selectedTab,
                    tabs: ["About", "Members", "Events"]
                )
                .padding(.horizontal, AppTheme.spacingMedium)
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    // About Tab
                    VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                        InfoRow(title: "Category", value: club.category.rawValue)
                        InfoRow(title: "Founded", value: "2024")
                        InfoRow(title: "Members", value: "\(club.memberIDs.count)")
                       
                    }
                    .padding(AppTheme.spacingMedium)
                    .tag(0)
                    
                    // Members Tab
                    VStack(spacing: AppTheme.spacingMedium) {
                        ForEach(0..<5) { _ in
                            MemberRow()
                        }
                    }
                    .padding(AppTheme.spacingMedium)
                    .tag(1)
                    
                    // Events Tab
                    VStack(spacing: AppTheme.spacingMedium) {
                        ForEach(0..<3) { _ in
                            EventRow()
                        }
                    }
                    .padding(AppTheme.spacingMedium)
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .padding(.vertical, AppTheme.spacingMedium)
        }
        .background(AppTheme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Handle join/leave club
                }) {
                    Text(club.requiresApplicationToJoin ? "Apply" : "Join")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, AppTheme.spacingMedium)
                        .padding(.vertical, AppTheme.spacingSmall)
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                }
            }
        }
    }
}

// Info Card
struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: AppTheme.spacingSmall) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppTheme.primary)
            
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
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

// Info Row
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}

// Member Row
struct MemberRow: View {
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
                Text("John Doe")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("President")
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

// Event Row
struct EventRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
            Text("Club Meeting")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(AppTheme.primary)
                Text("March 15, 2024")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                Image(systemName: "clock")
                    .foregroundColor(AppTheme.primary)
                Text("3:00 PM")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
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

#Preview {
    NavigationView {
        ClubDetailView(club: MockData.clubs[0])
    }
} 
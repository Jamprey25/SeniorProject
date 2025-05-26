import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.spacingLarge) {
                    // Profile Header
                    ProfileHeader()
                    
                    // Stats Section
                    StatsSection()
                    
                    // Settings Section
                    SettingsSection()
                }
                .padding(AppTheme.spacingMedium)
            }
            .background(AppTheme.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .id("ProfileView") // Add a stable ID to maintain state
    }
}

// Profile Header
struct ProfileHeader: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            // Profile Picture
            ZStack {
                Circle()
                    .fill(AppTheme.primaryGradient)
                    .frame(width: 100, height: 100)
                    .shadow(
                        color: AppTheme.primary.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                Text(String(authViewModel.username.prefix(1)).uppercased())
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // User Info
            VStack(spacing: 4) {
                Text(authViewModel.username.isEmpty ? "Username" : authViewModel.username)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(authViewModel.user?.email ?? "")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            // Edit Profile Button
            Button(action: {
                // Handle edit profile
            }) {
                Text("Edit Profile")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, AppTheme.spacingLarge)
                    .padding(.vertical, AppTheme.spacingSmall)
                    .background(AppTheme.primary.opacity(0.1))
                    .cornerRadius(AppTheme.cornerRadiusMedium)
            }
        }
        .padding(AppTheme.spacingLarge)
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadiusLarge)
        .shadow(
            color: AppTheme.shadowMedium.color,
            radius: AppTheme.shadowMedium.radius,
            x: AppTheme.shadowMedium.x,
            y: AppTheme.shadowMedium.y
        )
        .padding(.horizontal, AppTheme.spacingMedium)
    }
}

// Stats Section
struct StatsSection: View {
    var body: some View {
        HStack(spacing: AppTheme.spacingMedium) {
            StatCard(title: "Clubs", value: "5", icon: "person.3.fill")
            StatCard(title: "Events", value: "12", icon: "calendar")
            StatCard(title: "Posts", value: "8", icon: "square.text.square.fill")
        }
        .padding(.horizontal, AppTheme.spacingMedium)
    }
}

// Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: AppTheme.spacingSmall) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppTheme.primary)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(title)
                .font(.system(size: 14))
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

// Settings Section
struct SettingsSection: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            SettingsButton(title: "Notifications", icon: "bell.fill", color: AppTheme.primary)
            SettingsButton(title: "Privacy", icon: "lock.fill", color: AppTheme.secondary)
            SettingsButton(title: "Help & Support", icon: "questionmark.circle.fill", color: AppTheme.accent)
            
            // Sign Out Button
            Button(action: {
                authViewModel.signOut()
            }) {
                HStack {
                    Image(systemName: "arrow.right.square.fill")
                        .font(.system(size: 20))
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.secondary)
                .cornerRadius(AppTheme.cornerRadiusMedium)
            }
        }
        .padding(AppTheme.spacingMedium)
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadiusLarge)
        .shadow(
            color: AppTheme.shadowMedium.color,
            radius: AppTheme.shadowMedium.radius,
            x: AppTheme.shadowMedium.x,
            y: AppTheme.shadowMedium.y
        )
        .padding(.horizontal, AppTheme.spacingMedium)
    }
}

// Settings Button
struct SettingsButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Handle settings action
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationViewModel())
} 

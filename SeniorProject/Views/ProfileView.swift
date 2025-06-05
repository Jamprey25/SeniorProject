import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showingSignOutAlert = false
    @State private var isEditingProfile = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingLarge) {
                    // Profile Header
                    profileHeader
                    
                    // Stats Section
                    statsSection
                    
                    // Content Tabs
                    VStack(spacing: AppTheme.spacingMedium) {
                        // Custom Tab Bar
                        HStack(spacing: 0) {
                            ForEach(["About", "Activity", "Settings"], id: \.self) { tab in
                                TabButton(
                                    title: tab,
                                    isSelected: selectedTab == ["About", "Activity", "Settings"].firstIndex(of: tab)
                                ) {
                                    withAnimation {
                                        selectedTab = ["About", "Activity", "Settings"].firstIndex(of: tab) ?? 0
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.spacingMedium)
                        
                        // Tab Content
                        TabView(selection: $selectedTab) {
                            aboutSection
                                .tag(0)
                            
                            activitySection
                                .tag(1)
                            
                            settingsSection
                                .tag(2)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                }
                .padding(.bottom, AppTheme.spacingLarge)
            }
            .background(AppTheme.background)
            .navigationTitle("Profile")
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(AppTheme.primaryGradient)
                    .frame(width: 120, height: 120)
                    .shadow(
                        color: AppTheme.primary.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            // User Info
            VStack(spacing: 4) {
                Text(authViewModel.currentUser?.username ?? "")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(authViewModel.currentUser?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            // Edit Profile Button
            Button {
                isEditingProfile = true
            } label: {
                Label("Edit Profile", systemImage: "pencil")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, AppTheme.spacingMedium)
                    .padding(.vertical, AppTheme.spacingSmall)
                    .background(AppTheme.primary.opacity(0.1))
                    .cornerRadius(AppTheme.cornerRadiusMedium)
            }
        }
        .padding(.top, AppTheme.spacingLarge)
    }
    
    private var statsSection: some View {
        HStack(spacing: AppTheme.spacingMedium) {
            StatCard(
                title: "Clubs",
                value: "\(authViewModel.currentUser?.joinedClubIDs.count ?? 0)",
                icon: "person.3.fill"
            )
            
            StatCard(
                title: "Events",
                value: "12",
                icon: "calendar"
            )
            
            StatCard(
                title: "Posts",
                value: "24",
                icon: "square.text.square.fill"
            )
        }
        .padding(.horizontal, AppTheme.spacingMedium)
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
            InfoCard(
                title: "Role",
                value: authViewModel.currentUser?.role.rawValue.capitalized ?? "",
                icon: "person.badge.shield.checkmark.fill"
            )
            
            if let grade = authViewModel.currentUser?.grade {
                InfoCard(
                    title: "Grade",
                    value: "\(grade)",
                    icon: "graduationcap.fill"
                )
            }
            
            if let bio = authViewModel.currentUser?.bio, !bio.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                    Text("Bio")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(bio)
                        .font(.body)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(AppTheme.spacingMedium)
                .frame(maxWidth: .infinity, alignment: .leading)
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
        .padding(.horizontal, AppTheme.spacingMedium)
    }
    
    private var activitySection: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            ForEach(MockData.events.prefix(3)) { event in
                EventCard(event: event)
            }
        }
        .padding(.horizontal, AppTheme.spacingMedium)
    }
    
    private var settingsSection: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            Button(role: .destructive) {
                showingSignOutAlert = true
            } label: {
                HStack {
                    Image(systemName: "arrow.right.square")
                        .font(.system(size: 20))
                    Text("Sign Out")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .foregroundColor(AppTheme.secondary)
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
        .padding(.horizontal, AppTheme.spacingMedium)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationViewModel())
} 

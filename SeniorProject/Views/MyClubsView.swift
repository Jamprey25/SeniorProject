import SwiftUI

struct MyClubsView: View {
    @State private var selectedTab = 0
    @State private var joinedClubs: [Club] = []
    @State private var pendingClubs: [Club] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    private let clubService = ClubService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Segmented Control
                CustomSegmentedControl(
                    selectedTab: $selectedTab,
                    tabs: ["Joined", "Pending"]
                )
                .padding(.horizontal, AppTheme.spacingMedium)
                .padding(.top, AppTheme.spacingMedium)
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    // Joined Clubs
                    ScrollView {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if joinedClubs.isEmpty {
                            Text("You haven't joined any clubs yet")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            LazyVStack(spacing: AppTheme.spacingMedium) {
                                ForEach(joinedClubs) { club in
                                    NavigationLink(destination: ClubDetailView(club: club, onMembershipChanged: {
                                        Task {
                                            await loadUserClubs()
                                        }
                                    })) {
                                        JoinedClubCard(club: club)
                                    }
                                }
                            }
                            .padding(AppTheme.spacingMedium)
                        }
                    }
                    .tag(0)
                    .refreshable {
                        await loadUserClubs()
                    }
                    
                    // Pending Requests
                    ScrollView {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if pendingClubs.isEmpty {
                            Text("No pending requests")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            LazyVStack(spacing: AppTheme.spacingMedium) {
                                ForEach(pendingClubs) { club in
                                    PendingClubCard(club: club)
                                }
                            }
                            .padding(AppTheme.spacingMedium)
                        }
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(AppTheme.background)
            .navigationTitle("My Clubs")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await loadUserClubs()
        }
    }
    
    private func loadUserClubs() async {
        guard let currentUser = authViewModel.user else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let joinedClubIds = try await clubService.getUserClubs(userId: currentUser.uid)
            var loadedClubs: [Club] = []
            
            for clubId in joinedClubIds {
                if let club = try await clubService.getClub(clubId: clubId) {
                    loadedClubs.append(club)
                }
            }
            
            await MainActor.run {
                self.joinedClubs = loadedClubs
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

struct CustomSegmentedControl: View {
    @Binding var selectedTab: Int
    let tabs: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                tabButton(for: index)
            }
        }
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .shadow(
            color: AppTheme.shadowSmall.color,
            radius: AppTheme.shadowSmall.radius,
            x: AppTheme.shadowSmall.x,
            y: AppTheme.shadowSmall.y
        )
    }
    
    private func tabButton(for index: Int) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = index
            }
        }) {
            Text(tabs[index])
                .font(.system(size: 16, weight: selectedTab == index ? .semibold : .regular))
                .foregroundColor(selectedTab == index ? .white : AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacingSmall)
                .background(
                    selectedTab == index ?
                    AnyView(AppTheme.primaryGradient) :
                    AnyView(Color.clear)
                )
        }
    }
}

// Joined Club Card
struct JoinedClubCard: View {
    let club: Club
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: ClubDetailView(club: club)) {
            HStack(spacing: AppTheme.spacingMedium) {
                // Club Icon
                Circle()
                    .fill(AppTheme.primary.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(club.logo)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(club.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(club.meetingSchedule)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(club.meetingLocation)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.textSecondary)
                    .font(.system(size: 14, weight: .semibold))
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
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: { })
    }
}

// Pending Club Card
struct PendingClubCard: View {
    let club: Club
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: AppTheme.spacingMedium) {
            // Club Icon
            Circle()
                .fill(AppTheme.secondary.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.3.fill")
                        .foregroundColor(AppTheme.secondary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(club.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Request pending approval")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.secondary)
            }
            
            Spacer()
            
            Button(action: {
                // Handle cancel request
            }) {
                Text("Cancel")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.secondary)
                    .padding(.horizontal, AppTheme.spacingMedium)
                    .padding(.vertical, AppTheme.spacingSmall)
                    .background(AppTheme.secondary.opacity(0.1))
                    .cornerRadius(AppTheme.cornerRadiusSmall)
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: { })
    }
}

#Preview {
    MyClubsView()
} 

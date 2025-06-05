import SwiftUI

struct ClubDetailView: View {
    let club: Club
    @StateObject private var viewModel = ClubDetailViewModel()
    @State private var selectedTab = 0
    @State private var isJoining = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isMember = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    private let clubService = ClubService()
    var onMembershipChanged: (() -> Void)?
    
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
                    ClubInfoCard(
                        title: "Schedule",
                        value: club.meetingSchedule,
                        icon: "clock.fill"
                    )
                    
                    ClubInfoCard(
                        title: "Location",
                        value: club.meetingLocation,
                        icon: "location.fill"
                    )
                }
                .padding(.horizontal, AppTheme.spacingMedium)
                
                // Segmented Control
                CustomSegmentedControl(
                    selectedTab: $selectedTab,
                    tabs: ["About", "Members", "Events", "Announcements"]
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
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewModel.members.isEmpty {
                            Text("No members yet")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ForEach(viewModel.members) { member in
                                MemberRow(member: member)
                            }
                        }
                    }
                    .padding(AppTheme.spacingMedium)
                    .tag(1)
                    
                    // Events Tab
                    VStack(spacing: AppTheme.spacingMedium) {
                        let clubEvents = MockData.events.filter { $0.clubID == club.id }
                        if clubEvents.isEmpty {
                            Text("No upcoming events")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ForEach(clubEvents.sorted { $0.startTime < $1.startTime }) { event in
                                EventCard(event: event)
                            }
                        }
                    }
                    .padding(AppTheme.spacingMedium)
                    .tag(2)
                    
                    // Announcements Tab
                    VStack(spacing: AppTheme.spacingMedium) {
                        let clubAnnouncements = MockData.announcements.filter { $0.clubID == club.id }
                        if clubAnnouncements.isEmpty {
                            Text("No announcements yet")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ForEach(clubAnnouncements.sorted { $0.creationDate > $1.creationDate }) { announcement in
                                AnnouncementRow(announcement: announcement)
                            }
                        }
                    }
                    .padding(AppTheme.spacingMedium)
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .padding(.vertical, AppTheme.spacingMedium)
        }
        .background(AppTheme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isMember {
                    Button(action: {
                        Task {
                            await handleLeaveClub()
                        }
                    }) {
                        Text("Leave")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, AppTheme.spacingMedium)
                            .padding(.vertical, AppTheme.spacingSmall)
                            .background(AppTheme.secondary)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }
                } else {
                    Button(action: {
                        Task {
                            await handleJoinClub()
                        }
                    }) {
                        if isJoining {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(club.requiresApplicationToJoin ? "Apply" : "Join")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, AppTheme.spacingMedium)
                                .padding(.vertical, AppTheme.spacingSmall)
                                .background(AppTheme.primaryGradient)
                                .cornerRadius(AppTheme.cornerRadiusMedium)
                        }
                    }
                    .disabled(isJoining)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .task {
            await viewModel.loadMembers(for: club.id.uuidString)
            await checkMembershipStatus()
        }
    }
    
    private func checkMembershipStatus() async {
        guard let currentUser = authViewModel.user else { return }
        
        do {
            isMember = try await clubService.isUserMemberOfClub(userId: currentUser.uid, clubId: club.id.uuidString)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func handleJoinClub() async {
        guard let currentUser = authViewModel.user else { return }
        
        isJoining = true
        defer { isJoining = false }
        
        do {
            if club.requiresApplicationToJoin {
                // TODO: Implement application process
                errorMessage = "Application process not implemented yet"
                showError = true
            } else {
                try await clubService.joinClub(userId: currentUser.uid, clubId: club.id.uuidString)
                isMember = true
                // Reload members after joining
                await viewModel.loadMembers(for: club.id.uuidString)
                // Notify parent views about membership change
                onMembershipChanged?()
                // Dismiss the view to return to the previous screen
                await MainActor.run {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func handleLeaveClub() async {
        guard let currentUser = authViewModel.user else { return }
        
        isJoining = true
        defer { isJoining = false }
        
        do {
            try await clubService.leaveClub(userId: currentUser.uid, clubId: club.id.uuidString)
            isMember = false
            // Reload members after leaving
            await viewModel.loadMembers(for: club.id.uuidString)
            // Notify parent views about membership change
            onMembershipChanged?()
            // Dismiss the view to return to the previous screen
            await MainActor.run {
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    NavigationView {
        ClubDetailView(club: MockData.clubs[0])
    }
} 
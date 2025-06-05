import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var viewModel = AdminDashboardViewModel()
    @State private var showingClubRequestDetail: AdminClubRequest?
    @State private var showingClubHeadApplicationDetail: AdminClubHeadApplication?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Tab Bar
                HStack(spacing: 0) {
                    ForEach([AdminDashboardViewModel.AdminTab.pendingRequests,
                            .history,
                            .schoolOverview,
                            .settings], id: \.self) { tab in
                        AdminTabButton(title: tabTitle(for: tab),
                                isSelected: viewModel.selectedTab == tab) {
                            viewModel.selectedTab = tab
                        }
                    }
                }
                .padding(.horizontal)
                .background(Color(.systemBackground))
                
                // Tab Content
                TabView(selection: $viewModel.selectedTab) {
                    PendingRequestsView(
                        viewModel: viewModel,
                        showingClubRequestDetail: $showingClubRequestDetail,
                        showingClubHeadApplicationDetail: $showingClubHeadApplicationDetail
                    )
                    .tag(AdminDashboardViewModel.AdminTab.pendingRequests)
                    
                    HistoryView(viewModel: viewModel)
                        .tag(AdminDashboardViewModel.AdminTab.history)
                    
                    SchoolOverviewView(viewModel: viewModel)
                        .tag(AdminDashboardViewModel.AdminTab.schoolOverview)
                    
                    AdminSettingsView(viewModel: viewModel)
                        .tag(AdminDashboardViewModel.AdminTab.settings)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Admin Dashboard")
            .sheet(item: $showingClubRequestDetail) { request in
                ClubRequestDetailView(request: request, viewModel: viewModel)
            }
            .sheet(item: $showingClubHeadApplicationDetail) { application in
                ClubHeadApplicationDetailView(application: application, viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.loadPendingRequests()
        }
    }
    
    private func tabTitle(for tab: AdminDashboardViewModel.AdminTab) -> String {
        switch tab {
        case .pendingRequests: return "Pending"
        case .history: return "History"
        case .schoolOverview: return "Overview"
        case .settings: return "Settings"
        }
    }
}

struct AdminTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .primary : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Rectangle()
                        .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                )
        }
    }
}

struct PendingRequestsView: View {
    @ObservedObject var viewModel: AdminDashboardViewModel
    @Binding var showingClubRequestDetail: AdminClubRequest?
    @Binding var showingClubHeadApplicationDetail: AdminClubHeadApplication?
    @State private var showingApprovalAlert = false
    @State private var showingRejectionAlert = false
    @State private var selectedRequest: AdminClubRequest?
    @State private var adminComment: String = ""
    @State private var processingRequestId: UUID?
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                LazyVStack(spacing: 16) {
                    // Club Requests Section
                    Section(header: SectionHeader(title: "New Club Requests")) {
                        if viewModel.pendingClubRequests.isEmpty {
                            EmptyStateView(message: "No pending club requests")
                        } else {
                            ForEach(viewModel.pendingClubRequests) { request in
                                ClubRequestCard(
                                    request: request,
                                    onApprove: {
                                        print("Approve button tapped for request: \(request.id)")
                                        selectedRequest = request
                                        showingApprovalAlert = true
                                    },
                                    onReject: {
                                        print("Reject button tapped for request: \(request.id)")
                                        selectedRequest = request
                                        showingRejectionAlert = true
                                    },
                                    onViewDetails: { showingClubRequestDetail = request }
                                )
                                .environment(\.isProcessing, processingRequestId == request.id)
                                .transition(.opacity.combined(with: .move(edge: .trailing)))
                            }
                        }
                    }
                    
                    // Club Head Applications Section
                    Section(header: SectionHeader(title: "Club Head Applications")) {
                        if viewModel.pendingClubHeadApplications.isEmpty {
                            EmptyStateView(message: "No pending club head applications")
                        } else {
                            ForEach(viewModel.pendingClubHeadApplications) { application in
                                ClubHeadApplicationCard(
                                    application: application,
                                    onApprove: {
                                        Task {
                                            await viewModel.approveClubHeadApplication(id: application.id, adminComment: "")
                                        }
                                    },
                                    onReject: {
                                        Task {
                                            await viewModel.rejectClubHeadApplication(id: application.id, adminComment: "")
                                        }
                                    },
                                    onViewDetails: { showingClubHeadApplicationDetail = application }
                                )
                            }
                        }
                    }
                }
                .padding()
                .animation(.spring(), value: viewModel.pendingClubRequests)
            }
        }
        .refreshable {
            await viewModel.loadPendingRequests()
        }
        .alert("Approve Club Request", isPresented: $showingApprovalAlert) {
            TextField("Admin Comment (Optional)", text: $adminComment)
            Button("Cancel", role: .cancel) {
                adminComment = ""
                selectedRequest = nil
            }
            Button("Approve") {
                if let request = selectedRequest {
                    print("Approving request: \(request.id)")
                    processingRequestId = request.id
                    Task {
                        await viewModel.approveClubRequest(id: request.id, adminComment: adminComment)
                        print("Approval completed for request: \(request.id)")
                        adminComment = ""
                        selectedRequest = nil
                        processingRequestId = nil
                    }
                }
            }
        } message: {
            Text("Are you sure you want to approve this club request?")
        }
        .alert("Reject Club Request", isPresented: $showingRejectionAlert) {
            TextField("Admin Comment (Required)", text: $adminComment)
            Button("Cancel", role: .cancel) {
                adminComment = ""
                selectedRequest = nil
            }
            Button("Reject", role: .destructive) {
                if let request = selectedRequest {
                    print("Rejecting request: \(request.id)")
                    processingRequestId = request.id
                    Task {
                        await viewModel.rejectClubRequest(id: request.id, adminComment: adminComment)
                        print("Rejection completed for request: \(request.id)")
                        adminComment = ""
                        selectedRequest = nil
                        processingRequestId = nil
                    }
                }
            }
        } message: {
            Text("Please provide a reason for rejecting this club request.")
        }
        .onChange(of: viewModel.pendingClubRequests) { newValue in
            print("Pending requests updated. Count: \(newValue.count)")
        }
    }
}

private struct IsProcessingKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isProcessing: Bool {
        get { self[IsProcessingKey.self] }
        set { self[IsProcessingKey.self] = newValue }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
    }
}

struct EmptyStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct HistoryView: View {
    @ObservedObject var viewModel: AdminDashboardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLarge) {
                // Recent Activity Section
                Section(header: SectionHeader(title: "Recent Activity")) {
                    VStack(spacing: AppTheme.spacingMedium) {
                        ForEach(1...5, id: \.self) { _ in
                            ActivityCard(
                                title: "Club Request Processed",
                                description: "Coding Club request was approved",
                                date: Date(),
                                type: .approval
                            )
                        }
                    }
                }
                
                // Analytics Section
                Section(header: SectionHeader(title: "Analytics")) {
                    VStack(spacing: AppTheme.spacingMedium) {
                        AnalyticsCard(
                            title: "Total Clubs",
                            value: "24",
                            trend: "+3",
                            trendDirection: .up
                        )
                        
                        AnalyticsCard(
                            title: "Active Members",
                            value: "450",
                            trend: "+12%",
                            trendDirection: .up
                        )
                        
                        AnalyticsCard(
                            title: "Pending Requests",
                            value: "5",
                            trend: "-2",
                            trendDirection: .down
                        )
                    }
                }
            }
            .padding()
        }
    }
}

struct SchoolOverviewView: View {
    @ObservedObject var viewModel: AdminDashboardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLarge) {
                // School Stats
                Section(header: SectionHeader(title: "School Statistics")) {
                    VStack(spacing: AppTheme.spacingMedium) {
                        StatCard(
                            title: "Total Students",
                            value: "1,200",
                            icon: "person.3.fill"
                        )
                        
                        StatCard(
                            title: "Active Clubs",
                            value: "24",
                            icon: "star.fill"
                        )
                        
                        StatCard(
                            title: "Club Categories",
                            value: "8",
                            icon: "tag.fill"
                        )
                    }
                }
                
                // Popular Clubs
                Section(header: SectionHeader(title: "Popular Clubs")) {
                    VStack(spacing: AppTheme.spacingMedium) {
                        ForEach(1...3, id: \.self) { _ in
                            PopularClubCard(
                                name: "Coding Club",
                                members: 45,
                                category: "STEM"
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct AdminSettingsView: View {
    @ObservedObject var viewModel: AdminDashboardViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showingSignOutAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLarge) {
                // Account Settings
                Section(header: SectionHeader(title: "Account Settings")) {
                    VStack(spacing: AppTheme.spacingMedium) {
                        SettingsCard(
                            title: "Profile",
                            icon: "person.fill",
                            action: {}
                        )
                        
                        SettingsCard(
                            title: "Notifications",
                            icon: "bell.fill",
                            action: {}
                        )
                        
                        SettingsCard(
                            title: "Privacy",
                            icon: "lock.fill",
                            action: {}
                        )
                    }
                }
                
                // Admin Controls
                Section(header: SectionHeader(title: "Admin Controls")) {
                    VStack(spacing: AppTheme.spacingMedium) {
                        SettingsCard(
                            title: "Manage School Settings",
                            icon: "gear",
                            action: {}
                        )
                        
                        SettingsCard(
                            title: "User Management",
                            icon: "person.2.fill",
                            action: {}
                        )
                        
                        Button(role: .destructive) {
                            showingSignOutAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                Text("Sign Out")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                        }
                    }
                }
            }
            .padding()
        }
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

struct ActivityCard: View {
    let title: String
    let description: String
    let date: Date
    let type: ActivityType
    
    enum ActivityType {
        case approval
        case rejection
        case creation
    }
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .font(.title2)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(date, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
    
    private var iconName: String {
        switch type {
        case .approval: return "checkmark.circle.fill"
        case .rejection: return "xmark.circle.fill"
        case .creation: return "plus.circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch type {
        case .approval: return .green
        case .rejection: return .red
        case .creation: return .blue
        }
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let trend: String
    let trendDirection: TrendDirection
    
    enum TrendDirection {
        case up
        case down
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(trend)
                    .font(.subheadline)
                    .foregroundColor(trendDirection == .up ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
}

struct PopularClubCard: View {
    let name: String
    let members: Int
    let category: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text("\(members) members")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(category)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.primary.opacity(0.1))
                .foregroundColor(AppTheme.primary)
                .cornerRadius(AppTheme.cornerRadiusSmall)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
}

struct SettingsCard: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(AppTheme.primary)
                    .frame(width: 40)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
    }
}

#Preview {
    AdminDashboardView()
        .environmentObject(AuthenticationViewModel())
} 
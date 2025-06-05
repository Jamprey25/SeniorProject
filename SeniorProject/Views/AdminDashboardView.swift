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
                    
                    Text("History & Analytics")
                        .tag(AdminDashboardViewModel.AdminTab.history)
                    
                    Text("School Overview")
                        .tag(AdminDashboardViewModel.AdminTab.schoolOverview)
                    
                    Text("Settings")
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
                                    onApprove: { viewModel.approveClubRequest(id: request.id, adminComment: "") },
                                    onReject: { viewModel.rejectClubRequest(id: request.id, adminComment: "") },
                                    onViewDetails: { showingClubRequestDetail = request }
                                )
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
                                    onApprove: { viewModel.approveClubHeadApplication(id: application.id, adminComment: "") },
                                    onReject: { viewModel.rejectClubHeadApplication(id: application.id, adminComment: "") },
                                    onViewDetails: { showingClubHeadApplicationDetail = application }
                                )
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .refreshable {
            viewModel.loadPendingRequests()
        }
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

#Preview {
    AdminDashboardView()
        .environmentObject(AuthenticationViewModel())
} 
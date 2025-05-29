import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                TabView {
                    NavigationStack {
                        FeedView()
                    }
                    .tabItem {
                        Label("Feed", systemImage: "newspaper")
                    }
                    
                    NavigationStack {
                        ExploreView()
                    }
                    .tabItem {
                        Label("Explore", systemImage: "magnifyingglass")
                    }
                    
                    NavigationStack {
                        MyClubsView()
                    }
                    .tabItem {
                        Label("My Clubs", systemImage: "star.fill")
                    }
                    
                    if authViewModel.currentUser?.role == .clubHead {
                        NavigationStack {
                            ClubManagementView()
                        }
                        .tabItem {
                            Label("Manage", systemImage: "gear")
                        }
                    }
                    
                    if authViewModel.currentUser?.role == .administrator {
                        NavigationStack {
                            AdminDashboardView()
                        }
                        .tabItem {
                            Label("Admin", systemImage: "shield.fill")
                        }
                    }
                    
                    NavigationStack {
                        ProfileView()
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                }
                .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

#Preview {
    RootView()
} 

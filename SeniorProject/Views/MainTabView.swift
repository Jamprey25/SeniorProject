//
//  ContentView.swift
//  SeniorProject
//
//  Created by Joseph Amprey on 5/20/25.
//


import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var isFABExpanded = false
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "newspaper")
                }
                .tag(0)
            
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            MyClubsView()
                .tabItem {
                    Label("My Clubs", systemImage: "person.3")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(3)
        }
        .overlay(alignment: .bottom) {
            // Floating Action Button
            FloatingActionButton(isExpanded: $isFABExpanded)
                .padding(.bottom, 80) // Space for tab bar
        }
    }
}

// Floating Action Button
struct FloatingActionButton: View {
    @Binding var isExpanded: Bool
    
    var body: some View {
        ZStack {
            // Expanded Menu
            if isExpanded {
                VStack(spacing: AppTheme.spacingMedium) {
                    FABMenuItem(
                        title: "Create Club",
                        icon: "plus.circle.fill",
                        color: AppTheme.primary
                    )
                    
                    FABMenuItem(
                        title: "Join Club",
                        icon: "person.badge.plus.fill",
                        color: AppTheme.secondary
                    )
                    
                    FABMenuItem(
                        title: "Share",
                        icon: "square.and.arrow.up.fill",
                        color: AppTheme.accent
                    )
                }
                .padding(.bottom, AppTheme.spacingLarge)
                .transition(.scale.combined(with: .opacity))
            }
            
            // Main FAB Button
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: isExpanded ? "xmark" : "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(AppTheme.primaryGradient)
                    .clipShape(Circle())
                    .shadow(
                        color: AppTheme.primary.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            }
        }
    }
}

// FAB Menu Item
struct FABMenuItem: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
        }
        .padding(.horizontal, AppTheme.spacingLarge)
        .padding(.vertical, AppTheme.spacingMedium)
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .shadow(
            color: AppTheme.shadowSmall.color,
            radius: AppTheme.shadowSmall.radius,
            x: AppTheme.shadowSmall.x,
            y: AppTheme.shadowSmall.y
        )
        .padding(.horizontal, AppTheme.spacingLarge)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationViewModel())
}

//
//  ContentView.swift
//  SeniorProject
//
//  Created by Joseph Amprey on 5/20/25.
//


import SwiftUI
let mainColor = Color(.purple)
struct MainTabView: View {
    var body: some View {
        TabView {
            FeedView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(mainColor)
                .ignoresSafeArea()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Feed")
                }
            
            ExploreView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(mainColor)
                .ignoresSafeArea()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Explore")
                }
            
            MyClubsView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(mainColor)
                .ignoresSafeArea()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("My Clubs")
                }
            
            ProfileView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(mainColor)
                .ignoresSafeArea()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
        .tint(.black)
      
        
    }
}
    
    #Preview {
    MainTabView()
        .environmentObject(AuthenticationViewModel())
}

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
            Text("Feed")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(mainColor)
                .ignoresSafeArea()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Feed")
                }
            
            Text("Explore")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(mainColor)
                .ignoresSafeArea()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Explore")
                }
            
            Text("My Clubs")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(mainColor)
                .ignoresSafeArea()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("My Clubs")
                }
            
            Text("Profile")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(mainColor)
                .ignoresSafeArea()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
        .tint(.black)
        .foregroundStyle(.white)
        
    }
}
    
    #Preview {
    MainTabView()
}

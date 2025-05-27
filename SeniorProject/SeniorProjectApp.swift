//
//  SeniorProjectApp.swift
//  SeniorProject
//
//  Created by Joseph Amprey on 5/20/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct SeniorProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    if authViewModel.needsEmailVerification {
                        EmailVerificationView()
                            .environmentObject(authViewModel)
                    } else {
                        MainTabView()
                            .environmentObject(authViewModel)
                    }
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
            .onChange(of: authViewModel.isAuthenticated) { newValue in
                print("Auth state changed: isAuthenticated = \(newValue)")
                print("Current user: \(String(describing: authViewModel.user))")
                print("Email verified: \(authViewModel.isEmailVerified)")
                print("Needs verification: \(authViewModel.needsEmailVerification)")
            }
            .onChange(of: authViewModel.needsEmailVerification) { newValue in
                print("Email verification state changed: needsVerification = \(newValue)")
            }
            .id(authViewModel.isAuthenticated)
        }
    }
}

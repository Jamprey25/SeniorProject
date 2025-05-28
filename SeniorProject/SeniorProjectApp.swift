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
                            .transition(.opacity)
                    } else {
                        MainTabView()
                            .environmentObject(authViewModel)
                            .transition(.opacity)
                    }
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                        .transition(.opacity)
                }
            }
            .id("App_\(authViewModel.isAuthenticated)_\(authViewModel.needsEmailVerification)_\(authViewModel.user?.email ?? "nil")")
            .animation(.easeInOut, value: authViewModel.isAuthenticated)
            .animation(.easeInOut, value: authViewModel.needsEmailVerification)
            .onChange(of: authViewModel.isAuthenticated) { oldValue, newValue in
                print("App - Auth state changed: \(oldValue) -> \(newValue)")
                print("Current user: \(String(describing: authViewModel.user))")
                print("Email verified: \(authViewModel.isEmailVerified)")
                print("Needs verification: \(authViewModel.needsEmailVerification)")
            }
            .onChange(of: authViewModel.needsEmailVerification) { oldValue, newValue in
                print("App - Email verification state changed: \(oldValue) -> \(newValue)")
            }
            .onChange(of: authViewModel.user) { oldValue, newValue in
                print("App - User data changed: \(String(describing: oldValue?.email)) -> \(String(describing: newValue?.email))")
            }
        }
    }
}

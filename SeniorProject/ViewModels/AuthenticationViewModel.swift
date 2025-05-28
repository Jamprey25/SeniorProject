import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isEmailVerified = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var username: String = ""
    @Published var needsEmailVerification = false
    
    private var handle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in
                print("Auth state changed - User: \(String(describing: firebaseUser?.uid))")
                print("Email verified: \(firebaseUser?.isEmailVerified ?? false)")
                
                self?.isAuthenticated = firebaseUser != nil
                
                if let firebaseUser = firebaseUser {
                    // NEW: Reload user to get fresh verification status
                    try? await firebaseUser.reload()
                    self?.isEmailVerified = firebaseUser.isEmailVerified
                    self?.needsEmailVerification = !firebaseUser.isEmailVerified
                    
                    // Always fetch user data when we have a valid user
                    if firebaseUser.isEmailVerified {
                        await self?.fetchUserData(userId: firebaseUser.uid)
                    }
                } else {
                    self?.resetAuthState()
                }
                self?.logAuthState()
            }
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // NEW: Debug logging helper
    private func logAuthState() {
        print("""
        Auth State Update:
        - isAuthenticated: \(isAuthenticated)
        - isEmailVerified: \(isEmailVerified)
        - needsVerification: \(needsEmailVerification)
        - currentUser: \(user?.email ?? "nil")
        """)
    }
    
    // NEW: Reset auth state helper
    private func resetAuthState() {
        user = nil
        isEmailVerified = false
        needsEmailVerification = false
        username = ""
        objectWillChange.send()
    }
    
    private func fetchUserData(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if let data = document.data() {
                let user = User(
                    id: UUID(uuidString: data["id"] as? String ?? "") ?? UUID(),
                    username: data["username"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    role: User.userRole(rawValue: data["role"] as? String ?? "") ?? .student,
                    joinedClubIDs: (data["joinedClubIDs"] as? [String] ?? []).compactMap { UUID(uuidString: $0) },
                    bio: data["bio"] as? String ?? "",
                    grade: data["grade"] as? Int
                )
                await MainActor.run {
                    self.user = user
                    self.username = user.username
                    self.objectWillChange.send()
                }
            } else {
                // If no user document exists, create one
                print("No user document found, creating one...")
                let newUser = User(
                    id: UUID(uuidString: userId) ?? UUID(),
                    username: username,
                    email: auth.currentUser?.email ?? "",
                    role: .student
                )
                try await db.collection("users").document(userId).setData([
                    "id": newUser.id.uuidString,
                    "username": newUser.username,
                    "email": newUser.email,
                    "role": newUser.role.rawValue,
                    "joinedClubIDs": [],
                    "bio": "",
                    "grade": nil
                ])
                await MainActor.run {
                    self.user = newUser
                    self.objectWillChange.send()
                }
            }
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }
    
    func signUp(email: String, password: String, username: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let authResult = try await auth.createUser(withEmail: email, password: password)
            try await authResult.user.sendEmailVerification()
            
            self.isAuthenticated = true
            self.isEmailVerified = false
            self.needsEmailVerification = true
            self.username = username
            self.user = User(
                id: UUID(uuidString: authResult.user.uid) ?? UUID(),
                username: username,
                email: email,
                role: .student
            )
            self.objectWillChange.send()
            
        } catch {
            errorMessage = error.localizedDescription
            resetAuthState()
            self.objectWillChange.send()
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        print("Starting sign in process...")
        isLoading = true
        errorMessage = nil
        
        do {
            print("Attempting to sign in with Firebase...")
            let authResult = try await auth.signIn(withEmail: email, password: password)
            print("Firebase sign in successful, reloading user...")
            try await authResult.user.reload()  // Critical refresh
            
            print("Checking email verification status...")
            print("User ID: \(authResult.user.uid)")
            print("Email: \(authResult.user.email ?? "nil")")
            print("Email verified: \(authResult.user.isEmailVerified)")
            
            guard authResult.user.isEmailVerified else {
                print("Email not verified, signing out...")
                try await auth.signOut()
                await MainActor.run {
                    isAuthenticated = false
                    needsEmailVerification = true
                    errorMessage = "Please verify your email before signing in"
                    objectWillChange.send()
                }
                return
            }
            
            print("Email verified, fetching user data...")
            await fetchUserData(userId: authResult.user.uid)
            
            print("Setting authentication state...")
            await MainActor.run {
                isAuthenticated = true
                isEmailVerified = true
                needsEmailVerification = false
                print("Auth state updated - User: \(String(describing: self.user?.email))")
                print("Final auth state - isAuthenticated: \(isAuthenticated), isEmailVerified: \(isEmailVerified), needsVerification: \(needsEmailVerification)")
                objectWillChange.send()
            }
            
        } catch {
            print("Error during sign in: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = error.localizedDescription
                resetAuthState()
                objectWillChange.send()
            }
        }
        
        isLoading = false
        print("Sign in process completed")
    }
    
    func signOut() {
        do {
            try auth.signOut()
            resetAuthState()
        } catch {
            errorMessage = "Failed to sign out"
        }
    }
    
    func checkEmailVerification() async {
        guard let user = auth.currentUser else {
            print("No current user found when checking email verification")
            return
        }
        
        do {
            print("Checking email verification for user: \(user.uid)")
            print("Current verification status: \(user.isEmailVerified)")
            
            // Force reload the user to get the latest verification status
            try await user.reload()
            
            // Get fresh verification status
            let isVerified = user.isEmailVerified
            print("Updated verification status: \(isVerified)")
            
            await MainActor.run {
                isEmailVerified = isVerified
                isAuthenticated = isVerified
                needsEmailVerification = !isVerified
                
                print("""
                Email verification check completed:
                - isEmailVerified: \(isEmailVerified)
                - isAuthenticated: \(isAuthenticated)
                - needsEmailVerification: \(needsEmailVerification)
                - currentUser: \(user.email ?? "nil")
                """)
                
                if isVerified {
                    // If email is verified, fetch user data
                    Task {
                        await fetchUserData(userId: user.uid)
                    }
                }
                
                self.objectWillChange.send()
            }
        } catch {
            print("Error checking email verification: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = "Failed to check email verification status"
                self.objectWillChange.send()
            }
        }
    }
    
    func resendVerificationEmail() async {
        guard let user = auth.currentUser else { return }
        
        do {
            try await user.sendEmailVerification()
            errorMessage = "Verification email sent. Please check your inbox."
        } catch {
            errorMessage = "Failed to send verification email"
        }
    }
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await auth.sendPasswordReset(withEmail: email)
            errorMessage = "Password reset email sent. Please check your inbox."
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

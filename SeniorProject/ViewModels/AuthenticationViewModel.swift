import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

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
                print("Auth state changed - User: \(String(describing: firebaseUser))")
                self?.isAuthenticated = firebaseUser != nil
                if let firebaseUser = firebaseUser {
                    self?.isEmailVerified = firebaseUser.isEmailVerified
                    await self?.fetchUserData(userId: firebaseUser.uid)
                } else {
                    self?.user = nil
                    self?.isEmailVerified = false
                    self?.needsEmailVerification = false
                }
                print("isAuthenticated set to: \(self?.isAuthenticated ?? false)")
                self?.objectWillChange.send()
            }
        }
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
                self.user = user
                self.username = user.username
                self.objectWillChange.send()
            }
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, username: String) async {
        print("Starting sign up process...")
        isLoading = true
        errorMessage = nil
        
        do {
            print("Creating Firebase user...")
            // Create Firebase Auth user
            let authResult = try await auth.createUser(withEmail: email, password: password)
            
            // Send verification email
            try await authResult.user.sendEmailVerification()
            
            // Set authentication state
            print("Setting initial authentication state...")
            self.isAuthenticated = true  // Set to true to show EmailVerificationView
            self.isEmailVerified = false
            self.needsEmailVerification = true
            self.username = username
            self.user = User(
                id: UUID(uuidString: authResult.user.uid) ?? UUID(),
                username: username,
                email: email,
                role: .student
            )
            print("Sign up complete. isAuthenticated: \(self.isAuthenticated), needsEmailVerification: \(self.needsEmailVerification)")
            self.objectWillChange.send()
            
        } catch {
            print("Error during sign up: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            // If there's an error, ensure we're not in an authenticated state
            self.isAuthenticated = false
            self.isEmailVerified = false
            self.needsEmailVerification = false
            self.user = nil
            self.objectWillChange.send()
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        print("Starting sign in process...")
        isLoading = true
        errorMessage = nil
        
        do {
            print("Attempting Firebase sign in...")
            // Sign in with Firebase
            let authResult = try await auth.signIn(withEmail: email, password: password)
            
            // Reload user to get latest verification status
            try await authResult.user.reload()
            let isVerified = authResult.user.isEmailVerified
            print("Email verification status: \(isVerified)")
            
            if !isVerified {
                print("Email not verified, signing out...")
                errorMessage = "Please verify your email before signing in"
                self.isAuthenticated = false
                self.needsEmailVerification = true
                try await auth.signOut()
                self.objectWillChange.send()
                return
            }
            
            print("Fetching user data from Firestore...")
            // Fetch user data from Firestore
            let userDoc = try await db.collection("users").document(authResult.user.uid).getDocument()
            
            if let data = userDoc.data() {
                print("User data found in Firestore")
                let user = User(
                    id: UUID(uuidString: data["id"] as? String ?? "") ?? UUID(),
                    username: data["username"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    role: User.userRole(rawValue: data["role"] as? String ?? "") ?? .student,
                    joinedClubIDs: (data["joinedClubIDs"] as? [String] ?? []).compactMap { UUID(uuidString: $0) },
                    bio: data["bio"] as? String ?? "",
                    grade: data["grade"] as? Int
                )
                
                print("Setting user data and authentication state...")
                self.user = user
                self.username = user.username
                self.isAuthenticated = true
                self.isEmailVerified = true
                self.needsEmailVerification = false
                print("Sign in complete. isAuthenticated: \(self.isAuthenticated), needsEmailVerification: \(self.needsEmailVerification)")
                self.objectWillChange.send()
            } else {
                print("User data not found in Firestore, creating new user...")
                // If user data doesn't exist in Firestore, create it
                let newUser = User(
                    id: UUID(uuidString: authResult.user.uid) ?? UUID(),
                    username: self.username,
                    email: authResult.user.email ?? "",
                    role: .student
                )
                
                try await db.collection("users").document(authResult.user.uid).setData([
                    "id": newUser.id.uuidString,
                    "username": newUser.username,
                    "email": newUser.email,
                    "role": newUser.role.rawValue,
                    "joinedClubIDs": newUser.joinedClubIDs.map { $0.uuidString },
                    "bio": newUser.bio,
                    "grade": newUser.grade as Any
                ])
                
                print("Setting new user data and authentication state...")
                self.user = newUser
                self.username = newUser.username
                self.isAuthenticated = true
                self.isEmailVerified = true
                self.needsEmailVerification = false
                print("Sign in complete. isAuthenticated: \(self.isAuthenticated), needsEmailVerification: \(self.needsEmailVerification)")
                self.objectWillChange.send()
            }
            
        } catch {
            print("Error during sign in: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            self.isAuthenticated = false
            self.needsEmailVerification = false
            self.objectWillChange.send()
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try auth.signOut()
            self.isAuthenticated = false
            self.isEmailVerified = false
            self.needsEmailVerification = false
            self.user = nil
            self.username = ""
            self.objectWillChange.send()
        } catch {
            errorMessage = "Failed to sign out"
        }
    }
    
    /// Check if the current user's email is verified
    func checkEmailVerification() async {
        guard let user = auth.currentUser else { return }
        
        do {
            try await user.reload()
            self.isEmailVerified = user.isEmailVerified
            
            if self.isEmailVerified {
                // Create user in Firestore only after email verification
                let newUser = User(
                    id: UUID(uuidString: user.uid) ?? UUID(),
                    username: self.username,
                    email: user.email ?? "",
                    role: .student
                )
                
                try await db.collection("users").document(user.uid).setData([
                    "id": newUser.id.uuidString,
                    "username": newUser.username,
                    "email": newUser.email,
                    "role": newUser.role.rawValue,
                    "joinedClubIDs": newUser.joinedClubIDs.map { $0.uuidString },
                    "bio": newUser.bio,
                    "grade": newUser.grade as Any
                ])
                
                self.isAuthenticated = true
                self.needsEmailVerification = false
                await fetchUserData(userId: user.uid)
                self.objectWillChange.send()
            }
        } catch {
            errorMessage = "Failed to check email verification status"
        }
    }
    
    /// Resend verification email
    func resendVerificationEmail() async {
        guard let user = auth.currentUser else { return }
        
        do {
            try await user.sendEmailVerification()
            errorMessage = "Verification email sent. Please check your inbox."
        } catch {
            errorMessage = "Failed to send verification email"
        }
    }
    
    // MARK: - Password Reset
    
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

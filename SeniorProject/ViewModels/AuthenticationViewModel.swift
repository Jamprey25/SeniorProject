import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthenticationViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var username: String = ""
    @Published var needsEmailVerification = false
    @Published var isLoading = false
    
    private var handle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                print("Auth state changed - User: \(String(describing: user))")
                if let user = user {
                    if !user.isEmailVerified {
                        self?.needsEmailVerification = true
                        self?.isAuthenticated = false
                    } else {
                        self?.needsEmailVerification = false
                        self?.isAuthenticated = true
                        self?.fetchUserData(userId: user.uid)
                    }
                } else {
                    self?.isAuthenticated = false
                    self?.needsEmailVerification = false
                }
                self?.user = user
                print("isAuthenticated set to: \(self?.isAuthenticated ?? false)")
            }
        }
    }
    
    private func fetchUserData(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists,
                   let data = document.data() {
                    let role = User.userRole(rawValue: data["role"] as? String ?? "student") ?? .student
                    self?.username = data["username"] as? String ?? ""
                    print("Fetched username: \(self?.username ?? "none")")
                    
                    // Create user object with role
                    let user = User(
                        id: UUID(uuidString: userId) ?? UUID(),
                        username: self?.username ?? "",
                        email: data["email"] as? String ?? "",
                        schoolID: UUID(uuidString: data["schoolID"] as? String ?? "") ?? UUID(),
                        role: role,
                        joinedClubIDs: [],
                        bio: data["bio"] as? String ?? "",
                        grade: data["grade"] as? Int
                    )
                    
                    // Store user in environment
                    self?.currentUser = user
                } else {
                    print("No user data found")
                }
            }
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signIn(email: String, password: String) async {
        print("Attempting to sign in with email: \(email)")
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            DispatchQueue.main.async {
                print("Sign in successful")
                self.errorMessage = nil
                // Fetch user data after successful sign in
                self.fetchUserData(userId: result.user.uid)
            }
        } catch {
            DispatchQueue.main.async {
                print("Sign in error: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func signUp(email: String, password: String, username: String) async {
        print("Attempting to sign up with email: \(email)")
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Check if this is an admin account
            if email == "admin@clubhub.com" {
                try await RoleManagementService.shared.createAdminAccount(email: email)
            } else {
                // Create regular user with role management
                let user = try await RoleManagementService.shared.createNewUser(
                    username: username,
                    email: email,
                    schoolID: UUID() // TODO: Get actual school ID from school selection
                )
                
                // Store user data in Firestore
                try await db.collection("users").document(result.user.uid).setData([
                    "username": username,
                    "email": email,
                    "role": user.role.rawValue,
                    "joinedClubIDs": [],
                    "bio": "",
                    "createdAt": FieldValue.serverTimestamp()
                ])
            }
            
            // Send verification email
            try await result.user.sendEmailVerification()
            DispatchQueue.main.async {
                print("Verification email sent successfully")
                self.needsEmailVerification = true
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                print("Sign up error: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func resendVerificationEmail() {
        if let user = Auth.auth().currentUser {
            user.sendEmailVerification { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error resending verification email: \(error.localizedDescription)")
                        self?.errorMessage = "Error resending verification email"
                    } else {
                        print("Verification email resent successfully")
                        self?.errorMessage = "Verification email sent. Please check your inbox."
                    }
                }
            }
        }
    }
    
    func checkEmailVerification() {
        if let user = Auth.auth().currentUser {
            user.reload { [weak self] error in
                if let error = error {
                    print("Error reloading user: \(error.localizedDescription)")
                    return
                }
                
                if user.isEmailVerified {
                    // Fetch user data after verification
                    self?.fetchUserData(userId: user.uid)
                    DispatchQueue.main.async {
                        self?.needsEmailVerification = false
                        self?.isAuthenticated = true
                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            // Reset all state
            self.user = nil
            self.currentUser = nil
            self.isAuthenticated = false
            self.needsEmailVerification = false
            self.username = ""
            self.errorMessage = ""
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    // Add currentUser property
    @Published var currentUser: User?
} 
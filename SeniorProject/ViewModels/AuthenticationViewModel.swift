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
                if let document = document, document.exists {
                    self?.username = document.data()?["username"] as? String ?? ""
                    print("Fetched username: \(self?.username ?? "none")")
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
            // Store username in Firestore
            try await db.collection("users").document(result.user.uid).setData([
                "username": username,
                "email": email,
                "joinedClubIDs": [],
                "role": "student",
                "createdAt": FieldValue.serverTimestamp()
            ])
            
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
            print("Sign out successful")
        } catch {
            print("Sign out error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
} 
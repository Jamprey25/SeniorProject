import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthenticationViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var username: String = ""
    
    private var handle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                print("Auth state changed - User: \(String(describing: user))")
                self?.isAuthenticated = user != nil
                self?.user = user
                if let user = user {
                    self?.fetchUserData(userId: user.uid)
                }
                print("isAuthenticated set to: \(self?.isAuthenticated ?? false)")
            }
        }
    }
    
    private func fetchUserData(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                self?.username = document.data()?["username"] as? String ?? ""
            }
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signIn(email: String, password: String) {
        print("Attempting to sign in with email: \(email)")
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Sign in error: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                } else {
                    print("Sign in successful")
                    self?.errorMessage = nil
                }
            }
        }
    }
    
    func signUp(email: String, password: String, username: String) {
        print("Attempting to sign up with email: \(email)")
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Sign up error: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                } else if let user = result?.user {
                    // Store additional user data in Firestore
                    self?.db.collection("users").document(user.uid).setData([
                        "username": username,
                        "email": email
                    ]) { error in
                        if let error = error {
                            print("Error saving user data: \(error.localizedDescription)")
                            self?.errorMessage = "Error saving user data"
                        } else {
                            print("Sign up successful")
                            self?.errorMessage = nil
                        }
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
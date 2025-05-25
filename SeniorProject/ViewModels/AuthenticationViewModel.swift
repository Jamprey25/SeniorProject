import Foundation
import Firebase
import FirebaseAuth

class AuthenticationViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                print("Auth state changed - User: \(String(describing: user))")
                self?.isAuthenticated = user != nil
                self?.user = user
                print("isAuthenticated set to: \(self?.isAuthenticated ?? false)")
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
    
    func signUp(email: String, password: String) {
        print("Attempting to sign up with email: \(email)")
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Sign up error: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                } else {
                    print("Sign up successful")
                    self?.errorMessage = nil
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
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isSignUp = false
    @State private var isAnimating = false
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                NavigationStack {
                    ZStack {
                        // Background gradient
                        AppTheme.backgroundGradient
                            .ignoresSafeArea()
                        
                        if authViewModel.needsEmailVerification {
                            EmailVerificationView()
                        } else {
                            mainContent
                        }
                    }
                    .navigationBarHidden(true)
                    .onChange(of: authViewModel.isAuthenticated) { oldValue, newValue in
                        handleAuthStateChange(oldValue: oldValue, newValue: newValue)
                    }
                    .onChange(of: authViewModel.user) { oldValue, newValue in
                        handleUserChange(oldValue: oldValue, newValue: newValue)
                    }
                }
                .id("LoginView_\(authViewModel.isAuthenticated)_\(authViewModel.needsEmailVerification)_\(authViewModel.user?.email ?? "nil")")
            }
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLarge) {
                // Logo and App Name
                logoSection
                
                // Form Fields
                formFields
                
                // Error Message
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(AppTheme.secondary)
                        .font(.subheadline)
                        .padding(.top, AppTheme.spacingSmall)
                }
                
                // Sign In/Up Button
                signInUpButton
                
                // Toggle Sign In/Up
                toggleSignInUpButton
            }
            .padding(.bottom, AppTheme.spacingLarge)
        }
    }
    
    private var logoSection: some View {
        VStack(spacing: AppTheme.spacingSmall) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.primary)
                .padding(.bottom, AppTheme.spacingSmall)
            
            Text("ClubHub")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(.top, 60)
        .padding(.bottom, 40)
    }
    
    private var formFields: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            if isSignUp {
                CustomTextField(
                    text: $username,
                    placeholder: "Username",
                    systemImage: "person.fill"
                )
            }
            
            CustomTextField(
                text: $email,
                placeholder: "Email",
                systemImage: "envelope.fill"
            )
            
            CustomSecureField(
                text: $password,
                placeholder: "Password",
                systemImage: "lock.fill"
            )
        }
        .padding(.horizontal, AppTheme.spacingLarge)
    }
    
    private var signInUpButton: some View {
        Button {
            Task {
                if isSignUp {
                    await authViewModel.signUp(email: email, password: password, username: username)
                } else {
                    await authViewModel.signIn(email: email, password: password)
                }
            }
        } label: {
            if authViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text(isSignUp ? "Sign Up" : "Sign In")
                    .font(.headline)
            }
        }
        .primaryButtonStyle()
        .disabled(authViewModel.isLoading)
        .padding(.top, AppTheme.spacingMedium)
    }
    
    private var toggleSignInUpButton: some View {
        Button {
            withAnimation(.spring()) {
                isSignUp.toggle()
                if !isSignUp {
                    username = ""
                }
            }
        } label: {
            Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                .foregroundColor(AppTheme.primary)
                .font(.subheadline)
        }
        .padding(.top, AppTheme.spacingMedium)
    }
    
    private func handleAuthStateChange(oldValue: Bool, newValue: Bool) {
        print("LoginView - Auth state changed: \(oldValue) -> \(newValue)")
        if newValue {
            // Clear form fields when successfully authenticated
            email = ""
            password = ""
            username = ""
        }
    }
    
    private func handleUserChange(oldValue: FirebaseAuth.User?, newValue: FirebaseAuth.User?) {
        print("LoginView - User changed: \(String(describing: oldValue?.email)) -> \(String(describing: newValue?.email))")
    }
}

// Custom TextField
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .shadow(
            color: AppTheme.shadowSmall.color,
            radius: AppTheme.shadowSmall.radius,
            x: AppTheme.shadowSmall.x,
            y: AppTheme.shadowSmall.y
        )
    }
}

// Custom SecureField
struct CustomSecureField: View {
    @Binding var text: String
    let placeholder: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 20)
            
            SecureField(placeholder, text: $text)
                .textContentType(.password)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .shadow(
            color: AppTheme.shadowSmall.color,
            radius: AppTheme.shadowSmall.radius,
            x: AppTheme.shadowSmall.x,
            y: AppTheme.shadowSmall.y
        )
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
} 

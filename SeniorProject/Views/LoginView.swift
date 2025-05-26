import SwiftUI

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
                NavigationView {
                    ZStack {
                        // Background gradient
                        AppTheme.backgroundGradient
                            .ignoresSafeArea()
                        
                        ScrollView {
                            VStack(spacing: AppTheme.spacingLarge) {
                                // Logo and App Name
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
                                
                                // Form Fields
                                VStack(spacing: AppTheme.spacingMedium) {
                                    // Username Field (only shown during sign up)
                                    if isSignUp {
                                        CustomTextField(
                                            text: $username,
                                            placeholder: "Username",
                                            systemImage: "person.fill"
                                        )
                                    }
                                    
                                    // Email Field
                                    CustomTextField(
                                        text: $email,
                                        placeholder: "Email",
                                        systemImage: "envelope.fill"
                                    )
                                    
                                    // Password Field
                                    CustomSecureField(
                                        text: $password,
                                        placeholder: "Password",
                                        systemImage: "lock.fill"
                                    )
                                }
                                .padding(.horizontal, AppTheme.spacingLarge)
                                
                                // Error Message
                                if let errorMessage = authViewModel.errorMessage {
                                    Text(errorMessage)
                                        .foregroundColor(AppTheme.secondary)
                                        .font(.subheadline)
                                        .padding(.top, AppTheme.spacingSmall)
                                }
                                
                                // Sign In/Up Button
                                Button(action: {
                                    withAnimation(.spring()) {
                                        if isSignUp {
                                            authViewModel.signUp(email: email, password: password, username: username)
                                        } else {
                                            authViewModel.signIn(email: email, password: password)
                                        }
                                    }
                                }) {
                                    Text(isSignUp ? "Sign Up" : "Sign In")
                                        .font(.headline)
                                }
                                .primaryButtonStyle()
                                .padding(.top, AppTheme.spacingMedium)
                                
                                // Toggle Sign In/Up
                                Button(action: {
                                    withAnimation(.spring()) {
                                        isSignUp.toggle()
                                        if !isSignUp {
                                            username = ""
                                        }
                                    }
                                }) {
                                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                        .foregroundColor(AppTheme.primary)
                                        .font(.subheadline)
                                }
                                .padding(.top, AppTheme.spacingMedium)
                            }
                            .padding(.bottom, AppTheme.spacingLarge)
                        }
                    }
                    .navigationBarHidden(true)
                }
            }
        }
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

import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var isCheckingVerification = false
    
    var body: some View {
        VStack(spacing: AppTheme.spacingLarge) {
            // Header
            VStack(spacing: AppTheme.spacingMedium) {
                Image(systemName: "envelope.badge.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primary)
                
                Text("Verify Your Email")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("We've sent a verification email to your address. Please check your inbox and follow the instructions to verify your account.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.horizontal)
            }
            .padding(.top, 60)
            
            // Buttons
            VStack(spacing: AppTheme.spacingMedium) {
                // Resend Email Button
                Button(action: {
                    authViewModel.resendVerificationEmail()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Resend Verification Email")
                    }
                    .frame(maxWidth: .infinity)
                }
                .primaryButtonStyle()
                
                // Check Verification Button
                Button(action: {
                    isCheckingVerification = true
                    authViewModel.checkEmailVerification()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("I've Verified My Email")
                    }
                    .frame(maxWidth: .infinity)
                }
                .primaryButtonStyle()
                .disabled(isCheckingVerification)
                
                // Sign Out Button
                Button(action: {
                    authViewModel.signOut()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.primary)
            }
            .padding(.horizontal, AppTheme.spacingLarge)
            
            // Error Message
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(AppTheme.secondary)
                    .font(.subheadline)
                    .padding(.top, AppTheme.spacingSmall)
            }
            
            Spacer()
        }
        .padding()
        .background(AppTheme.backgroundGradient)
        .ignoresSafeArea()
    }
}

#Preview {
    EmailVerificationView()
        .environmentObject(AuthenticationViewModel())
} 
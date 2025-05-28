import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var isResending = false
    @State private var isCheckingVerification = false
    
    var body: some View {
        VStack(spacing: AppTheme.spacingLarge) {
            // Header
            VStack(spacing: AppTheme.spacingMedium) {
                Image(systemName: "envelope.badge.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primary)
                
                Text("Verify Your Email")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("We've sent a verification email to:\n\(authViewModel.user?.email ?? "")")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 60)
            
            // Instructions
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("Please:")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                    InstructionRow(number: "1", text: "Check your email inbox")
                    InstructionRow(number: "2", text: "Click the verification link")
                    InstructionRow(number: "3", text: "Return to the app and sign in")
                }
            }
            .padding(.horizontal, AppTheme.spacingLarge)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: AppTheme.spacingMedium) {
                // Resend Email Button
                Button(action: {
                    isResending = true
                    Task {
                        await authViewModel.resendVerificationEmail()
                        isResending = false
                    }
                }) {
                    HStack {
                        if isResending {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text("Resend Verification Email")
                    }
                }
                .primaryButtonStyle()
                .disabled(isResending)
                
                // Check Verification Button
                Button(action: {
                    isCheckingVerification = true
                    Task {
                        await authViewModel.checkEmailVerification()
                        isCheckingVerification = false
                    }
                }) {
                    HStack {
                        if isCheckingVerification {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        Text("I've Verified My Email")
                    }
                }
                .secondaryButtonStyle()
                .disabled(isCheckingVerification)
                
                // Sign Out Button
                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.secondary)
                }
            }
            .padding(.bottom, AppTheme.spacingLarge)
        }
        .padding()
        .background(AppTheme.backgroundGradient)
        .ignoresSafeArea()
        .alert("Verification Status", isPresented: .constant(authViewModel.errorMessage != nil)) {
            Button("OK") {
                authViewModel.errorMessage = nil
            }
        } message: {
            Text(authViewModel.errorMessage ?? "")
        }
        .id(authViewModel.isEmailVerified) // Force view refresh when verification state changes
    }
}

// Instruction Row
struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: AppTheme.spacingMedium) {
            Text(number)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(AppTheme.primary)
                .clipShape(Circle())
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}

#Preview {
    EmailVerificationView()
        .environmentObject(AuthenticationViewModel())
}

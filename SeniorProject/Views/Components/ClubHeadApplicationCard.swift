import SwiftUI

struct ClubHeadApplicationCard: View {
    let application: AdminClubHeadApplication
    let onApprove: () -> Void
    let onReject: () -> Void
    let onViewDetails: () -> Void
    @State private var isPressed = false
    @State private var showActions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(application.applicant.username)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Grade \(application.applicant.grade)")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Text(application.submissionDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            // Application Type
            HStack {
                if let clubName = application.targetClubName {
                    Label("Existing Club: \(clubName)", systemImage: "building.2.fill")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.primary.opacity(0.1))
                        .cornerRadius(AppTheme.cornerRadiusSmall)
                } else {
                    Label("New Club Leadership", systemImage: "star.fill")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(AppTheme.cornerRadiusSmall)
                }
            }
            
            // Application Details
            VStack(alignment: .leading, spacing: 8) {
                Text(application.applicationReason)
                    .font(.body)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                
                HStack {
                    Label("\(application.applicant.currentClubs.count) current clubs", systemImage: "person.3")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Spacer()
                    
                    Text(application.applicant.email)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            // Action Buttons
            if showActions {
                HStack(spacing: AppTheme.spacingMedium) {
                    Button(action: onApprove) {
                        Label("Approve", systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }
                    
                    Button(action: onReject) {
                        Label("Reject", systemImage: "xmark.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(AppTheme.secondary)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .shadow(
            color: AppTheme.shadowMedium.color,
            radius: AppTheme.shadowMedium.radius,
            x: AppTheme.shadowMedium.x,
            y: AppTheme.shadowMedium.y
        )
        .scaleEffect(isPressed ? AppTheme.cardScale : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation(.spring()) {
                isPressed = true
                showActions.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
            AppTheme.hapticFeedback.impactOccurred()
        }
        .onLongPressGesture {
            onViewDetails()
        }
    }
} 
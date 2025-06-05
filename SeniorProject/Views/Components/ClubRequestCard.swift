import SwiftUI

struct ClubRequestCard: View {
    let request: AdminClubRequest
    let onApprove: () -> Void
    let onReject: () -> Void
    let onViewDetails: () -> Void
    @State private var isPressed = false
    @State private var showActions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(request.clubName)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text(request.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.primary.opacity(0.1))
                    .cornerRadius(AppTheme.cornerRadiusSmall)
            }
            
            // Request Info
            VStack(alignment: .leading, spacing: 8) {
                Text("Requested by: \(request.requestedBy.username)")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(request.description)
                    .font(.body)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
            }
            
            // Footer
            HStack {
                Label("\(request.foundingMembers) founding members", systemImage: "person.2")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                Text(request.submissionDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
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
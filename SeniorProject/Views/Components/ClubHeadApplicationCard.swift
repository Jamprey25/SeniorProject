import SwiftUI

struct ClubHeadApplicationCard: View {
    let application: AdminClubHeadApplication
    let onApprove: () -> Void
    let onReject: () -> Void
    let onViewDetails: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(application.applicant.username)
                        .font(.headline)
                    Text("Grade \(application.applicant.grade)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(application.submissionDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let clubName = application.targetClubName {
                Text("Existing Club: \(clubName)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            } else {
                Text("New Club Leadership")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            
            Text(application.applicationReason)
                .font(.body)
                .lineLimit(2)
            
            HStack {
                Label("\(application.applicant.currentClubs.count) current clubs", systemImage: "person.3")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(application.applicant.email)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Button(action: onViewDetails) {
                    Text("View Application")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: onApprove) {
                    Text("Approve")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button(action: onReject) {
                    Text("Reject")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 
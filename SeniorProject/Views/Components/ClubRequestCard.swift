import SwiftUI

struct ClubRequestCard: View {
    let request: AdminClubRequest
    let onApprove: () -> Void
    let onReject: () -> Void
    let onViewDetails: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(request.clubName)
                    .font(.headline)
                Spacer()
                Text(request.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("Requested by: \(request.requestedBy.username) (\(request.requestedBy.email))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(request.description)
                .font(.body)
                .lineLimit(2)
            
            HStack {
                Label("\(request.foundingMembers) founding members", systemImage: "person.2")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(request.submissionDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Button(action: onViewDetails) {
                    Text("View Details")
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
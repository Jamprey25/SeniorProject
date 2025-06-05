import SwiftUI

struct ClubRequestDetailView: View {
    let request: AdminClubRequest
    @ObservedObject var viewModel: AdminDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var adminComment: String = ""
    @State private var showingConfirmation = false
    @State private var action: Action?
    
    enum Action {
        case approve
        case reject
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Club Information
                    Group {
                        Text(request.clubName)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(request.category.rawValue)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(request.description)
                            .font(.body)
                    }
                    
                    Divider()
                    
                    // Applicant Information
                    Group {
                        Text("Applicant Information")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name: \(request.requestedBy.username)")
                            Text("Email: \(request.requestedBy.email)")
                            Text("Grade: \(request.requestedBy.grade)")
                            
                            if !request.requestedBy.currentClubs.isEmpty {
                                Text("Current Clubs:")
                                    .padding(.top, 4)
                                ForEach(request.requestedBy.currentClubs, id: \.self) { club in
                                    Text("• \(club)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Founding Members
                    Group {
                        Text("Founding Members")
                            .font(.headline)
                        
                        Text("\(request.foundingMembers) interested members")
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Admin Comment
                    Group {
                        Text("Admin Comment")
                            .font(.headline)
                        
                        TextEditor(text: $adminComment)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        Button(action: { action = .reject; showingConfirmation = true }) {
                            Text("Reject")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        
                        Button(action: { action = .approve; showingConfirmation = true }) {
                            Text("Approve")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
                .padding()
            }
            .navigationTitle("Club Request Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Confirm Action", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button(action == .approve ? "Approve" : "Reject", role: .destructive) {
                    if let action = action {
                        switch action {
                        case .approve:
                            handleApprove()
                        case .reject:
                            handleReject()
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to \(action == .approve ? "approve" : "reject") this club request?")
            }
        }
    }
    
    private func handleApprove() {
        Task {
            await viewModel.approveClubRequest(id: request.id, adminComment: adminComment)
            dismiss()
        }
    }
    
    private func handleReject() {
        Task {
            await viewModel.rejectClubRequest(id: request.id, adminComment: adminComment)
            dismiss()
        }
    }
} 
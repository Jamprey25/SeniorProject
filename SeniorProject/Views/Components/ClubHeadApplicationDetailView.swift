import SwiftUI

struct ClubHeadApplicationDetailView: View {
    let application: AdminClubHeadApplication
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
                    // Application Type
                    Group {
                        if let clubName = application.targetClubName {
                            Text("Existing Club: \(clubName)")
                                .font(.title2)
                                .fontWeight(.bold)
                        } else {
                            Text("New Club Leadership")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }
                    
                    Divider()
                    
                    // Applicant Information
                    Group {
                        Text("Applicant Information")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name: \(application.applicant.username)")
                            Text("Email: \(application.applicant.email)")
                            Text("Grade: \(application.applicant.grade)")
                            
                            if !application.applicant.currentClubs.isEmpty {
                                Text("Current Clubs:")
                                    .padding(.top, 4)
                                ForEach(application.applicant.currentClubs, id: \.self) { club in
                                    Text("• \(club)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Application Details
                    Group {
                        Text("Application Details")
                            .font(.headline)
                        
                        Text("Application Reason")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(application.applicationReason)
                            .padding(.top, 4)
                        
                        Text("Leadership Experience")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        
                        Text(application.leadershipExperience)
                            .padding(.top, 4)
                        
                        Text("Academic Standing")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        
                        Text(application.academicStanding)
                            .padding(.top, 4)
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
            .navigationTitle("Application Details")
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
                            viewModel.approveClubHeadApplication(id: application.id, adminComment: adminComment)
                        case .reject:
                            viewModel.rejectClubHeadApplication(id: application.id, adminComment: adminComment)
                        }
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to \(action == .approve ? "approve" : "reject") this application?")
            }
        }
    }
} 
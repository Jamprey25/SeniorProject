import Foundation
import SwiftUI

class AdminDashboardViewModel: ObservableObject {
    @Published var selectedTab: AdminTab = .pendingRequests
    @Published var pendingClubRequests: [AdminClubRequest] = []
    @Published var pendingClubHeadApplications: [AdminClubHeadApplication] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    enum AdminTab {
        case pendingRequests
        case history
        case schoolOverview
        case settings
    }
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample club requests
        let sampleUser = AdminClubRequest.User(
            id: UUID(),
            username: "John Doe",
            email: "john.doe@school.edu",
            grade: 11,
            currentClubs: ["Chess Club", "Math Team"]
        )
        
        pendingClubRequests = [
            AdminClubRequest(
                id: UUID(),
                clubName: "Coding Club",
                description: "A club for students interested in programming and software development. We'll learn various programming languages and work on projects.",
                category: .technology,
                requestedBy: sampleUser,
                submissionDate: Date(),
                status: .pending,
                foundingMembers: 15
            ),
            AdminClubRequest(
                id: UUID(),
                clubName: "Environmental Science Club",
                description: "Dedicated to environmental awareness and sustainability projects within our school and community.",
                category: .academic,
                requestedBy: sampleUser,
                submissionDate: Date().addingTimeInterval(-86400),
                status: .pending,
                foundingMembers: 8
            )
        ]
        
        // Sample club head applications
        pendingClubHeadApplications = [
            AdminClubHeadApplication(
                id: UUID(),
                applicant: sampleUser,
                targetClubID: nil,
                targetClubName: nil,
                applicationReason: "I want to start a new coding club to help students learn programming and prepare for future careers in technology.",
                submissionDate: Date(),
                status: .pending,
                leadershipExperience: "Led several group projects in computer science class",
                academicStanding: "3.8 GPA, Advanced Placement Computer Science"
            ),
            AdminClubHeadApplication(
                id: UUID(),
                applicant: sampleUser,
                targetClubID: UUID(),
                targetClubName: "Chess Club",
                applicationReason: "I want to take on a leadership role in the Chess Club to help organize tournaments and mentor new members.",
                submissionDate: Date().addingTimeInterval(-43200),
                status: .pending,
                leadershipExperience: "Vice President of Math Team",
                academicStanding: "3.9 GPA, Advanced Mathematics"
            )
        ]
    }
    
    func loadPendingRequests() {
        isLoading = true
        // TODO: Implement API calls to fetch pending requests
        // This is a placeholder for demonstration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
        }
    }
    
    func approveClubRequest(id: UUID, adminComment: String) {
        // TODO: Implement API call to approve club request
        if let index = pendingClubRequests.firstIndex(where: { $0.id == id }) {
            pendingClubRequests.remove(at: index)
        }
    }
    
    func rejectClubRequest(id: UUID, adminComment: String) {
        // TODO: Implement API call to reject club request
        if let index = pendingClubRequests.firstIndex(where: { $0.id == id }) {
            pendingClubRequests.remove(at: index)
        }
    }
    
    func approveClubHeadApplication(id: UUID, adminComment: String) {
        // TODO: Implement API call to approve club head application
        if let index = pendingClubHeadApplications.firstIndex(where: { $0.id == id }) {
            pendingClubHeadApplications.remove(at: index)
        }
    }
    
    func rejectClubHeadApplication(id: UUID, adminComment: String) {
        // TODO: Implement API call to reject club head application
        if let index = pendingClubHeadApplications.firstIndex(where: { $0.id == id }) {
            pendingClubHeadApplications.remove(at: index)
        }
    }
} 
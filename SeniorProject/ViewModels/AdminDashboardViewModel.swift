import Foundation
import SwiftUI
import FirebaseFirestore

class AdminDashboardViewModel: ObservableObject {
    @Published var selectedTab: AdminTab = .pendingRequests
    @Published var pendingClubRequests: [AdminClubRequest] = []
    @Published var pendingClubHeadApplications: [AdminClubHeadApplication] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
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
        // Sample users
        let johnDoe = AdminClubRequest.User(
            id: UUID(),
            username: "John Doe",
            email: "john.doe@school.edu",
            grade: 11,
            currentClubs: ["Chess Club", "Math Team"]
        )
        
        let sarahSmith = AdminClubRequest.User(
            id: UUID(),
            username: "Sarah Smith",
            email: "sarah.smith@school.edu",
            grade: 12,
            currentClubs: ["Science Olympiad", "Debate Team"]
        )
        
        let michaelChen = AdminClubRequest.User(
            id: UUID(),
            username: "Michael Chen",
            email: "michael.chen@school.edu",
            grade: 10,
            currentClubs: ["Robotics Club"]
        )
        
        let emmaWilson = AdminClubRequest.User(
            id: UUID(),
            username: "Emma Wilson",
            email: "emma.wilson@school.edu",
            grade: 11,
            currentClubs: ["Art Club", "Environmental Club"]
        )
        
        // Sample club requests
        pendingClubRequests = [
            AdminClubRequest(
                id: UUID(),
                clubName: "Coding Club",
                description: "A club for students interested in programming and software development. We'll learn various programming languages, work on projects, and prepare for hackathons. Regular workshops on web development, mobile app creation, and competitive programming.",
                category: .stem,
                requestedBy: johnDoe,
                submissionDate: Date(),
                status: .pending,
                foundingMembers: 15
            ),
            AdminClubRequest(
                id: UUID(),
                clubName: "Environmental Science Club",
                description: "Dedicated to environmental awareness and sustainability projects within our school and community. Activities include recycling initiatives, community clean-ups, and educational workshops on climate change and conservation.",
                category: .academic,
                requestedBy: sarahSmith,
                submissionDate: Date().addingTimeInterval(-86400),
                status: .pending,
                foundingMembers: 8
            ),
            AdminClubRequest(
                id: UUID(),
                clubName: "Asian Cultural Association",
                description: "Celebrating and sharing Asian cultures through food, music, dance, and art. We'll organize cultural festivals, language exchange programs, and community outreach events to promote cultural understanding and appreciation.",
                category: .cultural,
                requestedBy: michaelChen,
                submissionDate: Date().addingTimeInterval(-172800),
                status: .pending,
                foundingMembers: 12
            ),
            AdminClubRequest(
                id: UUID(),
                clubName: "Digital Art Studio",
                description: "A creative space for students to explore digital art, graphic design, and animation. We'll learn industry-standard software, create digital portfolios, and collaborate on multimedia projects.",
                category: .arts,
                requestedBy: emmaWilson,
                submissionDate: Date().addingTimeInterval(-259200),
                status: .pending,
                foundingMembers: 10
            ),
            AdminClubRequest(
                id: UUID(),
                clubName: "Community Service Initiative",
                description: "Organizing volunteer opportunities and service projects for students. We'll partner with local organizations to address community needs through regular service events and fundraising campaigns.",
                category: .service,
                requestedBy: sarahSmith,
                submissionDate: Date().addingTimeInterval(-345600),
                status: .pending,
                foundingMembers: 20
            )
        ]
        
        // Sample club head applications
        pendingClubHeadApplications = [
            AdminClubHeadApplication(
                id: UUID(),
                applicant: johnDoe,
                targetClubID: nil,
                targetClubName: nil,
                applicationReason: "I want to start a new coding club to help students learn programming and prepare for future careers in technology. I have experience leading group projects and mentoring younger students in computer science.",
                submissionDate: Date(),
                status: .pending,
                leadershipExperience: "Led several group projects in computer science class, Organized school hackathon",
                academicStanding: "3.8 GPA, Advanced Placement Computer Science, National Honor Society"
            ),
            AdminClubHeadApplication(
                id: UUID(),
                applicant: sarahSmith,
                targetClubID: UUID(),
                targetClubName: "Science Olympiad",
                applicationReason: "I want to take on a leadership role in the Science Olympiad to help organize competitions and mentor new members. I've been a member for three years and have won several regional competitions.",
                submissionDate: Date().addingTimeInterval(-43200),
                status: .pending,
                leadershipExperience: "Science Olympiad Team Captain, Debate Team Vice President",
                academicStanding: "4.0 GPA, Advanced Placement Biology and Chemistry, Science National Honor Society"
            ),
            AdminClubHeadApplication(
                id: UUID(),
                applicant: michaelChen,
                targetClubID: nil,
                targetClubName: nil,
                applicationReason: "I want to start an Asian Cultural Association to celebrate and share our diverse cultures with the school community. I have experience organizing cultural events in my previous school.",
                submissionDate: Date().addingTimeInterval(-86400),
                status: .pending,
                leadershipExperience: "Organized cultural festival at previous school, Robotics Club Team Lead",
                academicStanding: "3.9 GPA, Advanced Placement World History, National Honor Society"
            ),
            AdminClubHeadApplication(
                id: UUID(),
                applicant: emmaWilson,
                targetClubID: nil,
                targetClubName: nil,
                applicationReason: "I want to start a Digital Art Studio to provide a creative space for students interested in digital media. I have experience with various design software and have won several art competitions.",
                submissionDate: Date().addingTimeInterval(-129600),
                status: .pending,
                leadershipExperience: "Art Club Secretary, Organized school art exhibition",
                academicStanding: "3.7 GPA, Advanced Placement Studio Art, Art Honor Society"
            )
        ]
    }
    
    func loadPendingRequests() {
        isLoading = true
        
        Task {
            do {
                // Load club requests
                let requestsSnapshot = try await db.collection("clubRequests")
                    .whereField("status", isEqualTo: "pending")
                    .getDocuments()
                
                var loadedRequests: [AdminClubRequest] = []
                for document in requestsSnapshot.documents {
                    let data = document.data()
                    if let request = try? AdminClubRequest(
                        id: UUID(uuidString: document.documentID) ?? UUID(),
                        clubName: data["clubName"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        category: Club.ClubCategory(rawValue: data["category"] as? String ?? "") ?? .other,
                        requestedBy: AdminClubRequest.User(
                            id: UUID(uuidString: (data["requestedBy"] as? [String: Any])?["id"] as? String ?? "") ?? UUID(),
                            username: (data["requestedBy"] as? [String: Any])?["username"] as? String ?? "",
                            email: (data["requestedBy"] as? [String: Any])?["email"] as? String ?? "",
                            grade: 0,
                            currentClubs: []
                        ),
                        submissionDate: (data["submissionDate"] as? Timestamp)?.dateValue() ?? Date(),
                        status: .pending,
                        foundingMembers: data["foundingMembers"] as? Int ?? 1
                    ) {
                        loadedRequests.append(request)
                    }
                }
                
                await MainActor.run {
                    self.pendingClubRequests = loadedRequests
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func approveClubRequest(id: UUID, adminComment: String) {
        Task {
            do {
                // Get the request
                let requestDoc = try await db.collection("clubRequests")
                    .document(id.uuidString)
                    .getDocument()
                
                guard let requestData = requestDoc.data() else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request not found"])
                }
                
                // Create the club
                let clubID = UUID()
                let clubData: [String: Any] = [
                    "name": requestData["clubName"] as? String ?? "",
                    "description": requestData["description"] as? String ?? "",
                    "category": requestData["category"] as? String ?? "",
                    "tags": requestData["tags"] as? [String] ?? [],
                    "schoolID": UUID().uuidString, // TODO: Get from school settings
                    "creationDate": FieldValue.serverTimestamp(),
                    "meetingSchedule": requestData["meetingSchedule"] as? String ?? "",
                    "meetingLocation": requestData["meetingLocation"] as? String ?? "",
                    "logo": "default_club_logo",
                    "memberIDs": [(requestData["requestedBy"] as? [String: Any])?["id"] as? String ?? ""],
                    "leadershipRoles": [[
                        "userID": (requestData["requestedBy"] as? [String: Any])?["id"] as? String ?? "",
                        "role": "Founder",
                        "permissions": [
                            "permissions": [
                                "manageClub",
                                "manageMembership",
                                "postAnnouncements",
                                "editClubInfo",
                                "assignRoles"
                            ]
                        ]
                    ]],
                    "isApproved": true,
                    "requiresApplicationToJoin": requestData["requiresApplicationToJoin"] as? Bool ?? false
                ]
                
                // Create the club document
                try await db.collection("clubs").document(clubID.uuidString).setData(clubData)
                
                // Update the request status
                try await requestDoc.reference.updateData([
                    "status": "approved",
                    "adminComment": adminComment,
                    "approvedAt": FieldValue.serverTimestamp(),
                    "clubID": clubID.uuidString
                ])
                
                // Refresh the list
                await MainActor.run {
                    loadPendingRequests()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func rejectClubRequest(id: UUID, adminComment: String) {
        Task {
            do {
                try await db.collection("clubRequests").document(id.uuidString).updateData([
                    "status": "rejected",
                    "adminComment": adminComment,
                    "rejectedAt": FieldValue.serverTimestamp()
                ])
                
                await MainActor.run {
                    loadPendingRequests()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
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
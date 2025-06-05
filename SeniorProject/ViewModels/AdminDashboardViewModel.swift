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
    private var isUsingSampleData = true // Flag to track if we're using sample data
    
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
                firestoreID: "sample_1",
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
                firestoreID: "sample_2",
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
                firestoreID: "sample_3",
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
                firestoreID: "sample_4",
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
                firestoreID: "sample_5",
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
                    print("Loading request with document ID: \(document.documentID)")
                    if let request = try? AdminClubRequest(
                        id: UUID(uuidString: document.documentID) ?? UUID(),
                        firestoreID: document.documentID,  // Store the Firestore document ID
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
                        print("Successfully loaded request with ID: \(request.id) and Firestore ID: \(request.firestoreID)")
                    }
                }
                
                await MainActor.run {
                    if !loadedRequests.isEmpty {
                        print("Successfully loaded \(loadedRequests.count) requests from Firestore")
                        self.pendingClubRequests = loadedRequests
                        self.isUsingSampleData = false
                    } else {
                        print("No requests found in Firestore, using sample data")
                        self.isUsingSampleData = true
                        self.loadSampleData()
                    }
                    self.isLoading = false
                }
            } catch {
                print("Error loading requests from Firestore: \(error.localizedDescription)")
                await MainActor.run {
                    print("Falling back to sample data due to error")
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    self.isUsingSampleData = true
                    self.loadSampleData()
                }
            }
        }
    }
    
    func approveClubRequest(id: UUID, adminComment: String) async {
        print("Starting approval process for request: \(id)")
        do {
            if isUsingSampleData {
                print("Using sample data for approval")
                // Handle sample data
                await MainActor.run {
                    if let index = pendingClubRequests.firstIndex(where: { $0.id == id }) {
                        print("Removing request at index: \(index)")
                        pendingClubRequests.remove(at: index)
                        print("Remaining requests: \(pendingClubRequests.count)")
                    }
                    selectedTab = .schoolOverview
                }
                return
            }
            
            print("Using Firestore data for approval")
            // Find the request in our local array to get the Firestore ID
            guard let request = pendingClubRequests.first(where: { $0.id == id }) else {
                print("Request not found in local array")
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request not found"])
            }
            
            print("Found request with Firestore ID: \(request.firestoreID)")
            // Get the request from Firestore using the correct document ID
            let requestDoc = try await db.collection("clubRequests")
                .document(request.firestoreID)
                .getDocument()
            
            guard let requestData = requestDoc.data() else {
                print("Request not found in Firestore")
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request not found"])
            }
            
            print("Creating new club")
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
                "requiresApplicationToJoin": requestData["requiresApplicationToJoin"] as? Bool ?? false,
                "isActive": true,
                "isVisible": true
            ]
            
            print("Saving club to Firestore")
            // Create the club document
            try await db.collection("clubs").document(clubID.uuidString).setData(clubData)
            
            print("Updating request status")
            // Update the request status using the correct document ID
            try await requestDoc.reference.updateData([
                "status": "approved",
                "adminComment": adminComment,
                "approvedAt": FieldValue.serverTimestamp(),
                "clubID": clubID.uuidString
            ])
            
            print("Updating UI state")
            // Update UI state on the main thread
            await MainActor.run {
                // Remove the request from the list
                if let index = pendingClubRequests.firstIndex(where: { $0.id == id }) {
                    print("Removing request at index: \(index)")
                    pendingClubRequests.remove(at: index)
                    print("Remaining requests: \(pendingClubRequests.count)")
                }
                
                // Switch to explore tab
                selectedTab = .schoolOverview
            }
            print("Approval process completed successfully")
        } catch {
            print("Error during approval process: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func rejectClubRequest(id: UUID, adminComment: String) async {
        print("Starting rejection process for request: \(id)")
        print("Current data source: \(isUsingSampleData ? "Sample Data" : "Firestore")")
        
        do {
            if isUsingSampleData {
                print("Using sample data for rejection")
                // Handle sample data
                await MainActor.run {
                    if let index = pendingClubRequests.firstIndex(where: { $0.id == id }) {
                        print("Removing request at index: \(index)")
                        pendingClubRequests.remove(at: index)
                        print("Remaining requests: \(pendingClubRequests.count)")
                    } else {
                        print("Request not found in sample data array")
                    }
                }
                return
            }
            
            print("Using Firestore data for rejection")
            print("Attempting to reject request with ID: \(id.uuidString)")
            
            // First check if the document exists
            let requestDoc = try await db.collection("clubRequests")
                .document(id.uuidString)
                .getDocument()
            
            guard requestDoc.exists else {
                print("Request document does not exist in Firestore")
                // If we can't find it in Firestore but we're not using sample data,
                // something is wrong with our data source tracking
                if let request = pendingClubRequests.first(where: { $0.id == id }) {
                    print("Found request in local array but not in Firestore - switching to sample data mode")
                    await MainActor.run {
                        self.isUsingSampleData = true
                        if let index = pendingClubRequests.firstIndex(where: { $0.id == id }) {
                            pendingClubRequests.remove(at: index)
                        }
                    }
                    return
                }
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request not found in database"])
            }
            
            print("Found request document in Firestore, proceeding with rejection")
            // Update the request status in Firestore
            try await requestDoc.reference.updateData([
                "status": "rejected",
                "adminComment": adminComment,
                "reviewedAt": FieldValue.serverTimestamp()
            ])
            
            print("Updating UI state")
            // Update UI state on the main thread
            await MainActor.run {
                // Remove the request from the list
                if let index = pendingClubRequests.firstIndex(where: { $0.id == id }) {
                    print("Removing request at index: \(index)")
                    pendingClubRequests.remove(at: index)
                    print("Remaining requests: \(pendingClubRequests.count)")
                }
            }
            print("Rejection process completed successfully")
        } catch {
            print("Error during rejection process: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func approveClubHeadApplication(id: UUID, adminComment: String) {
        // TODO: Implement API call to approve club head application
        if let index = pendingClubHeadApplications.firstIndex(where: { $0.id == id }) {
            pendingClubHeadApplications.remove(at: index)
        }
    }
    
    func rejectClubHeadApplication(id: UUID, adminComment: String) async {
        do {
            if isUsingSampleData {
                // Handle sample data
                await MainActor.run {
                    if let index = pendingClubHeadApplications.firstIndex(where: { $0.id == id }) {
                        pendingClubHeadApplications.remove(at: index)
                    }
                }
                return
            }
            
            // Update the application status in Firestore
            try await db.collection("clubHeadApplications")
                .document(id.uuidString)
                .updateData([
                    "status": "rejected",
                    "adminComment": adminComment,
                    "reviewedAt": FieldValue.serverTimestamp()
                ])
            
            // Remove from local array immediately
            await MainActor.run {
                if let index = pendingClubHeadApplications.firstIndex(where: { $0.id == id }) {
                    pendingClubHeadApplications.remove(at: index)
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
} 
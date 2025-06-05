import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class CreateClubViewModel: ObservableObject {
    @Published var name = ""
    @Published var shortDescription = ""
    @Published var detailedDescription = ""
    @Published var category: Club.ClubCategory = .academic
    @Published var tags: [String] = []
    @Published var meetingSchedule = ""
    @Published var meetingLocation = ""
    @Published var contactEmail = ""
    @Published var requiresApplicationToJoin = false
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var showingSuccessAlert = false
    
    private let db = Firestore.firestore()
    private let clubService = ClubService()
    
    var isValid: Bool {
        !name.isEmpty &&
        !shortDescription.isEmpty &&
        !detailedDescription.isEmpty &&
        !meetingSchedule.isEmpty &&
        !meetingLocation.isEmpty &&
        !contactEmail.isEmpty &&
        contactEmail.contains("@")
    }
    
    func submitClub() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Create a club request
        let request = [
            "clubName": name,
            "description": detailedDescription,
            "category": category.rawValue,
            "tags": tags,
            "meetingSchedule": meetingSchedule,
            "meetingLocation": meetingLocation,
            "contactEmail": contactEmail,
            "requiresApplicationToJoin": requiresApplicationToJoin,
            "requestedBy": [
                "id": currentUser.uid,
                "email": currentUser.email ?? "",
                "username": currentUser.displayName ?? "Anonymous"
            ],
            "submissionDate": FieldValue.serverTimestamp(),
            "status": "pending",
            "foundingMembers": 1 // Start with the creator
        ] as [String: Any]
        
        // Add the request to Firestore
        try await db.collection("clubRequests").addDocument(data: request)
        
        // Show success message
        showingSuccessAlert = true
    }
} 
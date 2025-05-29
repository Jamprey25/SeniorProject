import Foundation
import FirebaseFirestore


class ClubService: ObservableObject {
    private let db = Firestore.firestore()
    
    // Add a user to a club
    func joinClub(userId: String, clubId: String) async throws {
        let userRef = db.collection("users").document(userId)
        let clubRef = db.collection("clubs").document(clubId)
        
        // Check if user document exists
        let userDoc = try await userRef.getDocument()
        if !userDoc.exists {
            // Create user document with empty joinedClubIDs array
            try await userRef.setData([
                "joinedClubIDs": []
            ])
        }
        
        // Check if club document exists
        let clubDoc = try await clubRef.getDocument()
        if !clubDoc.exists {
            // Create club document with empty memberIDs array
            try await clubRef.setData([
                "memberIDs": []
            ])
        }
        
        // Start a batch write
        let batch = db.batch()
        
        // Add club to user's joined clubs
        batch.updateData([
            "joinedClubIDs": FieldValue.arrayUnion([clubId])
        ], forDocument: userRef)
        
        // Add user to club's members
        batch.updateData([
            "memberIDs": FieldValue.arrayUnion([userId])
        ], forDocument: clubRef)
        
        // Commit the batch
        try await batch.commit()
    }
    
    // Remove a user from a club
    func leaveClub(userId: String, clubId: String) async throws {
        let userRef = db.collection("users").document(userId)
        let clubRef = db.collection("clubs").document(clubId)
        
        // Check if both documents exist
        let userDoc = try await userRef.getDocument()
        let clubDoc = try await clubRef.getDocument()
        
        guard userDoc.exists && clubDoc.exists else {
            throw NSError(domain: "ClubService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User or club document not found"])
        }
        
        // Start a batch write
        let batch = db.batch()
        
        // Remove club from user's joined clubs
        batch.updateData([
            "joinedClubIDs": FieldValue.arrayRemove([clubId])
        ], forDocument: userRef)
        
        // Remove user from club's members
        batch.updateData([
            "memberIDs": FieldValue.arrayRemove([userId])
        ], forDocument: clubRef)
        
        // Commit the batch
        try await batch.commit()
    }
    
    // Get all clubs a user has joined
    func getUserClubs(userId: String) async throws -> [String] {
        let userRef = db.collection("users").document(userId)
        let document = try await userRef.getDocument()
        
        if let data = document.data(),
           let joinedClubIDs = data["joinedClubIDs"] as? [String] {
            return joinedClubIDs
        }
        return []
    }
    
    // Get all members of a club
    func getClubMembers(clubId: String) async throws -> [String] {
        let clubRef = db.collection("clubs").document(clubId)
        let document = try await clubRef.getDocument()
        
        if let data = document.data(),
           let memberIDs = data["memberIDs"] as? [String] {
            return memberIDs
        }
        return []
    }
    
    // Check if a user is a member of a club
    func isUserMemberOfClub(userId: String, clubId: String) async throws -> Bool {
        let clubs = try await getUserClubs(userId: userId)
        return clubs.contains(clubId)
    }
    
    // Get club details
    func getClub(clubId: String) async throws -> Club? {
        let clubRef = db.collection("clubs").document(clubId)
        let document = try await clubRef.getDocument()
        
        if let data = document.data() {
            return try Firestore.Decoder().decode(Club.self, from: data)
        }
        return nil
    }
} 

import Foundation
import FirebaseFirestore


class ClubService: ObservableObject {
    private let db = Firestore.firestore()
    
    // Clean up unnamed clubs
    func cleanupUnnamedClubs() async throws {
        let snapshot = try await db.collection("clubs").getDocuments()
        
        for document in snapshot.documents {
            let data = document.data()
            if let name = data["name"] as? String,
               name == "Unnamed Club" {
                try await db.collection("clubs").document(document.documentID).delete()
                print("Deleted unnamed club: \(document.documentID)")
            }
        }
    }
    
    // Create mock clubs in Firestore
    func createMockClubs() async throws {
        // First clean up any unnamed clubs
        try await cleanupUnnamedClubs()
        
        for club in MockData.clubs {
            try await db.collection("clubs").document(club.id.uuidString).setData([
                "name": club.name,
                "description": club.description,
                "category": club.category.rawValue,
                "tags": club.tags,
                "schoolID": club.schoolID.uuidString,
                "creationDate": club.creationDate,
                "meetingSchedule": club.meetingSchedule,
                "meetingLocation": club.meetingLocation,
                "logo": club.logo,
                "memberIDs": club.memberIDs.map { $0.uuidString },
                "leadershipRoles": club.leadershipRoles.map { [
                    "userID": $0.userID.uuidString,
                    "role": $0.role,
                    "permissions": [
                        "permissions": $0.permissions.permissions.map { $0.rawValue }
                    ]
                ]},
                "isApproved": club.isApproved,
                "requiresApplicationToJoin": club.requiresApplicationToJoin
            ])
        }
    }
    
    // Add a user to a club
    func joinClub(userId: String, clubId: String) async throws {
        let userRef = db.collection("users").document(userId)
        let clubRef = db.collection("clubs").document(clubId)
        
        // Check if user document exists
        let userDoc = try await userRef.getDocument()
        if !userDoc.exists {
            // Create user document with empty joinedClubIDs array
            try await userRef.setData([
                "joinedClubIDs": [],
                "username": "",
                "email": "",
                "role": "student",
                "bio": "",
                "createdAt": FieldValue.serverTimestamp()
            ])
        }
        
        // Check if club document exists
        let clubDoc = try await clubRef.getDocument()
        if !clubDoc.exists {
            throw NSError(domain: "ClubService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Club not found"])
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
        
        guard let data = document.data(),
              let joinedClubIDs = data["joinedClubIDs"] as? [String] else {
            return []
        }
        
        return joinedClubIDs
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
        
        guard let data = document.data() else {
            print("No data found for club: \(clubId)")
            return nil
        }
        
        // Get required fields with defaults
        let name = data["name"] as? String ?? "Unnamed Club"
        let description = data["description"] as? String ?? "No description available"
        let categoryString = data["category"] as? String ?? "other"
        let category = Club.ClubCategory(rawValue: categoryString) ?? .other
        let schoolIDString = data["schoolID"] as? String ?? UUID().uuidString
        let schoolID = UUID(uuidString: schoolIDString) ?? UUID()
        let creationDate = (data["creationDate"] as? Timestamp)?.dateValue() ?? Date()
        let meetingSchedule = data["meetingSchedule"] as? String ?? "Schedule TBD"
        let meetingLocation = data["meetingLocation"] as? String ?? "Location TBD"
        let logo = data["logo"] as? String ?? "default_club_logo"
        let isApproved = data["isApproved"] as? Bool ?? false
        let requiresApplicationToJoin = data["requiresApplicationToJoin"] as? Bool ?? false
        
        // Convert string IDs to UUIDs
        let memberIDs = (data["memberIDs"] as? [String])?.compactMap { UUID(uuidString: $0) } ?? []
        let leadershipRoles = (data["leadershipRoles"] as? [[String: Any]])?.compactMap { roleData -> ClubLeadershipRole? in
            guard let userIDString = roleData["userID"] as? String,
                  let userID = UUID(uuidString: userIDString),
                  let role = roleData["role"] as? String else {
                return nil
            }
            
            // Handle permissions with defaults
            let permissionsData = roleData["permissions"] as? [String: Any]
            let permissionsArray = permissionsData?["permissions"] as? [String] ?? []
            let permissions = LeadershipPermissions(permissions: permissionsArray.compactMap { ClubPermission(rawValue: $0) })
            
            return ClubLeadershipRole(userID: userID, role: role, permissions: permissions)
        } ?? []
        
        // Create and return the club
        return Club(
            id: UUID(uuidString: clubId) ?? UUID(),
            name: name,
            description: description,
            category: category,
            tags: data["tags"] as? [String] ?? [],
            schoolID: schoolID,
            creationDate: creationDate,
            meetingSchedule: meetingSchedule,
            meetingLocation: meetingLocation,
            logo: logo,
            memberIDs: memberIDs,
            leadershipRoles: leadershipRoles,
            isApproved: isApproved,
            requiresApplicationToJoin: requiresApplicationToJoin
        )
    }
} 

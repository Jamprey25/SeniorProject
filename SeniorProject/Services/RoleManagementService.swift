import Foundation
import FirebaseFirestore

class RoleManagementService: ObservableObject {
    private let db = Firestore.firestore()
    static let shared = RoleManagementService()
    
    private init() {}
    
    // MARK: - Master Admin Configuration
    
    private let masterAdminEmails = [
        "ivamprey@gmail.com",
        "ivamprey@icloud.com",
        "josephamprey@gmail.com"
    ]
    
    func isMasterAdmin(email: String) -> Bool {
        return masterAdminEmails.contains(email.lowercased())
    }
    
    // MARK: - User Role Management
    
    func createNewUser(username: String, email: String, schoolID: UUID) async throws -> User {
        // Check if user is a master admin
        let initialRole: User.userRole = isMasterAdmin(email: email) ? .administrator : .student
        
        let user = User(
            username: username,
            email: email,
            schoolID: schoolID,
            role: initialRole
        )
        
        // Save user to Firestore
        try await db.collection("users").document(user.id.uuidString).setData([
            "username": username,
            "email": email,
            "schoolID": schoolID.uuidString,
            "role": initialRole.rawValue,
            "joinedClubIDs": [],
            "bio": "",
            "createdAt": FieldValue.serverTimestamp()
        ])
        
        return user
    }
    
    func updateUserRole(userID: UUID, newRole: User.userRole) async throws {
        try await db.collection("users").document(userID.uuidString).updateData([
            "role": newRole.rawValue,
            "roleUpdatedAt": FieldValue.serverTimestamp()
        ])
    }
    
    // MARK: - Club Head Application
    
    func submitClubHeadApplication(userID: UUID, requestedClubID: UUID?, proposedClubName: String?, reason: String) async throws {
        let application = [
            "id": UUID().uuidString,
            "userID": userID.uuidString,
            "requestedClubID": requestedClubID?.uuidString,
            "proposedClubName": proposedClubName,
            "reason": reason,
            "status": "pending",
            "applicationDate": FieldValue.serverTimestamp()
        ] as [String: Any]
        
        try await db.collection("clubHeadApplications").addDocument(data: application)
    }
    
    func approveClubHeadApplication(applicationID: String, adminUser: User) async throws {
        guard adminUser.isAdministrator() else {
            throw NSError(domain: "RoleManagementService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Insufficient permissions"])
        }
        
        let applicationRef = db.collection("clubHeadApplications").document(applicationID)
        let application = try await applicationRef.getDocument()
        
        guard let data = application.data(),
              let userID = data["userID"] as? String,
              let status = data["status"] as? String,
              status == "pending" else {
            throw NSError(domain: "RoleManagementService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid application"])
        }
        
        // Update application status
        try await applicationRef.updateData([
            "status": "approved",
            "approvedBy": adminUser.id.uuidString,
            "approvedAt": FieldValue.serverTimestamp()
        ])
        
        // Update user role
        try await updateUserRole(userID: UUID(uuidString: userID)!, newRole: .clubHead)
    }
    
    // MARK: - Club Creation Permissions
    
    func assignClubCreationPermissions(user: User, club: Club) async throws {
        let founderRole = ClubLeadershipRole(
            userID: user.id,
            role: "Founder",
            permissions: LeadershipPermissions(permissions: [
                .manageClub,
                .manageMembership,
                .postAnnouncements,
                .editClubInfo,
                .assignRoles
            ])
        )
        
        // Add founder role to club
        try await db.collection("clubs").document(club.id.uuidString).updateData([
            "leadershipRoles": FieldValue.arrayUnion([try Firestore.Encoder().encode(founderRole)])
        ])
        
        // If this is their first club and approved, elevate to club head
        if user.role == .student && club.isApproved {
            try await updateUserRole(userID: user.id, newRole: .clubHead)
        }
    }
    
    // MARK: - School Settings
    
    func getSchoolSettings(schoolID: UUID) async throws -> SchoolSettings {
        let settingsRef = db.collection("schoolSettings").document(schoolID.uuidString)
        let document = try await settingsRef.getDocument()
        
        if let data = document.data() {
            return try Firestore.Decoder().decode(SchoolSettings.self, from: data)
        }
        
        // Return default settings if none exist
        return SchoolSettings(
            schoolID: schoolID,
            allowsStudentClubCreation: true,
            requiresAdminApprovalForClubs: true,
            maxClubsPerStudent: 2,
            adminEmails: []
        )
    }
    
    func updateSchoolSettings(settings: SchoolSettings, adminUser: User) async throws {
        guard adminUser.isAdministrator() else {
            throw NSError(domain: "RoleManagementService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Insufficient permissions"])
        }
        
        try await db.collection("schoolSettings").document(settings.schoolID.uuidString).setData(
            try Firestore.Encoder().encode(settings)
        )
    }
    
    // Development method to create an admin account
    func createAdminAccount(email: String) async throws {
        // Only allow this in development
        #if DEBUG
        let adminEmail = "ivamprey@icloud.com"
        if email == adminEmail {
            try await db.collection("users").document(email).setData([
                "role": "administrator",
                "email": email,
                "username": "Admin",
                "createdAt": FieldValue.serverTimestamp()
            ])
        }
        #endif
    }
} 
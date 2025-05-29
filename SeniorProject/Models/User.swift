//
//  User.swift
//  SeniorProject
//
//  Created by Joseph Amprey on 5/20/25.
//

import Foundation
import FirebaseFirestore

class User: ObservableObject, Identifiable {
    let id: UUID
    @Published var username: String
    @Published var email: String
    @Published var schoolID: UUID
    @Published var role: userRole
    @Published var joinedClubIDs: [UUID]
    //@Published var profileImageURL: URL?
    @Published var bio: String
    @Published var grade: Int?
    
    private let clubService = ClubService()
    
    enum userRole: String {
        case student
        case clubHead
        case administrator
    }
    
    init(id: UUID = UUID(),
         username: String,
         email: String,
         schoolID: UUID,
         role: userRole = .student,
         joinedClubIDs: [UUID] = [],
         bio: String = "",
         grade: Int? = nil) {
        self.id = id
        self.username = username
        self.email = email
        self.schoolID = schoolID
        self.role = role
        self.joinedClubIDs = joinedClubIDs
        self.bio = bio
        self.grade = grade
    }
    
    //created methods later 
    
    func joinClub(clubID: UUID) async throws {
        if !joinedClubIDs.contains(clubID) {
            try await clubService.joinClub(userId: id.uuidString, clubId: clubID.uuidString)
            joinedClubIDs.append(clubID)
        }
    }
    
    func leaveClub(clubID: UUID) async throws {
        if joinedClubIDs.contains(clubID) {
            try await clubService.leaveClub(userId: id.uuidString, clubId: clubID.uuidString)
            joinedClubIDs.removeAll { $0 == clubID }
        }
    }
    
    func isMemberOfClub(clubID: UUID) -> Bool {
        return joinedClubIDs.contains(clubID)
    }
    
    func isClubHead() -> Bool {
        return role == .clubHead
    }
    
    func isAdministrator() -> Bool {
        return role == .administrator
    }
    
    func updateRole(newRole: userRole) {
        self.role = newRole
    }
    
    func updateBio(newBio: String) {
        self.bio = newBio
    }
    
    func updateGrade(newGrade: Int?) {
        self.grade = newGrade
    }
    
    func getProfileInfo() -> [String: Any] {
        return [
            "username": username,
            "email": email,
            "role": role.rawValue,
            "bio": bio,
            "grade": grade as Any,
            "joinedClubs": joinedClubIDs.count
        ]
    }
    
    // MARK: - Permission Methods
    
    func canCreateClub() -> Bool {
        return PermissionManager.shared.canUserCreateClub(user: self)
    }
    
    func canManageClub(_ club: Club) -> Bool {
        return PermissionManager.shared.canUserManageClub(user: self, club: club)
    }
    
    func hasClubPermission(_ permission: ClubPermission, in club: Club) -> Bool {
        return PermissionManager.shared.canUserPerformAction(user: self, permission: permission, club: club)
    }
    
    func hasSystemPermission(_ permission: SystemPermission) -> Bool {
        return PermissionManager.shared.hasSystemPermission(user: self, permission: permission)
    }
    
    func getPermissionsInClub(_ club: Club) -> [ClubPermission] {
        return PermissionManager.shared.getUserPermissionsInClub(user: self, club: club)
    }
}

//
//  ClubLeadershipRole.swift
//  SeniorProject
//
//  Created by Joseph Amprey on 5/20/25.
//
import Foundation

struct ClubLeadershipRole: Identifiable, Codable {
    let id: UUID
    var userID: UUID
    var role: String
    var permissions: LeadershipPermissions
    
    init(id: UUID = UUID(), userID: UUID, role: String, permissions: LeadershipPermissions = LeadershipPermissions()) {
        self.id = id
        self.userID = userID
        self.role = role
        self.permissions = permissions
    }
    
    // Helper methods for permission management
    func hasPermission(_ permission: ClubPermission) -> Bool {
        return permissions.hasPermission(permission)
    }
    
    mutating func addPermission(_ permission: ClubPermission) {
        permissions.addPermission(permission)
    }
    
    mutating func removePermission(_ permission: ClubPermission) {
        permissions.removePermission(permission)
    }
}

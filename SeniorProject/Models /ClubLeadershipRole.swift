//
//  ClubLeadershipRole.swift
//  SeniorProject
//
//  Created by Joseph Amprey on 5/20/25.
//
import Foundation
struct ClubLeadershipRole: Identifiable {
    let id: UUID
    var userID: UUID
    var role: String
    //var permissions: LeadershipPermissions
    
    init(id: UUID = UUID(), userID: UUID, role: String) { // add this when ready permissions: LeadershipPermissions
        self.id = id
        self.userID = userID
        self.role = role
       // self.permissions = permissions
    }
}

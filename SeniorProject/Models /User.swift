//
//  User.swift
//  SeniorProject
//
//  Created by Joseph Amprey on 5/20/25.
//

import Foundation
class User: ObservableObject, Identifiable{
    let id : UUID
    @Published var username: String
    @Published var email: String
    @Published var schoolID: UUID
    @Published var role: userRole
    @Published var joinedClubIDs: [UUID]
    @Published var followedClubIDs: [UUID]
    //@Published var profileImageURL: URL?
    @Published var bio: String
    @Published var grade: Int?
    
    
    
    enum userRole: String, Codable  {
        case student
        case clubHead
        case administrator
        
        
        
    }
    
    init(id: UUID = UUID(),
    username: String,
    email: String,
    schoolID: UUID,
    role: userRole = .student,
    joinedClubIDs : [UUID] = [],
    followedClubIDs: [UUID] = [],
    bio: String = "",
    grade: Int? = nil) {
        self.id = id
        self.username = username
        self.email = email
        self.schoolID = schoolID
        self.role = role
        self.joinedClubIDs = joinedClubIDs
        self.followedClubIDs = followedClubIDs
        self.bio = bio
        self.grade = grade
    }
    
    //created methods later 
    
    
}

//
//  Club.swift
//  SeniorProject
//
//  Created by Joseph Amprey on 5/20/25.
//

import Foundation

struct Club: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var category: ClubCategory
    var tags: [String]
    var schoolID: UUID
    var creationDate: Date
    var meetingSchedule: String
    var meetingLocation: String
    var logo: String // Image name in Assets catalog
    //@Published var logoURL: URL?
    //@Published var coverImageURL: URL?
    var memberIDs: [UUID]
    var leadershipRoles: [ClubLeadershipRole]
    var isApproved: Bool
    var requiresApplicationToJoin: Bool
    
    init(id: UUID = UUID(),
         name: String,
         description: String,
         category: ClubCategory,
         tags: [String] = [],
         schoolID: UUID,
         creationDate: Date = Date(),
         meetingSchedule: String = "",
         meetingLocation: String = "",
         logo: String = "default_club_logo",
         memberIDs: [UUID] = [],
         leadershipRoles: [ClubLeadershipRole] = [],
         isApproved: Bool = false,
         requiresApplicationToJoin: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.tags = tags
        self.schoolID = schoolID
        self.creationDate = creationDate
        self.meetingSchedule = meetingSchedule
        self.meetingLocation = meetingLocation
        self.logo = logo
        self.memberIDs = memberIDs
        self.leadershipRoles = leadershipRoles
        self.isApproved = isApproved
        self.requiresApplicationToJoin = requiresApplicationToJoin
    }
    
    enum ClubCategory: String, CaseIterable, Codable {
        case academic = "Academic"
        case arts = "Arts"
        case athletics = "Athletics"
        case cultural = "Cultural"
        case service = "Community Service"
        case stem = "STEM"
        case publication = "Publications"
        case religious = "religious"
        case affinity = "affinity"
        case other = "Other"
    }
}

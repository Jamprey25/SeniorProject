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
    
    // MARK: - Member Management Methods
    
    /// Add a member to the club
    mutating func addMember(memberID: UUID) {
        if !memberIDs.contains(memberID) {
            memberIDs.append(memberID)
        }
    }
    
    /// Remove a member from the club
    mutating func removeMember(memberID: UUID) {
        memberIDs.removeAll { $0 == memberID }
    }
    
    /// Check if a user is a member of the club
    func isMember(memberID: UUID) -> Bool {
        return memberIDs.contains(memberID)
    }
    
    /// Get the total number of members
    func getMemberCount() -> Int {
        return memberIDs.count
    }
    
    // MARK: - Leadership Role Methods
    
    /// Add a leadership role
    mutating func addLeadershipRole(_ role: ClubLeadershipRole) {
        leadershipRoles.append(role)
    }
    
    /// Remove a leadership role
    mutating func removeLeadershipRole(for userID: UUID) {
        leadershipRoles.removeAll { $0.userID == userID }
    }
    
    /// Get all leadership roles
    func getLeadershipRoles() -> [ClubLeadershipRole] {
        return leadershipRoles
    }
    
    /// Check if a user has a leadership role
    func hasLeadershipRole(userID: UUID) -> Bool {
        return leadershipRoles.contains { $0.userID == userID }
    }
    
    // MARK: - Club Information Methods
    
    /// Update club description
    mutating func updateDescription(_ newDescription: String) {
        self.description = newDescription
    }
    
    /// Update meeting information
    mutating func updateMeetingInfo(schedule: String, location: String) {
        self.meetingSchedule = schedule
        self.meetingLocation = location
    }
    
    /// Add tags to the club
    mutating func addTags(_ newTags: [String]) {
        let uniqueTags = Set(tags + newTags)
        self.tags = Array(uniqueTags)
    }
    
    /// Remove tags from the club
    mutating func removeTags(_ tagsToRemove: [String]) {
        self.tags.removeAll { tagsToRemove.contains($0) }
    }
    
    /// Get club information as a dictionary
    func getClubInfo() -> [String: Any] {
        return [
            "name": name,
            "description": description,
            "category": category.rawValue,
            "tags": tags,
            "meetingSchedule": meetingSchedule,
            "meetingLocation": meetingLocation,
            "memberCount": memberIDs.count,
            "leadershipCount": leadershipRoles.count,
            "isApproved": isApproved,
            "requiresApplication": requiresApplicationToJoin
        ]
    }
}

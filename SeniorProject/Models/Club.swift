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
    
    
    
   
    mutating func addMember(memberID: UUID) { //only accescibale to club head
        if !memberIDs.contains(memberID) {
            memberIDs.append(memberID)
        }
    }
    
    
    mutating func removeMember(memberID: UUID) {//only accescibale to club head
        memberIDs.removeAll { $0 == memberID }
    }
    
    
   public func isMember(memberID: UUID) -> Bool {
        return memberIDs.contains(memberID)
    }
    
    
    public func getMemberCount() -> Int {
        return memberIDs.count
    }
    
    // MARK: - Leadership Role Methods
    
   
    mutating func addLeadershipRole(_ role: ClubLeadershipRole) { //only accescibale to club head and administrator
        leadershipRoles.append(role)
    }
    
    
    mutating func removeLeadershipRole(for userID: UUID) {//only accescibale to club head and administrator
        leadershipRoles.removeAll { $0.userID == userID }
    }
    
   
    public func getLeadershipRoles() -> [ClubLeadershipRole] {
        return leadershipRoles
    }
    
   
    public func hasLeadershipRole(userID: UUID) -> Bool {
        return leadershipRoles.contains { $0.userID == userID }
    }
    
    //ONLY People with leadership roles can do these
    
   
    mutating func updateDescription(_ newDescription: String) {
        self.description = newDescription
    }
    
    
    mutating func updateMeetingInfo(schedule: String, location: String) {
        self.meetingSchedule = schedule
        self.meetingLocation = location
    }
    
    
    mutating func addTags(_ newTags: [String]) {
        let uniqueTags = Set(tags + newTags)
        self.tags = Array(uniqueTags)
    }
    
   
    mutating func removeTags(_ tagsToRemove: [String]) {
        self.tags.removeAll { tagsToRemove.contains($0) }
    }
    
    
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
    
    // MARK: - Permission Methods
    
    func getUserPermissions(for userID: UUID) -> [ClubPermission] {
        guard let leadershipRole = leadershipRoles.first(where: { $0.userID == userID }) else {
            return []
        }
        return leadershipRole.permissions.permissions
    }
    
    func canUserPerformAction(userID: UUID, action: ClubPermission) -> Bool {
        guard let leadershipRole = leadershipRoles.first(where: { $0.userID == userID }) else {
            return false
        }
        return leadershipRole.hasPermission(action)
    }
    
    func isUserLeader(userID: UUID) -> Bool {
        return leadershipRoles.contains { $0.userID == userID }
    }
    
    func isUserFounder(userID: UUID) -> Bool {
        // Assuming the first leadership role is the founder
        return leadershipRoles.first?.userID == userID
    }
    
    // MARK: - Leadership Role Management
    
    mutating func assignLeadershipRole(userID: UUID, role: String, permissions: [ClubPermission]) {
        let leadershipPermissions = LeadershipPermissions(permissions: permissions)
        let newRole = ClubLeadershipRole(userID: userID, role: role, permissions: leadershipPermissions)
        leadershipRoles.append(newRole)
    }
    
    mutating func updateLeadershipPermissions(userID: UUID, permissions: [ClubPermission]) {
        if let index = leadershipRoles.firstIndex(where: { $0.userID == userID }) {
            leadershipRoles[index].permissions = LeadershipPermissions(permissions: permissions)
        }
    }
    
    mutating func removeLeadershipRole(userID: UUID) {
        leadershipRoles.removeAll { $0.userID == userID }
    }
}

//
//  Announcement.swift
//  SeniorProject
//
//  Created by Joseph Amprey on 5/20/25.
//

import Foundation

struct Announcement: Identifiable, Codable {
    let id: UUID
    let clubID: UUID
    let authorID: UUID
    var title: String
    var  content: String
    let creationDate: Date
    //let imageURLs: [URL]?
    var isPinned: Bool
    var reactions: [UUID: ReactionType]
    
    enum ReactionType: String, CaseIterable, Codable {
        case like = "👍"
        case love = "❤️"
        case laugh = "😂"
        case wow = "😮"
        case sad = "😢"
    }
  
    init(id: UUID = UUID(),
             clubID: UUID,
             authorID: UUID,
             title: String,
             content: String,
             creationDate: Date = Date(),
             isPinned: Bool = false,
             reactions: [UUID: ReactionType] = [:]) {
            self.id = id
            self.clubID = clubID
            self.authorID = authorID
            self.title = title
            self.content = content
            self.creationDate = creationDate
            self.isPinned = isPinned
            self.reactions = reactions
        }
    
    
    mutating func addReaction(userID: UUID, reaction: ReactionType) {
        reactions[userID] = reaction
    }
    
    
    mutating func removeReaction(userID: UUID) {
        reactions.removeValue(forKey: userID)
    }
    
    
    func getUserReaction(userID: UUID) -> ReactionType? {
        return reactions[userID]
    }
    
  
    func getReactionCounts() -> [ReactionType: Int] {
        var counts: [ReactionType: Int] = [:]
        for reaction in reactions.values {
            counts[reaction, default: 0] += 1
        }
        return counts
    }
    
  
    func getTotalReactionCount() -> Int {
        return reactions.count
    }
    
    
    mutating func pin() {
        self.isPinned = true
    }
    
   
    mutating func unpin() {
        self.isPinned = false
    }
    
   
    func isPinnedAnnouncement() -> Bool {
        return isPinned
    }
    
   
    mutating func updateContent(title: String? = nil, content: String? = nil) {
        if let title = title { self.title = title }
        if let content = content { self.content = content }
    }
    
   
    func getAgeInDays() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: creationDate, to: Date())
        return components.day ?? 0
    }
    
    /// Get announcement information as a dictionary
    func getAnnouncementInfo() -> [String: Any] {
        return [
            "title": title,
            "content": content,
            "creationDate": creationDate,
            "isPinned": isPinned,
            "reactionCount": reactions.count,
            "ageInDays": getAgeInDays()
        ]
    }
}

//
//  Announcement.swift
//  SeniorProject
//
//  Created by Joseph Amprey on 5/20/25.
//

import Foundation
struct Announcement: Identifiable {
    let id: UUID
    let clubID: UUID
    let authorID: UUID
    let title: String
    let content: String
    let creationDate: Date
    //let imageURLs: [URL]?
    let isPinned: Bool
    var reactions: [UUID: ReactionType]
    
    enum ReactionType: String, Codable, CaseIterable {
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
    
    
    
    
}

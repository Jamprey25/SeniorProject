//
//  Event.swift
//  SeniorProject
//
//  Created by Joseph Amprey on 5/20/25.
//

import Foundation
struct Event: Identifiable {
    let id: UUID
    let clubID: UUID
    let name: String
    let description: String
    let startTime: Date
    let endTime: Date
    let location: String
    let isRequired: Bool
    let creatorID: UUID
    var attendeeIDs: [UUID]
    
    init(id: UUID = UUID(),
         clubID: UUID,
         name: String,
         description: String,
         startTime: Date,
         endTime: Date,
         location: String,
         isRequired: Bool = false,
         creatorID: UUID,
         attendeeIDs: [UUID] = []) {
        self.id = id
        self.clubID = clubID
        self.name = name
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.isRequired = isRequired
        self.creatorID = creatorID
        self.attendeeIDs = attendeeIDs
    }
    
    //Add an add member to event method *
    
}

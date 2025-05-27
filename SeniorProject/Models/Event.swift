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
    var name: String
    var description: String
    var startTime: Date
    var endTime: Date
    var location: String
    var isRequired: Bool
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
    
    
    mutating func addAttendee(attendeeID: UUID) {
        if !attendeeIDs.contains(attendeeID) {
            attendeeIDs.append(attendeeID)
        }
    }
    
   
    mutating func removeAttendee(attendeeID: UUID) {
        attendeeIDs.removeAll { $0 == attendeeID }
    }
    
    
    func isAttending(attendeeID: UUID) -> Bool {
        return attendeeIDs.contains(attendeeID)
    }
    
    
    func getAttendeeCount() -> Int {
        return attendeeIDs.count
    }
    
   
    func hasStarted() -> Bool {
        return Date() >= startTime
    }
    
    
    func hasEnded() -> Bool {
        return Date() >= endTime
    }
    
   
    func isOngoing() -> Bool {
        let now = Date()
        return now >= startTime && now <= endTime
    }
    
    
    func getDurationInMinutes() -> Int {
        return Int(endTime.timeIntervalSince(startTime) / 60)
    }
    
    
    mutating func updateEventDetails(name: String? = nil, description: String? = nil, location: String? = nil) {
        if let name = name { self.name = name }
        if let description = description { self.description = description }
        if let location = location { self.location = location }
    }
    
    /// Update event time
    mutating func updateEventTime(startTime: Date? = nil, endTime: Date? = nil) {
        if let startTime = startTime { self.startTime = startTime }
        if let endTime = endTime { self.endTime = endTime }
    }
    
    /// Get event information as a dictionary
    func getEventInfo() -> [String: Any] {
        return [
            "name": name,
            "description": description,
            "startTime": startTime,
            "endTime": endTime,
            "location": location,
            "isRequired": isRequired,
            "attendeeCount": attendeeIDs.count,
            "status": isOngoing() ? "ongoing" : hasEnded() ? "ended" : "upcoming"
        ]
    }
}

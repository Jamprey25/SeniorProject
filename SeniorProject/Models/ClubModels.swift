import Foundation

// Using ClubCategory from Club.swift
enum MeetingFrequency: String, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case asNeeded = "As needed"
    
    var id: String { self.rawValue }
}

struct ClubSubmission: Identifiable {
    let id = UUID()
    var name: String
    var category: Club.ClubCategory
    var shortDescription: String
    var detailedDescription: String
    var meetingFrequency: MeetingFrequency
    var meetingTime: Date?
    var goals: String
    var contactEmail: String
    var status: ClubStatus = .pending
    
    enum ClubStatus {
        case pending
        case approved
        case rejected
    }
} 
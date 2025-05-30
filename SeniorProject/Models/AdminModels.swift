import Foundation

struct AdminClubRequest: Identifiable {
    let id: UUID
    let clubName: String
    let description: String
    let category: ClubCategory
    let requestedBy: User
    let submissionDate: Date
    let status: RequestStatus
    let foundingMembers: Int
    
    struct User {
        let id: UUID
        let username: String
        let email: String
        let grade: Int
        let currentClubs: [String]
    }
}

struct AdminClubHeadApplication: Identifiable {
    let id: UUID
    let applicant: AdminClubRequest.User
    let targetClubID: UUID?
    let targetClubName: String?
    let applicationReason: String
    let submissionDate: Date
    let status: ApplicationStatus
    let leadershipExperience: String
    let academicStanding: String
}

enum ClubCategory: String, CaseIterable {
    case academic = "Academic"
    case arts = "Arts"
    case sports = "Sports"
    case technology = "Technology"
    case community = "Community Service"
    case cultural = "Cultural"
    case other = "Other"
}

enum RequestStatus: String {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
}

enum ApplicationStatus: String {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
} 
import Foundation

struct AdminClubRequest: Identifiable, Equatable {
    let id: UUID
    let firestoreID: String
    let clubName: String
    let description: String
    let category: Club.ClubCategory
    let requestedBy: User
    let submissionDate: Date
    let status: RequestStatus
    let foundingMembers: Int
    
    struct User: Equatable {
        let id: UUID
        let username: String
        let email: String
        let grade: Int
        let currentClubs: [String]
    }
    
    static func == (lhs: AdminClubRequest, rhs: AdminClubRequest) -> Bool {
        lhs.id == rhs.id &&
        lhs.firestoreID == rhs.firestoreID &&
        lhs.clubName == rhs.clubName &&
        lhs.description == rhs.description &&
        lhs.category == rhs.category &&
        lhs.requestedBy == rhs.requestedBy &&
        lhs.submissionDate == rhs.submissionDate &&
        lhs.status == rhs.status &&
        lhs.foundingMembers == rhs.foundingMembers
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

enum RequestStatus: String, Equatable {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
}

enum ApplicationStatus: String, Equatable {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
} 
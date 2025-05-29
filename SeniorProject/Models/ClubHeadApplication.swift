import Foundation

struct ClubHeadApplication: Identifiable, Codable {
    let id: UUID
    let userID: UUID
    let requestedClubID: UUID?
    let proposedClubName: String?
    let reason: String
    let applicationDate: Date
    var status: ApplicationStatus
    var approvedBy: UUID?
    var approvedAt: Date?
    
    enum ApplicationStatus: String, Codable {
        case pending
        case approved
        case rejected
    }
    
    init(id: UUID = UUID(),
         userID: UUID,
         requestedClubID: UUID? = nil,
         proposedClubName: String? = nil,
         reason: String,
         applicationDate: Date = Date(),
         status: ApplicationStatus = .pending,
         approvedBy: UUID? = nil,
         approvedAt: Date? = nil) {
        self.id = id
        self.userID = userID
        self.requestedClubID = requestedClubID
        self.proposedClubName = proposedClubName
        self.reason = reason
        self.applicationDate = applicationDate
        self.status = status
        self.approvedBy = approvedBy
        self.approvedAt = approvedAt
    }
    
    var isPending: Bool {
        return status == .pending
    }
    
    var isApproved: Bool {
        return status == .approved
    }
    
    var isRejected: Bool {
        return status == .rejected
    }
    
    mutating func approve(by adminID: UUID) {
        status = .approved
        approvedBy = adminID
        approvedAt = Date()
    }
    
    mutating func reject() {
        status = .rejected
    }
} 
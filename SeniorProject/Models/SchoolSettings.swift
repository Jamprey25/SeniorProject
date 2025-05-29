import Foundation

struct SchoolSettings: Codable {
    let schoolID: UUID
    var allowsStudentClubCreation: Bool
    var requiresAdminApprovalForClubs: Bool
    var maxClubsPerStudent: Int
    var adminEmails: [String]
    
    init(schoolID: UUID,
         allowsStudentClubCreation: Bool = true,
         requiresAdminApprovalForClubs: Bool = true,
         maxClubsPerStudent: Int = 2,
         adminEmails: [String] = []) {
        self.schoolID = schoolID
        self.allowsStudentClubCreation = allowsStudentClubCreation
        self.requiresAdminApprovalForClubs = requiresAdminApprovalForClubs
        self.maxClubsPerStudent = maxClubsPerStudent
        self.adminEmails = adminEmails
    }
    
    func canStudentCreateClub() -> Bool {
        return allowsStudentClubCreation
    }
    
    func requiresApproval() -> Bool {
        return requiresAdminApprovalForClubs
    }
    
    func isAdminEmail(_ email: String) -> Bool {
        return adminEmails.contains(email.lowercased())
    }
    
    mutating func addAdminEmail(_ email: String) {
        if !adminEmails.contains(email.lowercased()) {
            adminEmails.append(email.lowercased())
        }
    }
    
    mutating func removeAdminEmail(_ email: String) {
        adminEmails.removeAll { $0.lowercased() == email.lowercased() }
    }
} 
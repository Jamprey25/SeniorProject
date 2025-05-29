import Foundation

// MARK: - Permission Enums

enum ClubPermission: String, CaseIterable, Codable {
    case createClub = "create_club"
    case manageClub = "manage_club"
    case moderateContent = "moderate_content"
    case approveClubs = "approve_clubs"
    case manageMembership = "manage_membership"
    case postAnnouncements = "post_announcements"
    case editClubInfo = "edit_club_info"
    case deleteClub = "delete_club"
    case assignRoles = "assign_roles"
}

enum SystemPermission: String, CaseIterable, Codable {
    case viewAllClubs = "view_all_clubs"
    case moderateUsers = "moderate_users"
    case manageSchoolSettings = "manage_school_settings"
    case viewAnalytics = "view_analytics"
}

// MARK: - Leadership Permissions

struct LeadershipPermissions: Codable {
    var permissions: [ClubPermission]
    
    init(permissions: [ClubPermission] = []) {
        self.permissions = permissions
    }
    
    func hasPermission(_ permission: ClubPermission) -> Bool {
        return permissions.contains(permission)
    }
    
    mutating func addPermission(_ permission: ClubPermission) {
        if !permissions.contains(permission) {
            permissions.append(permission)
        }
    }
    
    mutating func removePermission(_ permission: ClubPermission) {
        permissions.removeAll { $0 == permission }
    }
}

// MARK: - Permission Manager

class PermissionManager: ObservableObject {
    static let shared = PermissionManager()
    
    private init() {}
    
    // MARK: - Club Creation Permissions
    
    func canUserCreateClub(user: User) -> Bool {
        // Only verified students can create clubs
        guard user.role == .student else { return false }
        
        // TODO: Add checks for:
        // - Pending applications limit (2 per user)
        // - User ban status
        // - School's student-created clubs policy
        
        return true
    }
    
    // MARK: - Club Management Permissions
    
    func canUserManageClub(user: User, club: Club) -> Bool {
        // Administrators can manage any club
        if user.role == .administrator {
            return true
        }
        
        // Club heads can manage their own clubs
        if user.role == .clubHead {
            return club.leadershipRoles.contains { $0.userID == user.id }
        }
        
        return false
    }
    
    func canUserPerformAction(user: User, permission: ClubPermission, club: Club?) -> Bool {
        // Administrators have all permissions
        if user.role == .administrator {
            return true
        }
        
        // If no specific club is provided, check system-wide permissions
        guard let club = club else {
            return hasSystemPermission(user: user, permission: permission)
        }
        
        // Check club-specific permissions
        return getUserPermissionsInClub(user: user, club: club).contains(permission)
    }
    
    func getUserPermissionsInClub(user: User, club: Club) -> [ClubPermission] {
        // Administrators have all permissions
        if user.role == .administrator {
            return ClubPermission.allCases
        }
        
        // Find user's leadership role in the club
        guard let leadershipRole = club.leadershipRoles.first(where: { $0.userID == user.id }) else {
            return []
        }
        
        // Return permissions based on leadership role
        return leadershipRole.permissions.permissions
    }
    
    // MARK: - System Permissions
    
    func hasSystemPermission(user: User, permission: ClubPermission) -> Bool {
        switch permission {
        case .approveClubs, .moderateContent:
            return user.role == .administrator
        default:
            return false
        }
    }
    
    func hasSystemPermission(user: User, permission: SystemPermission) -> Bool {
        switch permission {
        case .viewAllClubs:
            return true // All users can view clubs
        case .moderateUsers, .manageSchoolSettings, .viewAnalytics:
            return user.role == .administrator
        }
    }
} 
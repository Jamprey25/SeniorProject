import SwiftUI

struct PermissionBasedView<Content: View>: View {
    let user: User
    let permission: ClubPermission
    let club: Club?
    let content: () -> Content
    
    init(user: User, permission: ClubPermission, club: Club? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.user = user
        self.permission = permission
        self.club = club
        self.content = content
    }
    
    var body: some View {
        Group {
            if user.hasClubPermission(permission, in: club ?? Club(id: UUID(), name: "", description: "", category: .other, schoolID: UUID())) {
                content()
            } else {
                EmptyView()
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    func permissionGated(user: User, permission: ClubPermission, club: Club? = nil) -> some View {
        PermissionBasedView(user: user, permission: permission, club: club) {
            self
        }
    }
    
    func systemPermissionGated(user: User, permission: SystemPermission) -> some View {
        Group {
            if user.hasSystemPermission(permission) {
                self
            } else {
                EmptyView()
            }
        }
    }
}

// MARK: - Preview Provider

struct PermissionBasedView_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(
            username: "Test User",
            email: "test@example.com",
            schoolID: UUID(),
            role: .student
        )
        
        let club = Club(
            name: "Test Club",
            description: "Test Description",
            category: .academic,
            schoolID: UUID()
        )
        
        return VStack {
            Text("Visible Content")
                .permissionGated(user: user, permission: .createClub)
            
            Text("Hidden Content")
                .permissionGated(user: user, permission: .approveClubs)
        }
    }
} 
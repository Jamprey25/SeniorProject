import Foundation
import FirebaseFirestore

@MainActor
class ClubDetailViewModel: ObservableObject {
    @Published var members: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let clubService = ClubService()
    private let db = Firestore.firestore()
    
    func loadMembers(for clubId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Get member IDs from the club
            let memberIds = try await clubService.getClubMembers(clubId: clubId)
            
            // Fetch user details for each member
            var loadedMembers: [User] = []
            for memberId in memberIds {
                if let userData = try await db.collection("users").document(memberId).getDocument().data() {
                    let user = User(
                        id: UUID(uuidString: memberId) ?? UUID(),
                        username: userData["username"] as? String ?? "",
                        email: userData["email"] as? String ?? "",
                        schoolID: UUID(uuidString: userData["schoolID"] as? String ?? "") ?? UUID(),
                        role: User.userRole(rawValue: userData["role"] as? String ?? "student") ?? .student,
                        joinedClubIDs: [],
                        bio: userData["bio"] as? String ?? "",
                        grade: userData["grade"] as? Int
                    )
                    loadedMembers.append(user)
                }
            }
            
            self.members = loadedMembers
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
} 
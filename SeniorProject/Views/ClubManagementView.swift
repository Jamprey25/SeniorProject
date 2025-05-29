import SwiftUI

struct ClubManagementView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Text("Club Management View")
            }
            .navigationTitle("Manage Clubs")
        }
    }
}

#Preview {
    ClubManagementView()
        .environmentObject(AuthenticationViewModel())
} 
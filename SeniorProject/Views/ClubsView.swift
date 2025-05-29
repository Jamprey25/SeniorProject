import SwiftUI

struct ClubsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Text("Clubs View")
            }
            .navigationTitle("Clubs")
        }
    }
}

#Preview {
    ClubsView()
        .environmentObject(AuthenticationViewModel())
} 
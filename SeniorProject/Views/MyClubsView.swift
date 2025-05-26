import SwiftUI

struct MyClubsView: View {
    // Mock data for joined clubs and pending requests
    let joinedClubs = Array(MockData.clubs.prefix(3))
    let pendingClubs = Array(MockData.clubs.suffix(2))
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("My Clubs")) {
                    ForEach(joinedClubs) { club in
                        NavigationLink(destination: Text(club.name)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(club.name)
                                    .font(.headline)
                                Text(club.meetingSchedule)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section(header: Text("Pending Requests")) {
                    ForEach(pendingClubs) { club in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(club.name)
                                    .font(.headline)
                                Text("Request pending approval")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Handle cancel request
                            }) {
                                Text("Cancel")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Clubs")
        }
    }
}

#Preview {
    MyClubsView()
} 
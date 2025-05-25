import SwiftUI

struct MyClubsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("My Clubs")) {
                    Text("Club 1")
                    Text("Club 2")
                    Text("Club 3")
                }
                
                Section(header: Text("Pending Requests")) {
                    Text("Club 4")
                    Text("Club 5")
                }
            }
            .navigationTitle("My Clubs")
        }
    }
}

#Preview {
    MyClubsView()
} 
import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text("Profile")
                                    .foregroundColor(.gray)
                            )
                        
                        VStack(alignment: .leading) {
                            Text("User Name")
                                .font(.headline)
                            Text("user@email.com")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.leading)
                    }
                    .padding(.vertical)
                }
                
                Section(header:Text("Settings")) {
                    Text("Edit Profile")
                    Text("Notifications")
                    Text("Privacy")
                    Text("Help & Support")
                }
                
                Section {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
} 

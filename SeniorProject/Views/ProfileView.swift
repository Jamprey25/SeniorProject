import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    // User Info
                    HStack {
                        Circle()
                            .fill(AppTheme.primary.opacity(0.1))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(AppTheme.primary)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authViewModel.currentUser?.username ?? "")
                                .font(.headline)
                            Text(authViewModel.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    // Role Info
                    HStack {
                        Text("Role")
                        Spacer()
                        Text(authViewModel.currentUser?.role.rawValue.capitalized ?? "")
                            .foregroundColor(.secondary)
                    }
                    
                    if let grade = authViewModel.currentUser?.grade {
                        HStack {
                            Text("Grade")
                            Spacer()
                            Text("\(grade)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    // Sign Out Button
                    Button(role: .destructive) {
                        showingSignOutAlert = true
                    } label: {
                        HStack {
                            Text("Sign Out")
                            Spacer()
                            Image(systemName: "arrow.right.square")
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

// Preview provider
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthenticationViewModel())
    }
} 

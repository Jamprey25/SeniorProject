import SwiftUI

struct CreateClubView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Create Club View")
                }
                .padding()
            }
            .background(AppTheme.background)
            .navigationTitle("Create Club")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CreateClubView()
} 
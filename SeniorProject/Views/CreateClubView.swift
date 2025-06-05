import SwiftUI

struct CreateClubView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateClubViewModel()
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Club Name", text: $viewModel.name)
                    TextField("Short Description", text: $viewModel.shortDescription)
                    TextEditor(text: $viewModel.detailedDescription)
                        .frame(height: 100)
                }
                
                Section("Category") {
                    Picker("Category", selection: $viewModel.category) {
                        ForEach(Club.ClubCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section("Meeting Information") {
                    TextField("Meeting Schedule (e.g., Every Monday 11:45-12:15)", text: $viewModel.meetingSchedule)
                    TextField("Meeting Location", text: $viewModel.meetingLocation)
                }
                
                Section("Contact") {
                    TextField("Contact Email", text: $viewModel.contactEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Toggle("Requires Application to Join", isOn: $viewModel.requiresApplicationToJoin)
                }
            }
            .navigationTitle("Create Club")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        Task {
                            do {
                                try await viewModel.submitClub()
                                showingSuccessAlert = true
                            } catch {
                                viewModel.errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isSubmitting)
                }
            }
            .alert("Success", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your club request has been submitted and is pending admin approval.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .overlay {
                if viewModel.isSubmitting {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    CreateClubView()
} 
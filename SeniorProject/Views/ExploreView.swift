import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var searchText = ""
    @State private var selectedCategory: Club.ClubCategory?
    @State private var clubs = MockData.clubs
    @State private var showingCreateClub = false
    
    var filteredClubs: [Club] {
        clubs.filter { club in
            let matchesSearch = searchText.isEmpty || 
                club.name.localizedCaseInsensitiveContains(searchText) ||
                club.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == nil || club.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search clubs...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                // Club List
                List {
                    Text("Explore View")
                }
            }
            .navigationTitle("Explore")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateClub = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .sheet(isPresented: $showingCreateClub) {
                CreateClubView()
            }
        }
    }
}

// Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textSecondary)
            
            TextField("Search clubs...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .shadow(
            color: AppTheme.shadowSmall.color,
            radius: AppTheme.shadowSmall.radius,
            x: AppTheme.shadowSmall.x,
            y: AppTheme.shadowSmall.y
        )
    }
}

// Category Filter Button
struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                .padding(.horizontal, AppTheme.spacingMedium)
                .padding(.vertical, AppTheme.spacingSmall)
                .background(
                    isSelected ?
                    AnyView(AppTheme.primaryGradient) :
                    AnyView(AppTheme.surface)
                )
                .cornerRadius(AppTheme.cornerRadiusMedium)
                .shadow(
                    color: isSelected ?
                        AppTheme.primary.opacity(0.3) :
                        AppTheme.shadowSmall.color,
                    radius: isSelected ? 8 : AppTheme.shadowSmall.radius,
                    x: 0,
                    y: isSelected ? 4 : AppTheme.shadowSmall.y
                )
        }
    }
}

// Club Card
struct ClubCard: View {
    let club: Club
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: ClubDetailView(club: club)) {
            VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                // Club Image
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                        .fill(AppTheme.primary.opacity(0.1))
                        .frame(height: 120)
                        .overlay(
                            Image(club.logo)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .clipped()
                        )
                    
                    if club.requiresApplicationToJoin {
                        Text("Application Required")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.secondary)
                            .cornerRadius(AppTheme.cornerRadiusSmall)
                            .padding(8)
                    }
                }
                
                // Club Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(club.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    Text(club.description)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                    
                    // Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(club.tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(AppTheme.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.primary.opacity(0.1))
                                    .cornerRadius(AppTheme.cornerRadiusSmall)
                            }
                        }
                    }
                }
                .padding(AppTheme.spacingSmall)
            }
            .background(AppTheme.surface)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .shadow(
                color: AppTheme.shadowSmall.color,
                radius: AppTheme.shadowSmall.radius,
                x: AppTheme.shadowSmall.x,
                y: AppTheme.shadowSmall.y
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: { })
    }
}

#Preview {
    ExploreView()
        .environmentObject(AuthenticationViewModel())
} 

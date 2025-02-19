import SwiftUI

// MARK: - Rotating Carousel View
struct RotatingCarouselView: View {
    let imageCount = 36
    @State private var currentIndex: Int = 0
    @State private var lastTranslation: CGFloat = 0
    // Adjust sensitivity (points per image change)
    let sensitivity: CGFloat = 10

    var body: some View {
        Image("MT03SB_\(currentIndex + 1)")
            .resizable()
            .scaledToFit()
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let delta = value.translation.width - lastTranslation
                        if abs(delta) >= sensitivity {
                            let steps = Int(delta / sensitivity)
                            currentIndex = (currentIndex - steps + imageCount) % imageCount
                            lastTranslation = value.translation.width
                        }
                    }
                    .onEnded { _ in
                        lastTranslation = 0
                    }
            )
    }
}

// MARK: - Model for Settings Options
struct SettingsOption: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let background: Color
    let destination: AnyView?  // If nil, no navigation occurs
}

struct SettingsView: View {
    @Binding var userFavorites: [FavoriteItem]
    
    // Track which option (if any) is active for sheet presentation.
    @State private var activeSheet: SettingsOption? = nil

    // Define our 9 grid cells as a stored property.
    private let options: [SettingsOption] = [
        SettingsOption(title: "Favorites",
                       icon: "star.circle",
                       background: Color.yellow,
                       destination: AnyView(ManageFavoritesView(userFavorites: .constant([])))),
        
        SettingsOption(title: "Categories",
                       icon: "circle.hexagongrid.circle",
                       background: Color.blue,
                       destination: AnyView(ManageCategoriesView())),
        
        SettingsOption(title: "Contacts",
                       icon: "phone.circle",
                       background: Color.purple,
                       destination: AnyView(ManageContactsView().environmentObject(ContactsManager()))),
        
        SettingsOption(title: "Music",
                       icon: "play.circle",
                       background: Color.pink,
                       destination: AnyView(ManageMusicView())),
        
        SettingsOption(title: "Maps",
                       icon: "map.circle",
                       background: Color.green,
                       destination: AnyView(ManageMapsView())),
        
        SettingsOption(title: "Garage",
                       icon: "car.circle",
                       background: Color.gray,
                       destination: nil),
        
        SettingsOption(title: "Profile",
                       icon: "person.circle",
                       background: Color.black,
                       destination: nil),
        
        // Two empty placeholders to complete the grid.
        SettingsOption(title: "", icon: "", background: Color.clear, destination: nil),
        SettingsOption(title: "", icon: "", background: Color.clear, destination: nil)
    ]
    
    // Define a 3-column grid.
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Top half: Rotating carousel and motorcycle name.
                    VStack(spacing: 8) {
                        RotatingCarouselView()
                            .frame(height: geometry.size.height * 0.4)
                        VStack(spacing: 4) {
                            Text("Yamaha MT-03")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("2022")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(height: geometry.size.height * 0.5)
                    
                    // Bottom half: 3x3 grid.
                    LazyVGrid(columns: columns, spacing: 30) {
                        ForEach(options) { option in
                            SettingsCell(option: option)
                                // If the option has a destination (and a non-empty title), make it tappable.
                                .onTapGesture {
                                    if option.destination != nil && !option.title.isEmpty {
                                        activeSheet = option
                                    }
                                }
                        }
                    }
                    .padding()
                }
                .edgesIgnoringSafeArea(.all)
            }
            .navigationBarHidden(true)
            // Attach a sheet that is bound to the activeSheet option.
            .sheet(item: $activeSheet) { option in
                // Wrap in a NavigationView if your destination view needs its own navigation stack.
                if let destination = option.destination {
                    NavigationView {
                        destination
                            .navigationBarTitle(option.title, displayMode: .inline)
                    }
                } else {
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Settings Cell View
struct SettingsCell: View {
    let option: SettingsOption
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(option.background)
                    .frame(width: 80, height: 80)
                if !option.icon.isEmpty {
                    Image(systemName: option.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
            }
            if !option.title.isEmpty {
                Text(option.title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var favorites: [FavoriteItem] = []
    static var previews: some View {
        SettingsView(userFavorites: $favorites)
    }
}

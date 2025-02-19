import SwiftUI
import MapKit
import MediaPlayer
import CoreLocation
import WeatherKit
import Combine

struct ContentView: View {
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
        span: ContentView.defaultSpan)
    @State private var didSetInitialLocation = false
    @State private var searchText: String = ""
    @State private var showSearchView = false
    @State private var showPlaylistSelector = false
    @StateObject private var locationManager = LocationManager()
    @State private var selectedMapItem: MKMapItem? = nil
    @StateObject private var searchViewModel = MapSearchViewModel()
    @StateObject private var musicLibraryViewModel = MusicLibraryViewModel()
    @StateObject private var musicPlayerViewModel = MusicPlayerViewModel()
    @State private var showFavoritesBar = false
    @State private var showCategoryBar = false
    @State private var showSettingsSheet = false
    @State private var showMusicServices = false
    @State private var showNavigationSteps: Bool = false
    @State private var currentNavStepIndex: Int = 0
    @State private var navigationMode: Bool = false  // New flag for NavigationMode
    @State private var selectedMusicService: MusicServiceBar.MusicService = .apple
    @StateObject private var navStepsVM = NavigationStepsViewModel()
    @StateObject private var contactsManager = ContactsManager()
    @State private var categorySettings: [CategorySettingGroup] = CategorySettingsStorage.load() ?? defaultCategoryGroups
    @State private var userFavorites: [FavoriteItem] = []
    @State private var allowedCategories: [MKPointOfInterestCategory] = [
        .bakery, .brewery, .cafe, .foodMarket, .restaurant, .winery,
        .zoo, .amusementPark, .campground, .atm, .bank, .museum,
        .theater, .park, .gasStation, .beach, .nationalPark, .landmark,
        .musicVenue, .fairground, .aquarium, .castle, .fortress
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main map and music controls
            VStack(spacing: 0) {
                CompassMapView(region: $region,
                                userLocation: locationManager.location,
                                heading: locationManager.heading?.trueHeading,
                                selectedItem: $selectedMapItem,
                                allowedCategories: $allowedCategories)
                    .frame(maxHeight: .infinity)
                    .clipShape(RoundedCorner(radius: 25, corners: [.bottomLeft, .bottomRight]))
                    .zIndex(1)
                MusicControlView(showPlaylistSelector: $showPlaylistSelector,                 selectedService: $selectedMusicService)
                    .environmentObject(musicPlayerViewModel)
                    .environmentObject(musicLibraryViewModel)
                    .frame(height: 225)
                    .offset(y: -25)
                    .zIndex(0)
            }
            
            // Bottom overlays (only show these if no destination is selected)
            if selectedMapItem == nil {
                ContactBar()
                    .padding(.trailing, 16)
                    .padding(.bottom, 420)
                    .transition(.move(edge: .trailing))
                
                CategoryBar(showCategories: $showCategoryBar,
                            allowedCategories: $allowedCategories,
                            categorySettings: $categorySettings)
                    .padding(.trailing, 16)
                    .padding(.bottom, 330)
                    .transition(.move(edge: .trailing))
                
                FavoriteDestinationBar(showFavorites: $showFavoritesBar,
                                       userFavorites: $userFavorites) { mkItem in
                    selectedMapItem = mkItem
                }
                .padding(.trailing, 16)
                .padding(.bottom, 240)
                .transition(.move(edge: .trailing))
            }
            
            // Music Action Bar
            MusicServiceBar(showMusicServices: $showMusicServices, showPlaylistSelector: $showPlaylistSelector, selectedService: $selectedMusicService
)
                .environmentObject(musicPlayerViewModel)
                .offset(x: 200)
                .padding(.trailing, 16)
                .padding(.bottom, 160)
                .zIndex(2)
            
            // Destination overlay
            if let dest = selectedMapItem {
                SelectedDestinationCard(
                    mapItem: dest,
                    userLocation: locationManager.location,
                    navigationSteps: navStepsVM.steps,
                    onClose: {
                        selectedMapItem = nil
                        // When destination is closed, exit navigation mode.
                        navigationMode = false
                    },
                    onNavigate: {
                        // User tapped the green button. Enter NavigationMode.
                        withAnimation {
                            showNavigationSteps = true
                            navigationMode = true
                            currentNavStepIndex = 0
                            // Adjust the map region for NavigationMode.
                            // **Adjust the values below to achieve your desired zoom and 3D view:**
                            region.center = navStepsVM.steps.first?.coordinate ?? region.center
                            region.span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                        }
                    }
                )
                .padding(.bottom, 240)
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: selectedMapItem)
                .zIndex(4)
                .offset(y:15)
            }
        }
        // Top overlay: combine profile, search, and status capsules
        .overlay(
            VStack{
                Spacer().frame(height: 32) // Adjust this value as needed

                HStack {
                    Button(action: { showSettingsSheet = true }) {
                        Image(systemName: "person.crop.circle")
                            .font(.title3)
                            .padding(15)
                            .foregroundStyle(Color.primary)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    Spacer()
                    StatusCapsulesView(region: $region, locationManager: locationManager)
                        .padding(.top, 8)
                    Spacer()
                    Button(action: { showSearchView = true }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .padding(15)
                            .foregroundStyle(Color.primary)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20),
            alignment: .top
        )
        
        // New overlay for NavigationStepsCardView (placed behind the status overlay)
                .overlay(
                    Group {
                        if showNavigationSteps {
                            NavigationStepsCardView(steps: navStepsVM.steps,
                                                    currentStepIndex: $currentNavStepIndex)
                                .onTapGesture {
                                    // Tapping the overlay toggles it off.
                                    withAnimation { showNavigationSteps = false }
                                }
                                .transition(.move(edge: .top))
                        }
                    }
                    .zIndex(1),
                    alignment: .top
                )
        // Sheets and onAppear handlers
        .sheet(isPresented: $showSearchView) {
            SearchView(searchText: $searchText,
                       isPresented: $showSearchView,
                       searchViewModel: searchViewModel,
                       region: $region,
                       userLocation: locationManager.location) { item in
                selectedMapItem = item
            }
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView(userFavorites: $userFavorites)
        }
        .onAppear { userFavorites = FavoritesStorage.loadFavorites() }
        .onChange(of: userFavorites) { newVal in FavoritesStorage.saveFavorites(newVal) }
        .onReceive(locationManager.$location) { newLoc in
            if !didSetInitialLocation, let loc = newLoc {
                region.center = loc.coordinate
                region.span = ContentView.defaultSpan
                didSetInitialLocation = true
            }
        }
        .onChange(of: showSearchView) { newValue in if newValue == false { region.span = ContentView.defaultSpan } }
        .onChange(of: showSettingsSheet) { newValue in if newValue == false { region.span = ContentView.defaultSpan } }
        .onChange(of: selectedMapItem) { newItem in
            // Reset the navigation overlay flag whenever a new destination is chosen.
            showNavigationSteps = false
            navStepsVM.calculateRouteSteps(from: locationManager.location, to: newItem)
        }
        .onChange(of: currentNavStepIndex) { newIndex in
            if navigationMode,
               navStepsVM.steps.indices.contains(newIndex) {
                // Update the map region to center on the coordinate for the new step.
                // **Adjust these values (span, etc.) for your desired camera effect:**
                region.center = navStepsVM.steps[newIndex].coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            }
        }
        // When navigation mode is toggled off, you can optionally reset the region.
        .onChange(of: showNavigationSteps) { newValue in
            if !newValue {
                // Optionally reset the region span when navigation overlay is dismissed.
                region.span = ContentView.defaultSpan
            }
        }
        .ignoresSafeArea(.all)
        .environmentObject(contactsManager)
    }
}

#Preview {
    ContentView()
}

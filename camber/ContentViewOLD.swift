////
////  ContentView.swift
////  YourApp
////
////  Created by You on 2023-XX-XX.
////
//
//import SwiftUI
//import MapKit
//import MediaPlayer
//import CoreLocation
//import WeatherKit
//import Combine
//
//// MARK: - Make CLLocationCoordinate2D Equatable
//extension CLLocationCoordinate2D: Equatable {
//    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
//        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
//    }
//}
//
///// Wraps CoreLocation to provide user's location & heading via @Published properties.
//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private let locationManager = CLLocationManager()
//    @Published var location: CLLocation?
//    @Published var heading: CLHeading?
//    
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        locationManager.startUpdatingHeading()
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locs: [CLLocation]) {
//        if let newLoc = locs.last {
//            self.location = newLoc
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        self.heading = newHeading
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Location manager error: \(error)")
//    }
//}
//
//// MARK: - Color <-> Hex
//extension Color {
//    func toHex() -> String {
//        let ui = UIColor(self)
//        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
//        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
//        return String(format: "#%02X%02X%02X%02X",
//                      Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
//    }
//    
//    static func fromHex(_ hex: String) -> Color {
//        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
//        guard let val = UInt64(cleaned, radix: 16) else { return .gray }
//        if cleaned.count == 8 {
//            let r = Double((val & 0xFF000000) >> 24) / 255
//            let g = Double((val & 0x00FF0000) >> 16) / 255
//            let b = Double((val & 0x0000FF00) >> 8) / 255
//            let a = Double(val & 0x000000FF) / 255
//            return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
//        } else if cleaned.count == 6 {
//            let r = Double((val & 0xFF0000) >> 16) / 255
//            let g = Double((val & 0x00FF00) >> 8) / 255
//            let b = Double(val & 0x0000FF) / 255
//            return Color(.sRGB, red: r, green: g, blue: b, opacity: 1)
//        }
//        return .gray
//    }
//}
//
//// MARK: - FavoriteItem & FavoritesStorage
//struct FavoriteItem: Identifiable, Codable, Equatable {
//    let id: UUID
//    var iconName: String
//    var label: String
//    var address: String?
//    var city: String?
//    var state: String?
//    
//    // New fields for route:
//    var latitude: Double?
//    var longitude: Double?
//    
//    var colorHex: String
//    var color: Color {
//        get { Color.fromHex(colorHex) }
//        set { colorHex = newValue.toHex() }
//    }
//    
//    init(id: UUID = UUID(),
//         iconName: String,
//         label: String,
//         address: String? = nil,
//         city: String? = nil,
//         state: String? = nil,
//         latitude: Double? = nil,
//         longitude: Double? = nil,
//         color: Color = .gray) {
//        self.id = id
//        self.iconName = iconName
//        self.label = label
//        self.address = address
//        self.city = city
//        self.state = state
//        self.latitude = latitude
//        self.longitude = longitude
//        self.colorHex = color.toHex()
//    }
//    
//    func toMapItem() -> MKMapItem? {
//        guard let lat = latitude, let lon = longitude else { return nil }
//        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//        let placemark = MKPlacemark(coordinate: coord)
//        let item = MKMapItem(placemark: placemark)
//        item.name = label
//        return item
//    }
//}
//
//class FavoritesStorage {
//    static let userDefaultsKey = "com.yourapp.userfavorites"
//    
//    static func loadFavorites() -> [FavoriteItem] {
//        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return [] }
//        do {
//            let decoded = try JSONDecoder().decode([FavoriteItem].self, from: data)
//            return decoded
//        } catch {
//            print("Failed to decode favorites:", error)
//            return []
//        }
//    }
//    
//    static func saveFavorites(_ items: [FavoriteItem]) {
//        do {
//            let data = try JSONEncoder().encode(items)
//            UserDefaults.standard.set(data, forKey: userDefaultsKey)
//        } catch {
//            print("Failed to encode favorites:", error)
//        }
//    }
//}
//
//// MARK: - WeatherManager using WeatherKit
//class WeatherManager: ObservableObject {
//    @Published var temperature: Double?
//    
//    private let weatherService = WeatherService()
//    private var lastFetchDate: Date?
//    private var lastCoordinate: CLLocationCoordinate2D?
//    
//    func updateTemperature(for coordinate: CLLocationCoordinate2D) {
//        let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        if let last = lastCoordinate {
//            let oldLocation = CLLocation(latitude: last.latitude, longitude: last.longitude)
//            if newLocation.distance(from: oldLocation) < 100 { return }
//        }
//        if let lastFetch = lastFetchDate, Date().timeIntervalSince(lastFetch) < 600 { return }
//        lastCoordinate = coordinate
//        lastFetchDate = Date()
//        Task {
//            do {
//                let weather = try await weatherService.weather(for: newLocation)
//                let fahrenheit = weather.currentWeather.temperature.converted(to: .fahrenheit).value
//                DispatchQueue.main.async { self.temperature = fahrenheit }
//            } catch {
//                print("WeatherKit error: \(error)")
//            }
//        }
//    }
//}
//
//// MARK: - CategoryItem
//struct CategoryItem {
//    let category: MKPointOfInterestCategory
//    let title: String
//    let iconName: String
//}
//
//// MARK: - Category Settings Structures
//struct CategorySetting: Codable, Identifiable, Equatable {
//    let id: String // use MKPointOfInterestCategory.rawValue
//    let title: String
//    var isOn: Bool
//}
//struct CategorySettingGroup: Codable, Identifiable, Equatable {
//    let id: String // use group name
//    var groupName: String
//    var groupColorHex: String
//    var categories: [CategorySetting]
//    
//    var groupColor: Color {
//        get { Color.fromHex(groupColorHex) }
//        set { groupColorHex = newValue.toHex() }
//    }
//}
//
//// Default category groups (adjust as needed)
//let defaultCategoryGroups: [CategorySettingGroup] = [
//    CategorySettingGroup(id: "Arts", groupName: "Arts & Culture", groupColorHex: Color.purple.toHex(), categories: [
//        CategorySetting(id: MKPointOfInterestCategory.museum.rawValue, title: "Museum", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.musicVenue.rawValue, title: "Music Venue", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.theater.rawValue, title: "Theater", isOn: true)
//    ]),
//    CategorySettingGroup(id: "Education", groupName: "Education", groupColorHex: Color.green.toHex(), categories: [
//        CategorySetting(id: MKPointOfInterestCategory.library.rawValue, title: "Library", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.planetarium.rawValue, title: "Planetarium", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.school.rawValue, title: "School", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.university.rawValue, title: "University", isOn: true)
//    ]),
//    CategorySettingGroup(id: "Entertainment", groupName: "Entertainment", groupColorHex: Color.red.toHex(), categories: [
//        CategorySetting(id: MKPointOfInterestCategory.movieTheater.rawValue, title: "Movie Theater", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.nightlife.rawValue, title: "Nightlife", isOn: true)
//    ]),
//    CategorySettingGroup(id: "Health", groupName: "Health & Safety", groupColorHex: Color.pink.toHex(), categories: [
//        CategorySetting(id: MKPointOfInterestCategory.fireStation.rawValue, title: "Fire Station", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.hospital.rawValue, title: "Hospital", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.pharmacy.rawValue, title: "Pharmacy", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.police.rawValue, title: "Police", isOn: true)
//    ]),
//    CategorySettingGroup(id: "Historical", groupName: "Historical & Cultural", groupColorHex: Color.brown.toHex(), categories: [
//        CategorySetting(id: MKPointOfInterestCategory.castle.rawValue, title: "Castle", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.fortress.rawValue, title: "Fortress", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.landmark.rawValue, title: "Landmark", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.nationalMonument.rawValue, title: "Monument", isOn: true)
//    ]),
//    CategorySettingGroup(id: "Food", groupName: "Food & Drink", groupColorHex: Color.orange.toHex(), categories: [
//        CategorySetting(id: MKPointOfInterestCategory.bakery.rawValue, title: "Bakery", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.brewery.rawValue, title: "Brewery", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.cafe.rawValue, title: "Cafe", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.distillery.rawValue, title: "Distillery", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.foodMarket.rawValue, title: "Food Market", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.restaurant.rawValue, title: "Restaurant", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.winery.rawValue, title: "Winery", isOn: true)
//    ]),
//    CategorySettingGroup(id: "Personal", groupName: "Personal Services", groupColorHex: Color.mint.toHex(), categories: [
//        CategorySetting(id: MKPointOfInterestCategory.animalService.rawValue, title: "Animal Service", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.atm.rawValue, title: "ATM", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.automotiveRepair.rawValue, title: "Auto Repair", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.bank.rawValue, title: "Bank", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.beauty.rawValue, title: "Beauty", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.evCharger.rawValue, title: "EV Charger", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.fitnessCenter.rawValue, title: "Fitness Center", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.laundry.rawValue, title: "Laundry", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.mailbox.rawValue, title: "Mailbox", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.postOffice.rawValue, title: "Post Office", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.restroom.rawValue, title: "Restroom", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.spa.rawValue, title: "Spa", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.store.rawValue, title: "Store", isOn: true)
//    ]),
//    CategorySettingGroup(id: "Parks", groupName: "Parks & Recreation", groupColorHex: Color.teal.toHex(), categories: [
//        CategorySetting(id: MKPointOfInterestCategory.amusementPark.rawValue, title: "Amusement Park", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.aquarium.rawValue, title: "Aquarium", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.beach.rawValue, title: "Beach", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.campground.rawValue, title: "Campground", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.fairground.rawValue, title: "Fairground", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.marina.rawValue, title: "Marina", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.nationalPark.rawValue, title: "National Park", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.park.rawValue, title: "Park", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.rvPark.rawValue, title: "RV Park", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.zoo.rawValue, title: "Zoo", isOn: true)
//    ]),
//    CategorySettingGroup(id: "Sports", groupName: "Sports", groupColorHex: Color.indigo.toHex(), categories: [
//        CategorySetting(id: MKPointOfInterestCategory.baseball.rawValue, title: "Baseball", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.basketball.rawValue, title: "Basketball", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.bowling.rawValue, title: "Bowling", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.goKart.rawValue, title: "Go Kart", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.golf.rawValue, title: "Golf", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.hiking.rawValue, title: "Hiking", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.miniGolf.rawValue, title: "Mini Golf", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.rockClimbing.rawValue, title: "Rock Climbing", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.skatePark.rawValue, title: "Skate Park", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.skating.rawValue, title: "Skating", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.skiing.rawValue, title: "Skiing", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.soccer.rawValue, title: "Soccer", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.stadium.rawValue, title: "Stadium", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.tennis.rawValue, title: "Tennis", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.volleyball.rawValue, title: "Volleyball", isOn: true)
//    ]),
//    CategorySettingGroup(id: "Travel", groupName: "Travel", groupColorHex: Color.cyan.toHex(), categories: [
//        CategorySetting(id: MKPointOfInterestCategory.airport.rawValue, title: "Airport", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.carRental.rawValue, title: "Car Rental", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.conventionCenter.rawValue, title: "Convention Center", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.gasStation.rawValue, title: "Gas Station", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.hotel.rawValue, title: "Hotel", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.parking.rawValue, title: "Parking", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.publicTransport.rawValue, title: "Public Transport", isOn: true)
//    ]),
//    CategorySettingGroup(id: "Water", groupName: "Water Sports", groupColorHex: Color.blue.toHex(), categories: [
//        CategorySetting(id: MKPointOfInterestCategory.fishing.rawValue, title: "Fishing", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.kayaking.rawValue, title: "Kayaking", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.surfing.rawValue, title: "Surfing", isOn: true),
//        CategorySetting(id: MKPointOfInterestCategory.swimming.rawValue, title: "Swimming", isOn: true)
//    ])
//]
//
//// MARK: - ManageCategoriesView
//struct ManageCategoriesView: View {
//    @State private var categoryGroups: [CategorySettingGroup] = CategorySettingsStorage.load() ?? defaultCategoryGroups
//    
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach($categoryGroups) { $group in
//                    Section(header: CategoryGroupHeaderView(group: $group)) {
//                        ForEach($group.categories) { $cat in
//                            Toggle(isOn: $cat.isOn) {
//                                Text(cat.title)
//                            }
//                        }
//                    }
//                }
//            }
//            .listStyle(InsetGroupedListStyle())
//            .navigationTitle("Manage Categories")
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Save") {
//                        CategorySettingsStorage.save(categoryGroups)
//                    }
//                }
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Done") {
//                        // Dismiss if needed.
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - CategoryGroupHeaderView
//struct CategoryGroupHeaderView: View {
//    @Binding var group: CategorySettingGroup
//    @State private var showColorPicker = false
//    
//    var body: some View {
//        HStack {
//            Button {
//                showColorPicker.toggle()
//            } label: {
//                Circle()
//                    .fill(group.groupColor)
//                    .frame(width: 24, height: 24)
//            }
//            .popover(isPresented: $showColorPicker) {
//                ColorPicker("Pick a color", selection: $group.groupColor)
//                    .padding()
//            }
//            Text(group.groupName)
//                .font(.headline)
//        }
//    }
//}
//
//// MARK: - CategorySettingsStorage
//struct CategorySettingsStorage {
//    static let key = "com.yourapp.categorysettings"
//    
//    static func save(_ groups: [CategorySettingGroup]) {
//        do {
//            let data = try JSONEncoder().encode(groups)
//            UserDefaults.standard.set(data, forKey: key)
//        } catch {
//            print("Failed to encode category settings:", error)
//        }
//    }
//    
//    static func load() -> [CategorySettingGroup]? {
//        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
//        do {
//            let groups = try JSONDecoder().decode([CategorySettingGroup].self, from: data)
//            return groups
//        } catch {
//            print("Failed to decode category settings:", error)
//            return nil
//        }
//    }
//}
//
//// MARK: - ContentView
//struct ContentView: View {
//    // Use a static constant for defaultSpan to avoid initialization errors.
//    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//    
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
//        span: ContentView.defaultSpan
//    )
//    @State private var didSetInitialLocation = false
//    @State private var searchText: String = ""
//    @State private var showSearchView = false
//    @State private var showPlaylistSelector = false
//    @StateObject private var locationManager = LocationManager()
//    @State private var selectedMapItem: MKMapItem? = nil
//    @StateObject private var searchViewModel = MapSearchViewModel()
//    @StateObject private var musicLibraryViewModel = MusicLibraryViewModel()
//    @StateObject private var musicPlayerViewModel = MusicPlayerViewModel()
//    @State private var showFavoritesBar = false
//    @State private var showCategoryBar = false
//    @State private var showSettingsSheet = false
//    @StateObject private var navStepsVM = NavigationStepsViewModel()
//    @StateObject private var contactsManager = ContactsManager()
//    @State private var categorySettings: [CategorySettingGroup] = CategorySettingsStorage.load() ?? defaultCategoryGroups
//    @State private var userFavorites: [FavoriteItem] = []
//    // Dynamic allowed categories for filtering map pins.
//    @State private var allowedCategories: [MKPointOfInterestCategory] = [
//        .bakery, .brewery, .cafe, .foodMarket, .restaurant, .winery,
//        .zoo, .amusementPark, .campground, .atm, .bank, .museum,
//        .theater, .park, .gasStation, .beach, .nationalPark, .landmark,
//        .musicVenue, .fairground, .aquarium, .castle, .fortress
//    ]
//    
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            // Map & Music area
//            VStack(spacing: 0) {
//                CompassMapView(region: $region,
//                                userLocation: locationManager.location,
//                                heading: locationManager.heading?.trueHeading,
//                                selectedItem: $selectedMapItem,
//                                allowedCategories: $allowedCategories)
//                    .frame(maxHeight: .infinity)
//                    .clipShape(RoundedCorner(radius: 25, corners: [.bottomLeft, .bottomRight]))
//                    .zIndex(1)
//                MusicControlView(showPlaylistSelector: $showPlaylistSelector)
//                    .environmentObject(musicPlayerViewModel)
//                    .environmentObject(musicLibraryViewModel)
//                    .frame(height: 225)
//                    .offset(y:-25)
//                    .zIndex(0)
//            }
//            
//            // Profile icon (top–leading)
//            .overlay(
//                VStack {
//                    HStack {
//                        Button {
//                            showSettingsSheet = true
//                        } label: {
//                            Image(systemName: "person.crop.circle")
//                                .font(.title3)
//                                .padding(15)
//                                .foregroundStyle(Color.primary)
//                                .background(.ultraThinMaterial)
//                                .clipShape(Circle())
//                                .shadow(radius: 4)
//                        }
//                        Spacer()
//                    }
//                    Spacer()
//                }
//                .padding(.leading)
//                .padding(.top, 50),
//                alignment: .topLeading
//            )
//            
//            // Search icon (top–trailing)
//            .overlay(
//                VStack {
//                    HStack {
//                        Spacer()
//                        Button {
//                            showSearchView = true
//                        } label: {
//                            Image(systemName: "magnifyingglass")
//                                .font(.title3)
//                                .padding(15)
//                                .foregroundStyle(Color.primary)
//                                .background(.ultraThinMaterial)
//                                .clipShape(Circle())
//                                .shadow(radius: 4)
//                        }
//                    }
//                    Spacer()
//                }
//                .padding(.trailing)
//                .padding(.top, 50),
//                alignment: .topTrailing
//            )
//            
//            // Status Capsules at top center.
//            .overlay(
//                StatusCapsulesView(region: $region, locationManager: locationManager)
//                    .padding(.top, 60)
//                    .padding(.horizontal, 70),
//                alignment: .top
//            )
//            // Navigation Steps
//            .overlay(
//                NavigationStepsCardView(steps: navStepsVM.steps)
//                    .padding(.top, 120), // Adjust this value as needed.
//                alignment: .top
//            )
//            
//            .overlay(
//                ContactBar()
//                    .padding(.trailing, 16)
//                    .padding(.bottom, 420), // Adjust this value to position it as desired.
//                alignment: .bottomTrailing
//            )
//            // Category bar (above favorites bar)
//            .overlay(
//                CategoryBar(showCategories: $showCategoryBar,
//                            allowedCategories: $allowedCategories,
//                            categorySettings: $categorySettings)
//                    .padding(.trailing, 16)
//                    .padding(.bottom, 330),
//                alignment: .bottomTrailing
//            )
//            
//            // Favorites bar
//            .overlay(
//                FavoriteDestinationBar(showFavorites: $showFavoritesBar,
//                                       userFavorites: $userFavorites) { mkItem in
//                    selectedMapItem = mkItem
//                }
//                .padding(.trailing, 16)
//                .padding(.bottom, 240),
//                alignment: .bottomTrailing
//            )
//            
//            // Music Section Controller
//            .overlay(
//                Button(action: { showPlaylistSelector.toggle() }) {
//                    Image(systemName: showPlaylistSelector ? "folder.circle" : "playpause.circle")
//                        .offset(x: -15)
//                        .font(.title2)
//                        .padding(.vertical, 20)
//                        .padding(.horizontal, 25)
//                        .foregroundStyle(Color.white)
//                        .background(Color.pink.opacity(0.8))
//                        .clipShape(RoundedRectangle(cornerRadius: 15))
//                        .shadow(radius: 4)
//                }
//                .offset(x: 50) // extra 5px down; x offset of 20px.
//                .padding(.trailing, 16)
//                .padding(.bottom, 160) // Adjust this value to position it under the Favorite Bar.
//                .zIndex(2),
//                alignment: .bottomTrailing
//            )
//            
//            // Selected item card (if any)
//            if let dest = selectedMapItem {
//                SelectedItemCard(mapItem: dest, userLocation: locationManager.location) {
//                    selectedMapItem = nil
//                }
//                .padding(.bottom, 240)
//                .transition(.move(edge: .bottom))
//                .animation(.spring(), value: selectedMapItem)
//            }
//        }
//        .sheet(isPresented: $showSearchView) {
//            SearchView(searchText: $searchText,
//                       isPresented: $showSearchView,
//                       searchViewModel: searchViewModel,
//                       region: $region,
//                       userLocation: locationManager.location) { item in
//                selectedMapItem = item
//            }
//        }
//        .sheet(isPresented: $showSettingsSheet) {
//            SettingsView(userFavorites: $userFavorites)
//        }
//        .onAppear { userFavorites = FavoritesStorage.loadFavorites() }
//        .onChange(of: userFavorites) { newVal in FavoritesStorage.saveFavorites(newVal) }
//        .onReceive(locationManager.$location) { newLoc in
//            if !didSetInitialLocation, let loc = newLoc {
//                region.center = loc.coordinate
//                region.span = ContentView.defaultSpan
//                didSetInitialLocation = true
//            }
//        }
//        .onChange(of: showSearchView) { newValue in if newValue == false { region.span = ContentView.defaultSpan } }
//        .onChange(of: showSettingsSheet) { newValue in if newValue == false { region.span = ContentView.defaultSpan } }
//        .onChange(of: selectedMapItem) { newItem in
//            navStepsVM.calculateRouteSteps(from: locationManager.location, to: newItem)
//        }
//        .ignoresSafeArea(.all)
//        .environmentObject(contactsManager)
//    }
//}
//
//struct ContactBar: View {
//    @State private var showContacts: Bool = false
//    @EnvironmentObject var contactsManager: ContactsManager
//    
//    private let expandedWidth = UIScreen.main.bounds.width - 30
//    private let expandedHeight: CGFloat = 76
//    
//    var body: some View {
//        if showContacts {
//            HStack(spacing: 12) {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 16) {
//                        ForEach(contactsManager.contacts) { contact in
//                            Button(action: {
//                                if let url = URL(string: "tel://\(contact.phoneNumber)"),
//                                   UIApplication.shared.canOpenURL(url) {
//                                    UIApplication.shared.open(url)
//                                }
//                            }) {
//                                VStack {
//                                    Circle()
//                                        .fill(Color.purple)
//                                        .frame(width: 50, height: 50)
//                                        .overlay(
//                                            Text(String(contact.firstName.prefix(1)))
//                                                .font(.headline)
//                                                .foregroundColor(.white)
//                                        )
//                                    Text(contact.firstName)
//                                        .font(.caption)
//                                        .foregroundColor(.white)
//                                }
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 4)
//                }
//                Spacer(minLength: 8)
//                Button(action: {
//                    withAnimation { showContacts.toggle() }
//                }) {
//                    Image(systemName: "xmark")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding(15)
//                        .background(Color.red)
//                        .clipShape(RoundedRectangle(cornerRadius: 15))
//                        .shadow(radius: 4)
//                }
//            }
//            .padding(.vertical, 10)
//            .padding(.horizontal, 12)
//            .frame(width: expandedWidth, height: expandedHeight)
//            .background(.ultraThinMaterial)
//            .clipShape(RoundedRectangle(cornerRadius: 15))
//            .shadow(radius: 4)
//            .transition(.move(edge: .trailing))
//        } else {
//            Button(action: {
//                withAnimation { showContacts.toggle() }
//            }) {
//                Image(systemName: "phone.circle")
//                    .offset(x: -15)
//                    .font(.title2)
//                    .padding(25)
//                    .foregroundStyle(Color.white)
//                    .background(Color.purple.opacity(0.8))
//                    .clipShape(RoundedRectangle(cornerRadius: 15))
//                    .shadow(radius: 4)
//            }
//            .offset(x: 50)
//        }
//    }
//}
//
///// A UIViewRepresentable that shows the map, routes, and pins.
//struct CompassMapView: UIViewRepresentable {
//    @Binding var region: MKCoordinateRegion
//    var userLocation: CLLocation?
//    var heading: CLLocationDirection?
//    @Binding var selectedItem: MKMapItem?
//    @Binding var allowedCategories: [MKPointOfInterestCategory]
//    
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        
//        // Show user location and force tracking mode to follow heading.
//        mapView.showsUserLocation = true
//        mapView.setUserTrackingMode(.follow, animated: false)
//        
//        // Hide the default compass.
//        mapView.showsCompass = false
//        
//        // Create and add a custom compass button.
//        let compassButton = MKCompassButton(mapView: mapView)
//        compassButton.compassVisibility = .visible
//        // Disable autoresizing mask to use Auto Layout.
//        compassButton.translatesAutoresizingMaskIntoConstraints = false
//        mapView.addSubview(compassButton)
//        NSLayoutConstraint.activate([
//            // Position the compass button 80 points from the top
//            // and 16 points from the trailing edge.
//            compassButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 120),
//            compassButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20)
//        ])
//        
//        mapView.isRotateEnabled = true
//        mapView.showsTraffic = true
//        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: allowedCategories)
//        
//        return mapView
//    }
//    
//    func updateUIView(_ mapView: MKMapView, context: Context) {
//        context.coordinator.updateRoute(on: mapView,
//                                        userLoc: userLocation,
//                                        selectedItem: selectedItem)
//        if let heading = heading {
//            var camera = mapView.camera
//            camera.heading = heading
//            mapView.setCamera(camera, animated: true)
//        }
//        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: allowedCategories)
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: CompassMapView
//        private var lastSelectedItem: MKMapItem? = nil
//        private var currentOverlay: MKOverlay?
//        private var destinationAnnotation: MKPointAnnotation?
//        
//        init(_ parent: CompassMapView) {
//            self.parent = parent
//        }
//        
//        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//            DispatchQueue.main.async { self.parent.region = mapView.region }
//        }
//        
//        func updateRoute(on mapView: MKMapView,
//                         userLoc: CLLocation?,
//                         selectedItem: MKMapItem?) {
//            if userLoc == nil || selectedItem == nil {
//                removeOverlayAndPin(from: mapView)
//                return
//            }
//            if selectedItem == lastSelectedItem { return }
//            lastSelectedItem = selectedItem
//            removeOverlayAndPin(from: mapView)
//            let ann = MKPointAnnotation()
//            ann.coordinate = selectedItem!.placemark.coordinate
//            ann.title = selectedItem!.name
//            destinationAnnotation = ann
//            mapView.addAnnotation(ann)
//            let req = MKDirections.Request()
//            let userPL = MKPlacemark(coordinate: userLoc!.coordinate)
//            req.source = MKMapItem(placemark: userPL)
//            req.destination = selectedItem
//            req.transportType = .automobile
//            MKDirections(request: req).calculate { [weak self] resp, error in
//                guard let self = self else { return }
//                if let route = resp?.routes.first {
//                    DispatchQueue.main.async {
//                        mapView.addOverlay(route.polyline)
//                        self.currentOverlay = route.polyline
//                        self.fitAndCenterRoute(route, on: mapView)
//                    }
//                }
//            }
//        }
//        
//        private func removeOverlayAndPin(from mapView: MKMapView) {
//            if let ov = currentOverlay { mapView.removeOverlay(ov); currentOverlay = nil }
//            if let ann = destinationAnnotation { mapView.removeAnnotation(ann); destinationAnnotation = nil }
//        }
//        
//        private func fitAndCenterRoute(_ route: MKRoute, on mapView: MKMapView) {
//            let rect = route.polyline.boundingMapRect
//            let insets = UIEdgeInsets(top: 60, left: 60, bottom: 300, right: 60)
//            mapView.setVisibleMapRect(rect, edgePadding: insets, animated: false)
//            let newAltitude = mapView.camera.altitude
//            let midpoint = findHalfwayCoordinate(route: route)
//            let cam = MKMapCamera(lookingAtCenter: midpoint,
//                                  fromDistance: newAltitude,
//                                  pitch: 0,
//                                  heading: 0)
//            mapView.setCamera(cam, animated: true)
//        }
//        
//        private func findHalfwayCoordinate(route: MKRoute) -> CLLocationCoordinate2D {
//            let total = route.distance, half = total / 2.0
//            let pts = route.polyline.points(), cnt = route.polyline.pointCount
//            var distSoFar = 0.0
//            for i in 0..<(cnt - 1) {
//                let p1 = pts[i], p2 = pts[i+1]
//                let segDist = p1.distance(to: p2)
//                if distSoFar + segDist >= half {
//                    let fraction = (half - distSoFar) / segDist
//                    let x = p1.x + fraction*(p2.x - p1.x)
//                    let y = p1.y + fraction*(p2.y - p1.y)
//                    return MKMapPoint(x: x, y: y).coordinate
//                }
//                distSoFar += segDist
//            }
//            return pts[cnt-1].coordinate
//        }
//        
//        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//            if let poly = overlay as? MKPolyline {
//                let rend = MKPolylineRenderer(polyline: poly)
//                rend.strokeColor = .blue
//                rend.lineWidth = 5
//                return rend
//            }
//            return MKOverlayRenderer(overlay: overlay)
//        }
//        
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            if annotation is MKUserLocation { return nil }
//            let rid = "TrafficDestPin"
//            var pin = mapView.dequeueReusableAnnotationView(withIdentifier: rid) as? MKPinAnnotationView
//            if pin == nil {
//                pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: rid)
//                pin!.canShowCallout = true
//                pin!.pinTintColor = .red
//            } else { pin!.annotation = annotation }
//            return pin
//        }
//    }
//}
//
//class NavigationStepsViewModel: ObservableObject {
//    @Published var steps: [NavigationStep] = []
//    
//    func calculateRouteSteps(from userLocation: CLLocation?, to destination: MKMapItem?) {
//        guard let userLocation = userLocation, let destination = destination else {
//            self.steps = []
//            return
//        }
//        
//        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
//        request.destination = destination
//        request.transportType = .automobile
//        
//        let directions = MKDirections(request: request)
//        directions.calculate { [weak self] response, error in
//            if let route = response?.routes.first {
//                // Filter out steps with empty instructions and then map to NavigationStep.
//                let navSteps: [NavigationStep] = route.steps.filter { !$0.instructions.isEmpty }
//                    .map { step in
//                        let arrow = self?.arrowIcon(for: step) ?? "arrow.forward"
//                        let distance = String(format: "%.1f mi", step.distance / 1609.34)
//                        let street = self?.streetName(for: step.instructions) ?? step.instructions
//                        return NavigationStep(arrowIcon: arrow, distance: distance, streetName: street)
//                    }
//                DispatchQueue.main.async {
//                    self?.steps = navSteps
//                }
//            }
//        }
//    }
//    
//    private func arrowIcon(for step: MKRoute.Step) -> String {
//        let ins = step.instructions.lowercased()
//        if ins.contains("left") { return "arrow.turn.up.left" }
//        if ins.contains("right") { return "arrow.turn.up.right" }
//        return "arrow.up"
//    }
//    
//    private func streetName(for instructions: String) -> String {
//        if let range = instructions.lowercased().range(of: "onto ") {
//            let after = instructions[range.upperBound...]
//            return String(after).capitalized
//        }
//        return instructions
//    }
//}
//
//// A simple model to hold data for each navigation step.
//struct NavigationStep {
//    let arrowIcon: String  // e.g. "arrow.turn.right.up"
//    let distance: String   // e.g. "2.4 mi"
//    let streetName: String // e.g. "North Wells Street"
//}
//
//struct NavigationStepsCardView: View {
//    let steps: [NavigationStep]
//    @State private var currentStepIndex: Int = 0
//    private let cardHeight: CGFloat = 160
//    
//    var body: some View {
//        if steps.isEmpty {
//            EmptyView()
//        } else {
//            ZStack(alignment: .topTrailing) {
//                HStack(spacing: 0) {
//                    Image(systemName: steps[currentStepIndex].arrowIcon)
//                        .font(.system(size: 24, weight: .bold))
//                        .foregroundColor(.white)
//                        .padding(12)
//                        .background(Color.blue)
//                        .clipShape(Circle())
//                    
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(steps[currentStepIndex].distance)
//                            .font(.headline)
//                            .foregroundColor(.white)
//                        Text(steps[currentStepIndex].streetName)
//                            .font(.subheadline)
//                            .foregroundColor(.white)
//                    }
//                    .padding(.leading, 12)
//                    Spacer()
//                }
//                .padding(.horizontal)
//                .padding(.vertical, 8)
//                .frame(height: cardHeight)
//                .background(Color.black)
//                .cornerRadius(40)
//                .shadow(color: Color.black.opacity(0.8), radius: 12, x: 0, y: 6)
//                
//                HStack {
//                    Button(action: {
//                        if currentStepIndex > 0 {
//                            currentStepIndex -= 1
//                        }
//                    }) {
//                        Image(systemName: "chevron.left.circle.fill")
//                            .font(.title)
//                            .foregroundColor(.white)
//                    }
//                    Spacer()
//                    Button(action: {
//                        if currentStepIndex < steps.count - 1 {
//                            currentStepIndex += 1
//                        }
//                    }) {
//                        Image(systemName: "chevron.right.circle.fill")
//                            .font(.title)
//                            .foregroundColor(.white)
//                    }
//                }
//                .padding(.horizontal, 16)
//                .padding(.bottom, 8)
//                .frame(maxHeight: cardHeight, alignment: .bottom)
//            }
//            .padding(.horizontal, 10)
//            .offset(y: -110)
//        }
//    }
//}
//
//struct FavoriteDestinationBar: View {
//    @Binding var showFavorites: Bool
//    @Binding var userFavorites: [FavoriteItem]
//    
//    let onSelectFavorite: (MKMapItem) -> Void
//    
//    private let expandedWidth = UIScreen.main.bounds.width - 30
//    private let expandedHeight: CGFloat = 76
//    
//    var body: some View {
//        if showFavorites {
//            HStack(spacing: 12) {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 16) {
//                        if let home = userFavorites.first(where: { $0.label == "Home" }) {
//                            FavoriteButton(fav: home, fallbackIcon: "house.fill", fallbackColor: .blue)
//                        } else {
//                            FavoriteButton(fav: nil, fallbackIcon: "house.fill", fallbackColor: .blue)
//                        }
//                        if let work = userFavorites.first(where: { $0.label == "Work" }) {
//                            FavoriteButton(fav: work, fallbackIcon: "briefcase.fill", fallbackColor: .brown)
//                        } else {
//                            FavoriteButton(fav: nil, fallbackIcon: "briefcase.fill", fallbackColor: .brown)
//                        }
//                        ForEach(userFavorites.filter { $0.label != "Home" && $0.label != "Work" }, id: \.id) { fav in
//                            FavoriteButton(fav: fav, fallbackIcon: nil, fallbackColor: .gray)
//                        }
//                    }
//                    .padding(.horizontal, 4)
//                }
//                Spacer(minLength: 8)
//                Button {
//                    withAnimation {
//                        showFavorites = false
//                    }
//                } label: {
//                    Image(systemName: "xmark")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding(15)
//                        .background(.red)
//                        .clipShape(RoundedRectangle(cornerRadius: 15))
//                        .shadow(radius: 4)
//                }
//            }
//            .padding(.vertical, 10)
//            .padding(.horizontal, 12)
//            .frame(width: expandedWidth, height: expandedHeight)
//            .background(.ultraThinMaterial)
//            .clipShape(RoundedRectangle(cornerRadius: 15))
//            .shadow(radius: 4)
//            .transition(.move(edge: .trailing))
//        } else {
//            Button {
//                withAnimation {
//                    showFavorites = true
//                }
//            } label: {
//                Image(systemName: "star.circle")
//                    .offset(x: -15)
//                    .font(.title2)
//                    .padding(25)
//                    .foregroundStyle(Color.white)
//                    .background(Color.yellow.opacity(0.8))
//                    .clipShape(RoundedRectangle(cornerRadius: 15))
//                    .shadow(radius: 4)
//            }
//            .offset(x: 50)
//        }
//    }
//    
//    @ViewBuilder
//    private func FavoriteButton(fav: FavoriteItem?, fallbackIcon: String?, fallbackColor: Color) -> some View {
//        Button {
//            if let item = fav?.toMapItem() {
//                onSelectFavorite(item)
//            }
//        } label: {
//            if let f = fav {
//                DestinationCircleIcon(systemName: f.iconName, label: f.label, color: f.color)
//            } else if let fallbackIcon = fallbackIcon {
//                DestinationCircleIcon(systemName: fallbackIcon, label: "Set Address", color: fallbackColor)
//            }
//        }
//    }
//}
//// MARK: - Updated Category Bar and Button
//// Global default icon mapping:
//let defaultCategoryIcons: [String: String] = [
//    MKPointOfInterestCategory.museum.rawValue: "building.columns",
//    MKPointOfInterestCategory.musicVenue.rawValue: "music.mic",
//    MKPointOfInterestCategory.theater.rawValue: "theatermasks.fill",
//    MKPointOfInterestCategory.library.rawValue: "books.vertical.fill",
//    MKPointOfInterestCategory.planetarium.rawValue: "moon.stars.fill",
//    MKPointOfInterestCategory.school.rawValue: "graduationcap.fill",
//    MKPointOfInterestCategory.university.rawValue: "building.columns",
//    MKPointOfInterestCategory.movieTheater.rawValue: "film.fill",
//    MKPointOfInterestCategory.nightlife.rawValue: "sparkles",
//    MKPointOfInterestCategory.fireStation.rawValue: "flame.fill",
//    MKPointOfInterestCategory.hospital.rawValue: "cross.case.fill",
//    MKPointOfInterestCategory.pharmacy.rawValue: "pills.fill",
//    MKPointOfInterestCategory.police.rawValue: "shield.fill",
//    MKPointOfInterestCategory.castle.rawValue: "building.columns",
//    MKPointOfInterestCategory.fortress.rawValue: "lock.shield.fill",
//    MKPointOfInterestCategory.landmark.rawValue: "mappin.and.ellipse",
//    MKPointOfInterestCategory.nationalMonument.rawValue: "building",
//    MKPointOfInterestCategory.bakery.rawValue: "birthday.cake.fill",
//    MKPointOfInterestCategory.brewery.rawValue: "mug.fill",
//    MKPointOfInterestCategory.cafe.rawValue: "cup.and.saucer.fill",
//    MKPointOfInterestCategory.distillery.rawValue: "drop.fill",
//    MKPointOfInterestCategory.foodMarket.rawValue: "cart.fill",
//    MKPointOfInterestCategory.restaurant.rawValue: "fork.knife",
//    MKPointOfInterestCategory.winery.rawValue: "wineglass.fill",
//    MKPointOfInterestCategory.animalService.rawValue: "pawprint.fill",
//    MKPointOfInterestCategory.atm.rawValue: "banknote.fill",
//    MKPointOfInterestCategory.automotiveRepair.rawValue: "wrench.and.screwdriver.fill",
//    MKPointOfInterestCategory.bank.rawValue: "dollarsign.circle.fill",
//    MKPointOfInterestCategory.beauty.rawValue: "heart.circle.fill",
//    MKPointOfInterestCategory.evCharger.rawValue: "bolt.car.fill",
//    MKPointOfInterestCategory.fitnessCenter.rawValue: "figure.walk",
//    MKPointOfInterestCategory.laundry.rawValue: "drop.fill",
//    MKPointOfInterestCategory.mailbox.rawValue: "mail.fill",
//    MKPointOfInterestCategory.postOffice.rawValue: "envelope.fill",
//    MKPointOfInterestCategory.restroom.rawValue: "person.fill",
//    MKPointOfInterestCategory.spa.rawValue: "leaf.fill",
//    MKPointOfInterestCategory.store.rawValue: "bag.fill",
//    MKPointOfInterestCategory.amusementPark.rawValue: "sparkles",
//    MKPointOfInterestCategory.aquarium.rawValue: "fish.fill",
//    MKPointOfInterestCategory.beach.rawValue: "sun.max.fill",
//    MKPointOfInterestCategory.campground.rawValue: "tent.fill",
//    MKPointOfInterestCategory.fairground.rawValue: "ticket.fill",
//    MKPointOfInterestCategory.marina.rawValue: "ferry.fill",
//    MKPointOfInterestCategory.nationalPark.rawValue: "leaf.fill",
//    MKPointOfInterestCategory.park.rawValue: "tree.fill",
//    MKPointOfInterestCategory.rvPark.rawValue: "car.fill",
//    MKPointOfInterestCategory.zoo.rawValue: "pawprint.fill",
//    MKPointOfInterestCategory.baseball.rawValue: "sportscourt",
//    MKPointOfInterestCategory.basketball.rawValue: "sportscourt",
//    MKPointOfInterestCategory.bowling.rawValue: "sportscourt",
//    MKPointOfInterestCategory.goKart.rawValue: "car.fill",
//    MKPointOfInterestCategory.golf.rawValue: "sportscourt",
//    MKPointOfInterestCategory.hiking.rawValue: "figure.walk",
//    MKPointOfInterestCategory.miniGolf.rawValue: "figure.walk",
//    MKPointOfInterestCategory.rockClimbing.rawValue: "figure.climbing",
//    MKPointOfInterestCategory.skatePark.rawValue: "figure.walk",
//    MKPointOfInterestCategory.skating.rawValue: "figure.walk",
//    MKPointOfInterestCategory.skiing.rawValue: "figure.skiing.downhill",
//    MKPointOfInterestCategory.soccer.rawValue: "sportscourt",
//    MKPointOfInterestCategory.stadium.rawValue: "sportscourt",
//    MKPointOfInterestCategory.tennis.rawValue: "tennis.racket",
//    MKPointOfInterestCategory.volleyball.rawValue: "sportscourt",
//    MKPointOfInterestCategory.airport.rawValue: "airplane",
//    MKPointOfInterestCategory.carRental.rawValue: "car.fill",
//    MKPointOfInterestCategory.conventionCenter.rawValue: "building.2.fill",
//    MKPointOfInterestCategory.gasStation.rawValue: "fuelpump.fill",
//    MKPointOfInterestCategory.hotel.rawValue: "bed.double.fill",
//    MKPointOfInterestCategory.parking.rawValue: "parkingsign.circle.fill",
//    MKPointOfInterestCategory.publicTransport.rawValue: "bus.fill",
//    MKPointOfInterestCategory.fishing.rawValue: "fish.fill",
//    MKPointOfInterestCategory.kayaking.rawValue: "sailboat.fill",
//    MKPointOfInterestCategory.surfing.rawValue: "wave.3.forward",
//    MKPointOfInterestCategory.swimming.rawValue: "figure.skiing.downhill"
//]
//
//// MARK: - Updated Category Bar and Category Button
//struct CategoryBar: View {
//    @Binding var showCategories: Bool
//    @Binding var allowedCategories: [MKPointOfInterestCategory]
//    @Binding var categorySettings: [CategorySettingGroup]
//    
//    private let expandedWidth = UIScreen.main.bounds.width - 30
//    private let expandedHeight: CGFloat = 76
//    
//    // Compute active categories from the category settings (only toggled on)
//    var activeCategories: [CategoryItem] {
//        var items: [CategoryItem] = []
//        for group in categorySettings {
//            for cat in group.categories {
//                if cat.isOn {
//                    let poiCategory = MKPointOfInterestCategory(rawValue: cat.id)
//                    let icon = defaultCategoryIcons[cat.id] ?? "questionmark.circle"
//                    items.append(CategoryItem(category: poiCategory, title: cat.title, iconName: icon))
//                }
//            }
//        }
//        return items
//    }
//    
//    var body: some View {
//        if showCategories {
//            HStack(spacing: 12) {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 16) {
//                        ForEach(activeCategories, id: \.title) { cat in
//                            // Pass the group color for this category from the settings.
//                            CategoryButton(categoryItem: cat, groupColor: groupColor(for: cat), allowedCategories: $allowedCategories)
//                        }
//                    }
//                    .padding(.horizontal, 4)
//                }
//                Spacer(minLength: 8)
//                Button {
//                    withAnimation {
//                        showCategories = false
//                    }
//                } label: {
//                    Image(systemName: "xmark")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding(15)
//                        .background(Color.red)
//                        .clipShape(RoundedRectangle(cornerRadius: 15))
//                        .shadow(radius: 4)
//                }
//            }
//            .padding(.vertical, 10)
//            .padding(.horizontal, 12)
//            .frame(width: expandedWidth, height: expandedHeight)
//            .background(.ultraThinMaterial)
//            .clipShape(RoundedRectangle(cornerRadius: 15))
//            .shadow(radius: 4)
//            .transition(.move(edge: .trailing))
//        } else {
//            Button {
//                withAnimation {
//                    showCategories = true
//                }
//            } label: {
//                Image(systemName: "circle.hexagongrid.circle")
//                    .offset(x: -15)
//                    .font(.title2)
//                    .padding(25)
//                    .foregroundStyle(Color.white)
//                    .background(Color.blue.opacity(0.8))
//                    .clipShape(RoundedRectangle(cornerRadius: 15))
//                    .shadow(radius: 4)
//            }
//            .offset(x: 50)
//        }
//    }
//    
//    // Helper: return the group color for a given category by checking the settings.
//    func groupColor(for categoryItem: CategoryItem) -> Color {
//        for group in categorySettings {
//            if group.categories.contains(where: { $0.id == categoryItem.category.rawValue && $0.isOn }) {
//                return group.groupColor
//            }
//        }
//        return .gray
//    }
//}
//
//struct CategoryButton: View {
//    let categoryItem: CategoryItem
//    let groupColor: Color
//    @Binding var allowedCategories: [MKPointOfInterestCategory]
//    
//    var body: some View {
//        Button {
//            if isAllowed() {
//                allowedCategories.removeAll { $0 == categoryItem.category }
//                print("Toggled OFF map filter for: \(categoryItem.title)")
//            } else {
//                allowedCategories.append(categoryItem.category)
//                print("Toggled ON map filter for: \(categoryItem.title)")
//            }
//        } label: {
//            VStack(spacing: 4) {
//                Circle()
//                    .fill(isAllowed() ? groupColor : groupColor.opacity(0.5))
//                    .frame(width: 40, height: 40)
//                    .overlay(
//                        Image(systemName: categoryItem.iconName)
//                            .font(.headline)
//                            .foregroundColor(.white)
//                    )
//                Text(categoryItem.title)
//                    .font(.caption2)
//                    .foregroundColor(.primary)
//            }
//        }
//    }
//    
//    func isAllowed() -> Bool {
//        allowedCategories.contains(categoryItem.category)
//    }
//    
//    func getGroupColor(for item: CategoryItem, allowed: Bool) -> Color {
//        let cat = item.category
//        // Define groups with distinct colors.
//        let arts: Set<MKPointOfInterestCategory> = [.museum, .musicVenue, .theater]
//        let education: Set<MKPointOfInterestCategory> = [.library, .planetarium, .school, .university]
//        let entertainment: Set<MKPointOfInterestCategory> = [.movieTheater, .nightlife]
//        let health: Set<MKPointOfInterestCategory> = [.fireStation, .hospital, .pharmacy, .police]
//        let historical: Set<MKPointOfInterestCategory> = [.castle, .fortress, .landmark, .nationalMonument]
//        let food: Set<MKPointOfInterestCategory> = [.bakery, .brewery, .cafe, .distillery, .foodMarket, .restaurant, .winery]
//        let personal: Set<MKPointOfInterestCategory> = [.animalService, .atm, .automotiveRepair, .bank, .beauty, .evCharger, .fitnessCenter, .laundry, .mailbox, .postOffice, .restroom, .spa, .store]
//        let parks: Set<MKPointOfInterestCategory> = [.amusementPark, .aquarium, .beach, .campground, .fairground, .marina, .nationalPark, .park, .rvPark, .zoo]
//        let sports: Set<MKPointOfInterestCategory> = [.baseball, .basketball, .bowling, .goKart, .golf, .hiking, .miniGolf, .rockClimbing, .skatePark, .skating, .skiing, .soccer, .stadium, .tennis, .volleyball]
//        let travel: Set<MKPointOfInterestCategory> = [.airport, .carRental, .conventionCenter, .gasStation, .hotel, .parking, .publicTransport]
//        let water: Set<MKPointOfInterestCategory> = [.fishing, .kayaking, .surfing, .swimming]
//        
//        var baseColor: Color = .gray
//        if arts.contains(cat) { baseColor = .purple }
//        else if education.contains(cat) { baseColor = .green }
//        else if entertainment.contains(cat) { baseColor = .red }
//        else if health.contains(cat) { baseColor = .pink }
//        else if historical.contains(cat) { baseColor = .brown }
//        else if food.contains(cat) { baseColor = .orange }
//        else if personal.contains(cat) { baseColor = .mint }
//        else if parks.contains(cat) { baseColor = .teal }
//        else if sports.contains(cat) { baseColor = .indigo }
//        else if travel.contains(cat) { baseColor = .cyan }
//        else if water.contains(cat) { baseColor = .blue }
//        
//        return allowed ? baseColor : baseColor.opacity(0.5)
//    }
//}
//
//// MARK: - DestinationCircleIcon
//struct DestinationCircleIcon: View {
//    let systemName: String
//    let label: String
//    let color: Color
//    
//    var body: some View {
//        VStack(spacing: 4) {
//            ZStack {
//                Circle()
//                    .fill(color)
//                    .frame(width: 44, height: 44)
//                Image(systemName: systemName)
//                    .foregroundColor(.white)
//                    .font(.title3)
//            }
//            Text(label)
//                .font(.caption2).bold()
//                .foregroundColor(.primary)
//        }
//    }
//}
//
//struct SettingsView: View {
//    @Environment(\.dismiss) var dismiss
//    @Binding var userFavorites: [FavoriteItem]
//    
//    var body: some View {
//        NavigationView {
//            List {
//                NavigationLink("Favorites") {
//                    ManageFavoritesView(userFavorites: $userFavorites)
//                }
//                NavigationLink("Categories") {
//                    ManageCategoriesView()
//                }
//                NavigationLink("Contacts") {
//                    ManageContactsView()
//                        .environmentObject(ContactsManager()) // Alternatively, pass a shared ContactsManager from ContentView.
//                }
//            }
//            .navigationTitle("Settings")
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Done") { dismiss() }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - ManageFavoritesView
//struct ManageFavoritesView: View {
//    @Environment(\.dismiss) var dismiss
//    @Binding var userFavorites: [FavoriteItem]
//    
//    @State private var searchText: String = ""
//    @State private var showSearchSheet = false
//    @StateObject private var searchVM = MapSearchViewModel()
//    @State private var searchRegion = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
//        span: ContentView.defaultSpan
//    )
//    
//    @State private var editingFavorite: FavoriteItem? = nil
//    @State private var selectedSearchResult: MKMapItem? = nil
//    @State private var showFavoriteDetail = false
//    
//    var body: some View {
//        NavigationView {
//            List {
//                Section("Home & Work") {
//                    let homeIndex = userFavorites.firstIndex { $0.label == "Home" }
//                    if let i = homeIndex {
//                        FavoriteRow(favorite: userFavorites[i]) {
//                            editingFavorite = userFavorites[i]
//                            showSearchSheet = true
//                        }
//                    } else {
//                        let placeholder = FavoriteItem(iconName: "house.fill", label: "Home", color: .blue)
//                        FavoriteRow(favorite: placeholder) {
//                            editingFavorite = placeholder
//                            showSearchSheet = true
//                        }
//                    }
//                    
//                    let workIndex = userFavorites.firstIndex { $0.label == "Work" }
//                    if let i = workIndex {
//                        FavoriteRow(favorite: userFavorites[i]) {
//                            editingFavorite = userFavorites[i]
//                            showSearchSheet = true
//                        }
//                    } else {
//                        let placeholder = FavoriteItem(iconName: "briefcase.fill", label: "Work", color: .brown)
//                        FavoriteRow(favorite: placeholder) {
//                            editingFavorite = placeholder
//                            showSearchSheet = true
//                        }
//                    }
//                }
//                
//                Section("Custom Favorites") {
//                    ForEach(userFavorites.filter { $0.label != "Home" && $0.label != "Work" }, id: \.id) { fav in
//                        FavoriteRow(favorite: fav) {
//                            editingFavorite = fav
//                            showSearchSheet = true
//                        }
//                    }
//                    .onDelete { offsets in userFavorites.remove(atOffsets: offsets) }
//                    
//                    Button("Add New Favorite") {
//                        let newFav = FavoriteItem(iconName: "mappin.circle.fill", label: "New Favorite", color: .gray)
//                        editingFavorite = newFav
//                        showSearchSheet = true
//                    }
//                }
//            }
//            .navigationTitle("Manage Favorites")
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Done") { dismiss() }
//                }
//            }
//            .sheet(isPresented: $showSearchSheet) {
//                SearchView(searchText: $searchText,
//                           isPresented: $showSearchSheet,
//                           searchViewModel: searchVM,
//                           region: $searchRegion,
//                           userLocation: nil) { mapItem in
//                    selectedSearchResult = mapItem
//                    showSearchSheet = false
//                    showFavoriteDetail = true
//                }
//            }
//            .sheet(isPresented: $showFavoriteDetail) {
//                if let fav = editingFavorite, let mapItem = selectedSearchResult {
//                    FavoriteDetailView(favorite: fav,
//                                       mapItem: mapItem,
//                                       userFavorites: $userFavorites,
//                                       onSave: { updatedFav in
//                        if updatedFav.label == "Home" {
//                            if let i = userFavorites.firstIndex(where: { $0.label == "Home" }) {
//                                userFavorites[i] = updatedFav
//                            } else { userFavorites.append(updatedFav) }
//                        } else if updatedFav.label == "Work" {
//                            if let i = userFavorites.firstIndex(where: { $0.label == "Work" }) {
//                                userFavorites[i] = updatedFav
//                            } else { userFavorites.append(updatedFav) }
//                        } else {
//                            if let i = userFavorites.firstIndex(where: { $0.id == fav.id }) {
//                                userFavorites[i] = updatedFav
//                            } else { userFavorites.append(updatedFav) }
//                        }
//                        showFavoriteDetail = false
//                    },
//                                       onCancel: { showFavoriteDetail = false })
//                } else {
//                    Text("No selection made.").padding()
//                }
//            }
//            .onAppear { ensureHomeWorkExist() }
//        }
//    }
//    
//    private func ensureHomeWorkExist() {
//        if !userFavorites.contains(where: { $0.label == "Home" }) {
//            let home = FavoriteItem(iconName: "house.fill", label: "Home", color: .blue)
//            userFavorites.append(home)
//        }
//        if !userFavorites.contains(where: { $0.label == "Work" }) {
//            let work = FavoriteItem(iconName: "briefcase.fill", label: "Work", color: .brown)
//            userFavorites.append(work)
//        }
//    }
//}
//
//// MARK: - FavoriteRow
//struct FavoriteRow: View {
//    let favorite: FavoriteItem
//    let onTap: () -> Void
//    
//    var body: some View {
//        Button {
//            onTap()
//        } label: {
//            HStack(spacing: 12) {
//                ZStack {
//                    if favorite.address == nil {
//                        Circle().fill(Color(.systemGray4)).frame(width: 40, height: 40)
//                    } else {
//                        Circle().fill(favorite.color).frame(width: 40, height: 40)
//                    }
//                    Image(systemName: favorite.iconName)
//                        .font(.headline)
//                        .foregroundColor(.white)
//                }
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(favorite.label).font(.headline)
//                    if let a = favorite.address, let c = favorite.city, let s = favorite.state {
//                        Text("\(a), \(c), \(s)")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                    } else {
//                        Text("Set Address")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                    }
//                }
//            }
//            .padding(.vertical, 6)
//        }
//    }
//}
//
//// MARK: - FavoriteDetailView
//struct FavoriteDetailView: View {
//    @Environment(\.dismiss) var dismiss
//    @State var favorite: FavoriteItem
//    let mapItem: MKMapItem
//    @Binding var userFavorites: [FavoriteItem]
//    let onSave: (FavoriteItem) -> Void
//    let onCancel: () -> Void
//    
//    var cityState: String {
//        let c = mapItem.placemark.locality ?? ""
//        let s = mapItem.placemark.administrativeArea ?? ""
//        return "\(c), \(s)"
//    }
//    
//    let possibleColors: [Color] = [.gray, .blue, .brown, .green, .pink, .purple, .mint, .orange, .yellow, .cyan]
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Name")) {
//                    TextField("Enter a name", text: $favorite.label)
//                }
//                Section(header: Text("Address")) {
//                    Text(mapItem.name ?? "Unknown").font(.headline)
//                    Text(streetAddressFor(mapItem.placemark))
//                    Text(cityState)
//                }
//                Section(header: Text("Color")) {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack {
//                            ForEach(possibleColors, id: \.self) { color in
//                                Circle()
//                                    .fill(color)
//                                    .frame(width: 30, height: 30)
//                                    .overlay(
//                                        Circle().stroke(Color.white, lineWidth: favorite.color == color ? 3 : 0)
//                                    )
//                                    .onTapGesture { favorite.color = color }
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Favorite Details")
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") { onCancel(); dismiss() }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Confirm") {
//                        favorite.address = streetAddressFor(mapItem.placemark)
//                        favorite.city    = mapItem.placemark.locality
//                        favorite.state   = mapItem.placemark.administrativeArea
//                        let coord = mapItem.placemark.coordinate
//                        favorite.latitude = coord.latitude
//                        favorite.longitude = coord.longitude
//                        onSave(favorite)
//                        dismiss()
//                    }
//                }
//            }
//        }
//    }
//    
//    func streetAddressFor(_ placemark: CLPlacemark) -> String {
//        let sub = placemark.subThoroughfare ?? ""
//        let thr = placemark.thoroughfare ?? ""
//        let st = (sub + " " + thr).trimmingCharacters(in: .whitespaces)
//        return st.isEmpty ? "No street" : st
//    }
//}
//
//struct ManageContactsView: View {
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var contactsManager: ContactsManager
//    @State private var showAddContactSheet: Bool = false
//    
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(contactsManager.contacts) { contact in
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text(contact.fullName)
//                                .font(.headline)
//                            Text(contact.phoneNumber)
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                        Spacer()
//                    }
//                }
//                .onDelete(perform: contactsManager.removeContacts)
//            }
//            .navigationTitle("Manage Contacts")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Done") { dismiss() }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: { showAddContactSheet = true }) {
//                        Image(systemName: "plus")
//                    }
//                }
//            }
//            .sheet(isPresented: $showAddContactSheet) {
//                AddContactView { newContact in
//                    contactsManager.addContact(newContact)
//                }
//            }
//        }
//    }
//}
//
//struct AddContactView: View {
//    @Environment(\.dismiss) var dismiss
//    @State private var firstName: String = ""
//    @State private var lastName: String = ""
//    @State private var phoneNumber: String = ""
//    
//    // Validate: only allow exactly 10 digits (ignoring non-digit characters)
//    var isPhoneValid: Bool {
//        let digits = phoneNumber.filter { "0123456789".contains($0) }
//        return digits.count == 10
//    }
//    
//    // Format phone number for display, e.g., (123) 456-7890
//    func formatPhone(_ number: String) -> String {
//        let digits = number.filter { "0123456789".contains($0) }
//        guard digits.count == 10 else { return number }
//        let area = digits.prefix(3)
//        let middle = digits.dropFirst(3).prefix(3)
//        let last = digits.dropFirst(6)
//        return "(\(area)) \(middle)-\(last)"
//    }
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Contact Info")) {
//                    TextField("First Name", text: $firstName)
//                    TextField("Last Name", text: $lastName)
//                    TextField("Phone Number", text: $phoneNumber)
//                        .keyboardType(.phonePad)
//                }
//            }
//            .navigationTitle("Add Contact")
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") { dismiss() }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Save") {
//                        // Here, we store the raw 10-digit string (if valid)
//                        let digits = phoneNumber.filter { "0123456789".contains($0) }
//                        let newContact = ContactItem(firstName: firstName,
//                                                     lastName: lastName,
//                                                     phoneNumber: digits)
//                        onSave(newContact)
//                        dismiss()
//                    }
//                    .disabled(!isPhoneValid)
//                }
//            }
//        }
//        .presentationDetents([.medium])
//    }
//    
//    var onSave: (ContactItem) -> Void
//}
//
//struct ContactItem: Identifiable, Codable, Equatable {
//    var id: UUID = UUID()
//    var firstName: String = ""
//    var lastName: String = ""
//    var phoneNumber: String = ""
//    
//    var fullName: String {
//        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
//    }
//}
//
//class ContactsManager: ObservableObject {
//    @Published var contacts: [ContactItem] = []
//    
//    private let key = "com.yourapp.contacts"
//    
//    init() {
//        loadContacts()
//    }
//    
//    func loadContacts() {
//        if let data = UserDefaults.standard.data(forKey: key) {
//            do {
//                let decoded = try JSONDecoder().decode([ContactItem].self, from: data)
//                self.contacts = decoded
//            } catch {
//                print("Error decoding contacts: \(error)")
//            }
//        }
//    }
//    
//    func saveContacts() {
//        do {
//            let data = try JSONEncoder().encode(contacts)
//            UserDefaults.standard.set(data, forKey: key)
//        } catch {
//            print("Error encoding contacts: \(error)")
//        }
//    }
//    
//    func addContact(_ contact: ContactItem) {
//        contacts.append(contact)
//        saveContacts()
//    }
//    
//    func removeContacts(at offsets: IndexSet) {
//        contacts.remove(atOffsets: offsets)
//        saveContacts()
//    }
//}
//
//// MARK: - StatusCapsulesView
//struct StatusCapsulesView: View {
//    @Binding var region: MKCoordinateRegion
//    @ObservedObject var locationManager: LocationManager
//    @StateObject private var weatherManager = WeatherManager()
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            CapsuleView(text: speedText)
//            CapsuleView(text: cardinalDirectionText)
//            CapsuleView(text: temperatureText)
//        }
//        .onAppear { weatherManager.updateTemperature(for: region.center) }
//        .onChange(of: region.center) { newCenter in weatherManager.updateTemperature(for: newCenter) }
//    }
//    
//    var speedText: String {
//        if let speed = locationManager.location?.speed, speed > 0 {
//            return String(format: "%.0f mph", speed * 2.23694)
//        }
//        return "0 mph"
//    }
//    
//    var cardinalDirectionText: String {
//        let degrees: Double
//        if let trueHeading = locationManager.heading?.trueHeading, trueHeading > 0 {
//            degrees = trueHeading
//        } else if let magneticHeading = locationManager.heading?.magneticHeading, magneticHeading > 0 {
//            degrees = magneticHeading
//        } else {
//            degrees = 0
//        }
//        return cardinalDirection(from: degrees)
//    }
//    
//    var temperatureText: String {
//        if let temp = weatherManager.temperature {
//            return String(format: "%.0f°F", temp)
//        }
//        return "--°F"
//    }
//    
//    func cardinalDirection(from degrees: Double) -> String {
//        let normalized = degrees.truncatingRemainder(dividingBy: 360)
//        switch normalized {
//        case 337.5..<360, 0..<22.5: return "N"
//        case 22.5..<67.5: return "NE"
//        case 67.5..<112.5: return "E"
//        case 112.5..<157.5: return "SE"
//        case 157.5..<202.5: return "S"
//        case 202.5..<247.5: return "SW"
//        case 247.5..<292.5: return "W"
//        case 292.5..<337.5: return "NW"
//        default: return "N"
//        }
//    }
//}
//
//// MARK: - CapsuleView
//struct CapsuleView: View {
//    let text: String
//    var body: some View {
//        Text(text)
//            .font(.headline)
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//            .background(Capsule().fill(.ultraThinMaterial))
//            .shadow(radius: 2)
//    }
//}
//
//struct MusicControlView: View {
//    @EnvironmentObject var musicPlayerViewModel: MusicPlayerViewModel
//    @EnvironmentObject var musicLibraryViewModel: MusicLibraryViewModel
//    @Binding var showPlaylistSelector: Bool
//
//    // Timer to update the progress bar.
//    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    @State private var refreshFlag: Bool = false
//
//    // Computed properties for playback progress.
//    var currentPlaybackTime: TimeInterval {
//        MPMusicPlayerController.systemMusicPlayer.currentPlaybackTime
//    }
//    var playbackDuration: TimeInterval {
//        MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.playbackDuration ?? 0
//    }
//    var playbackProgress: Double {
//        guard playbackDuration > 0 else { return 0 }
//        return currentPlaybackTime / playbackDuration
//    }
//    
//    var body: some View {
//        ZStack {
//            backgroundView
//                .padding(.bottom, -25) // Extend the album art background downward by 25 points
//
//            if showPlaylistSelector {
//                playlistView
//                    .offset(y:40)
//            } else {
//                controlModeView
//                    .offset(y:35)
//            }
//        }
//        .frame(height: 225)
////        .clipped()
//        .onReceive(timer) { _ in
//            self.refreshFlag.toggle()
//        }
//    }
//    
//    // MARK: - Background
//    private var backgroundView: some View {
//        ZStack {
//            if let cover = musicPlayerViewModel.nowPlayingAlbumCover {
//                // Set the blur radius based on playback state:
//                let blurRadius = musicPlayerViewModel.playbackState == .playing ? 10 : 20
//                Image(uiImage: cover)
//                    .resizable()
//                    .scaledToFill()
//                    // Apply saturation based on playback progress:
//                    .saturation(playbackProgress)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .clipped()
//                    .blur(radius: CGFloat(blurRadius))
//                    .overlay(
//                        LinearGradient(
//                            gradient: Gradient(colors: [Color.black.opacity(0.2), Color.clear]),
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                    )
//            } else {
//                Color.white
//            }
//            // An extra subtle overlay for texture.
//            Color.white.opacity(0.02)
//                .blur(radius: 5)
//        }
//    }
//    
//    // MARK: - Control Mode (Song Info, Gestures & Progress Bar)
//    private var controlModeView: some View {
//        GeometryReader { geo in
//            VStack(spacing: 8) {
//                // Push content toward the top.
//                Spacer(minLength: geo.size.height * 0.2)
//                
//                // Song info: Title (cleaned) and Artist.
//                if !musicPlayerViewModel.currentSongTitle.isEmpty {
//                    VStack(spacing: 4) {
//                        Text(cleanSongTitle(musicPlayerViewModel.currentSongTitle))
//                            .font(.title).bold()
//                            .foregroundColor(.white)
//                        if !musicPlayerViewModel.currentArtistName.isEmpty {
//                            Text(musicPlayerViewModel.currentArtistName)
//                                .font(.title2)
//                                .fontWeight(.semibold)
//                                .foregroundColor(.white.opacity(0.8))
//                        }
//                    }
//                }
//                Spacer()
//                    .frame(height: 15)
//                // Progress Bar right below the artist name.
//                SongProgressView(progress: playbackProgress,
//                                 currentTime: currentPlaybackTime,
//                                 duration: playbackDuration)
//                    .padding(.horizontal)
//                
//                Spacer()
//            }
//            .frame(width: geo.size.width, height: geo.size.height)
//            // Make entire area tappable.
//            .contentShape(Rectangle())
//            .highPriorityGesture(
//                DragGesture(minimumDistance: 20)
//                    .onEnded { value in
//                        if value.translation.width > 75 {
//                            previousTrack()
//                        } else if value.translation.width < -75 {
//                            nextTrack()
//                        }
//                    }
//            )
//            .onTapGesture {
//                togglePlayPause()
//            }
//        }
//    }
//    
//    // MARK: - Playlist View
//    private var playlistView: some View {
//        VStack {
//            Spacer()
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 16) {
//                    ShuffleLibraryIcon()
//                        .onTapGesture { shuffleAllSongs() }
//                    
//                    ForEach(Array(musicLibraryViewModel.playlists.enumerated()), id: \.element.persistentID) { index, playlist in
//                        PlaylistItemView(playlist: playlist, seed: "\(playlist.persistentID)-\(index)")
//                            .onTapGesture {
//                                let player = MPMusicPlayerController.systemMusicPlayer
//                                player.setQueue(with: playlist)
//                                player.shuffleMode = .songs
//                                player.play()
//                            }
//                    }
//                }
//                .padding(.horizontal)
//            }
//            Spacer()
//        }
//    }
//    
//    // MARK: - Music Control Functions
//    func previousTrack() {
//        MPMusicPlayerController.systemMusicPlayer.skipToPreviousItem()
//    }
//    
//    func togglePlayPause() {
//        let player = MPMusicPlayerController.systemMusicPlayer
//        if musicPlayerViewModel.playbackState == .playing {
//            player.pause()
//        } else {
//            player.play()
//        }
//    }
//    
//    func nextTrack() {
//        MPMusicPlayerController.systemMusicPlayer.skipToNextItem()
//    }
//    
//    func shuffleAllSongs() {
//        let query = MPMediaQuery.songs()
//        let player = MPMusicPlayerController.systemMusicPlayer
//        player.setQueue(with: query)
//        player.shuffleMode = .songs
//        player.play()
//    }
//    
//    // MARK: - Helper: Clean Song Title
//    private func cleanSongTitle(_ title: String) -> String {
//        var cleaned = title.replacingOccurrences(of: "\\(.*?\\)", with: "", options: .regularExpression)
//        cleaned = cleaned.replacingOccurrences(of: "\\[.*?\\]", with: "", options: .regularExpression)
//        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//}
//
//// MARK: - Progress Bar View
//struct SongProgressView: View {
//    let progress: Double
//    let currentTime: TimeInterval
//    let duration: TimeInterval
//    
//    var body: some View {
//        VStack(spacing: 4) {
//            ZStack(alignment: .leading) {
//                Capsule()
//                    .frame(height: 6)
//                    .foregroundColor(Color.gray.opacity(0.5))
//                Capsule()
//                    .frame(width: CGFloat(progress) * UIScreen.main.bounds.width, height: 6)
//                    .foregroundColor(.white)
//            }
//            HStack {
//                Text(timeFormatted(currentTime))
//                Spacer()
//                Text(timeFormatted(duration))
//            }
//            .font(.caption)
//            .foregroundColor(.white)
//        }
//        .frame(height: 30)
//    }
//    
//    func timeFormatted(_ totalSeconds: TimeInterval) -> String {
//        guard totalSeconds.isFinite else { return "0:00" }
//        let seconds = Int(totalSeconds) % 60
//        let minutes = Int(totalSeconds) / 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//}
//
///// Observes the system music player's playback state & now‑playing info.
//class MusicPlayerViewModel: ObservableObject {
//    @Published var playbackState: MPMusicPlaybackState = .stopped
//    @Published var nowPlayingAlbumCover: UIImage? = nil
//    @Published var currentSongTitle: String = ""
//    @Published var currentArtistName: String = ""
//    
//    private var player = MPMusicPlayerController.systemMusicPlayer
//    
//    init() {
//        self.playbackState = player.playbackState
//        updateNowPlayingInfo()
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(playbackStateChanged),
//                                               name: .MPMusicPlayerControllerPlaybackStateDidChange,
//                                               object: player)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(nowPlayingItemChanged),
//                                               name: .MPMusicPlayerControllerNowPlayingItemDidChange,
//                                               object: player)
//        player.beginGeneratingPlaybackNotifications()
//    }
//    
//    @objc private func playbackStateChanged() {
//        DispatchQueue.main.async {
//            self.playbackState = self.player.playbackState
//            self.updateNowPlayingInfo()
//        }
//    }
//    
//    @objc private func nowPlayingItemChanged() {
//        DispatchQueue.main.async {
//            self.updateNowPlayingInfo()
//        }
//    }
//    
//    private func updateNowPlayingInfo() {
//        if let nowPlaying = player.nowPlayingItem {
//            if let artwork = nowPlaying.artwork,
//               let image = artwork.image(at: CGSize(width: 300, height: 300)) {
//                self.nowPlayingAlbumCover = image
//            } else {
//                self.nowPlayingAlbumCover = nil
//            }
//            self.currentSongTitle = nowPlaying.title ?? ""
//            self.currentArtistName = nowPlaying.artist ?? ""
//        } else {
//            self.nowPlayingAlbumCover = nil
//            self.currentSongTitle = ""
//            self.currentArtistName = ""
//        }
//    }
//    
//    deinit {
//        player.endGeneratingPlaybackNotifications()
//        NotificationCenter.default.removeObserver(self)
//    }
//}
//
///// Fetches playlists from the user's music library.
//class MusicLibraryViewModel: ObservableObject {
//    @Published var playlists: [MPMediaPlaylist] = []
//    
//    init() {
//        requestAuthorization()
//    }
//    
//    func requestAuthorization() {
//        MPMediaLibrary.requestAuthorization { status in
//            if status == .authorized {
//                self.fetchPlaylists()
//            } else {
//                print("Not authorized to access music library")
//            }
//        }
//    }
//    
//    func fetchPlaylists() {
//        let query = MPMediaQuery.playlists()
//        if let collections = query.collections as? [MPMediaPlaylist] {
//            DispatchQueue.main.async {
//                self.playlists = collections
//            }
//        }
//    }
//}
//
//// MARK: - Easy UIBezierPath -> Path operator
//infix operator |>: MultiplicationPrecedence
//func |><A,B>(lhs: A, rhs: (A) -> B) -> B { rhs(lhs) }
//
//#Preview {
//    ContentView()
//        .environmentObject(ContactsManager())
//}

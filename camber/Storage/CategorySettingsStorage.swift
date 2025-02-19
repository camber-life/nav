//
//  CategorySettingsStorage.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import Foundation
import SwiftUI
import MapKit

public struct CategorySettingsStorage {
    static let key = "com.yourapp.categorysettings"
    
    public static func save(_ groups: [CategorySettingGroup]) {
        do {
            let data = try JSONEncoder().encode(groups)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to encode category settings:", error)
        }
    }
    
    public static func load() -> [CategorySettingGroup]? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            let groups = try JSONDecoder().decode([CategorySettingGroup].self, from: data)
            return groups
        } catch {
            print("Failed to decode category settings:", error)
            return nil
        }
    }
}

// Make sure your model types are declared public if they need to be visible in other files:
public struct CategorySetting: Codable, Identifiable, Equatable {
    public let id: String // use MKPointOfInterestCategory.rawValue
    public let title: String
    public var isOn: Bool

    public init(id: String, title: String, isOn: Bool) {
        self.id = id
        self.title = title
        self.isOn = isOn
    }
}

public struct CategorySettingGroup: Codable, Identifiable, Equatable {
    public let id: String // use group name
    public var groupName: String
    public var groupColorHex: String
    public var categories: [CategorySetting]

    public var groupColor: Color {
        get { Color.fromHex(groupColorHex) }
        set { groupColorHex = newValue.toHex() }
    }

    public init(id: String, groupName: String, groupColorHex: String, categories: [CategorySetting]) {
        self.id = id
        self.groupName = groupName
        self.groupColorHex = groupColorHex
        self.categories = categories
    }
}

// Define defaultCategoryGroups publicly
public let defaultCategoryGroups: [CategorySettingGroup] = [
    CategorySettingGroup(
        id: "Arts",
        groupName: "Arts & Culture",
        groupColorHex: Color.purple.toHex(),
        categories: [
            CategorySetting(id: MKPointOfInterestCategory.museum.rawValue, title: "Museum", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.musicVenue.rawValue, title: "Music Venue", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.theater.rawValue, title: "Theater", isOn: true)
        ]
    ),
    CategorySettingGroup(
        id: "Education",
        groupName: "Education",
        groupColorHex: Color.green.toHex(),
        categories: [
            CategorySetting(id: MKPointOfInterestCategory.library.rawValue, title: "Library", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.planetarium.rawValue, title: "Planetarium", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.school.rawValue, title: "School", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.university.rawValue, title: "University", isOn: true)
        ]
    ),
    CategorySettingGroup(
        id: "Entertainment",
        groupName: "Entertainment",
        groupColorHex: Color.red.toHex(),
        categories: [
            CategorySetting(id: MKPointOfInterestCategory.movieTheater.rawValue, title: "Movie Theater", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.nightlife.rawValue, title: "Nightlife", isOn: true)
        ]
    ),
    CategorySettingGroup(
        id: "Health",
        groupName: "Health & Safety",
        groupColorHex: Color.pink.toHex(),
        categories: [
            CategorySetting(id: MKPointOfInterestCategory.fireStation.rawValue, title: "Fire Station", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.hospital.rawValue, title: "Hospital", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.pharmacy.rawValue, title: "Pharmacy", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.police.rawValue, title: "Police", isOn: true)
        ]
    ),
    CategorySettingGroup(
        id: "Historical",
        groupName: "Historical & Cultural",
        groupColorHex: Color.brown.toHex(),
        categories: [
            CategorySetting(id: MKPointOfInterestCategory.castle.rawValue, title: "Castle", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.fortress.rawValue, title: "Fortress", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.landmark.rawValue, title: "Landmark", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.nationalMonument.rawValue, title: "Monument", isOn: true)
        ]
    ),
    CategorySettingGroup(
        id: "Food",
        groupName: "Food & Drink",
        groupColorHex: Color.orange.toHex(),
        categories: [
            CategorySetting(id: MKPointOfInterestCategory.bakery.rawValue, title: "Bakery", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.brewery.rawValue, title: "Brewery", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.cafe.rawValue, title: "Cafe", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.distillery.rawValue, title: "Distillery", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.foodMarket.rawValue, title: "Food Market", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.restaurant.rawValue, title: "Restaurant", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.winery.rawValue, title: "Winery", isOn: true)
        ]
    ),
    CategorySettingGroup(
        id: "Personal",
        groupName: "Personal Services",
        groupColorHex: Color.mint.toHex(),
        categories: [
            CategorySetting(id: MKPointOfInterestCategory.animalService.rawValue, title: "Animal Service", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.atm.rawValue, title: "ATM", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.automotiveRepair.rawValue, title: "Auto Repair", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.bank.rawValue, title: "Bank", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.beauty.rawValue, title: "Beauty", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.evCharger.rawValue, title: "EV Charger", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.fitnessCenter.rawValue, title: "Fitness Center", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.laundry.rawValue, title: "Laundry", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.mailbox.rawValue, title: "Mailbox", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.postOffice.rawValue, title: "Post Office", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.restroom.rawValue, title: "Restroom", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.spa.rawValue, title: "Spa", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.store.rawValue, title: "Store", isOn: true)
        ]
    ),
    CategorySettingGroup(
        id: "Parks",
        groupName: "Parks & Recreation",
        groupColorHex: Color.teal.toHex(),
        categories: [
            CategorySetting(id: MKPointOfInterestCategory.amusementPark.rawValue, title: "Amusement Park", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.aquarium.rawValue, title: "Aquarium", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.beach.rawValue, title: "Beach", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.campground.rawValue, title: "Campground", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.fairground.rawValue, title: "Fairground", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.marina.rawValue, title: "Marina", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.nationalPark.rawValue, title: "National Park", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.park.rawValue, title: "Park", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.rvPark.rawValue, title: "RV Park", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.zoo.rawValue, title: "Zoo", isOn: true)
        ]
    ),
    CategorySettingGroup(
        id: "Sports",
        groupName: "Sports",
        groupColorHex: Color.indigo.toHex(),
        categories: [
            CategorySetting(id: MKPointOfInterestCategory.baseball.rawValue, title: "Baseball", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.basketball.rawValue, title: "Basketball", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.bowling.rawValue, title: "Bowling", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.goKart.rawValue, title: "Go Kart", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.golf.rawValue, title: "Golf", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.hiking.rawValue, title: "Hiking", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.miniGolf.rawValue, title: "Mini Golf", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.rockClimbing.rawValue, title: "Rock Climbing", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.skatePark.rawValue, title: "Skate Park", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.skating.rawValue, title: "Skating", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.skiing.rawValue, title: "Skiing", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.soccer.rawValue, title: "Soccer", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.stadium.rawValue, title: "Stadium", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.tennis.rawValue, title: "Tennis", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.volleyball.rawValue, title: "Volleyball", isOn: true)
        ]
    ),
    CategorySettingGroup(
        id: "Travel",
        groupName: "Travel",
        groupColorHex: Color.cyan.toHex(),
        categories: [
            CategorySetting(id: MKPointOfInterestCategory.airport.rawValue, title: "Airport", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.carRental.rawValue, title: "Car Rental", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.conventionCenter.rawValue, title: "Convention Center", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.gasStation.rawValue, title: "Gas Station", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.hotel.rawValue, title: "Hotel", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.parking.rawValue, title: "Parking", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.publicTransport.rawValue, title: "Public Transport", isOn: true)
        ]
    ),
    CategorySettingGroup(
        id: "Water",
        groupName: "Water Sports",
        groupColorHex: Color.blue.toHex(),
        categories: [
            CategorySetting(id: MKPointOfInterestCategory.fishing.rawValue, title: "Fishing", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.kayaking.rawValue, title: "Kayaking", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.surfing.rawValue, title: "Surfing", isOn: true),
            CategorySetting(id: MKPointOfInterestCategory.swimming.rawValue, title: "Swimming", isOn: true)
        ]
    )
]

extension Color {
    func toHex() -> String {
        // Convert the Color to a UIColor first.
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02X%02X%02X%02X",
                      Int(red * 255),
                      Int(green * 255),
                      Int(blue * 255),
                      Int(alpha * 255))
    }
    
    static func fromHex(_ hex: String) -> Color {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        if hexString.count == 8 {
            let r = Double((rgbValue & 0xFF000000) >> 24) / 255
            let g = Double((rgbValue & 0x00FF0000) >> 16) / 255
            let b = Double((rgbValue & 0x0000FF00) >> 8) / 255
            let a = Double(rgbValue & 0x000000FF) / 255
            return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
        } else if hexString.count == 6 {
            let r = Double((rgbValue & 0xFF0000) >> 16) / 255
            let g = Double((rgbValue & 0x00FF00) >> 8) / 255
            let b = Double(rgbValue & 0x0000FF) / 255
            return Color(.sRGB, red: r, green: g, blue: b, opacity: 1)
        } else {
            return .gray
        }
    }
}

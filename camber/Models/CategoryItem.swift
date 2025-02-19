//
//  CategoryItem.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import MapKit
import SwiftUI

public struct CategoryItem {
    public let category: MKPointOfInterestCategory
    public let title: String
    public let iconName: String
    
    public init(category: MKPointOfInterestCategory, title: String, iconName: String) {
        self.category = category
        self.title = title
        self.iconName = iconName
    }
}

public let defaultCategoryIcons: [String: String] = [
    MKPointOfInterestCategory.museum.rawValue: "building.columns",
    MKPointOfInterestCategory.musicVenue.rawValue: "music.mic",
    MKPointOfInterestCategory.theater.rawValue: "theatermasks.fill",
    // … (add the rest of your mapping)
]
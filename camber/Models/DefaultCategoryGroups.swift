import SwiftUI
import MapKit

public let defaultCategoryGroups: [CategorySettingGroup] = [
    CategorySettingGroup(id: "Arts", groupName: "Arts & Culture", groupColorHex: Color.purple.toHex(), categories: [
        CategorySetting(id: MKPointOfInterestCategory.museum.rawValue, title: "Museum", isOn: true),
        CategorySetting(id: MKPointOfInterestCategory.musicVenue.rawValue, title: "Music Venue", isOn: true),
        CategorySetting(id: MKPointOfInterestCategory.theater.rawValue, title: "Theater", isOn: true)
    ]),
    // … add the remaining groups similar to your current defaultCategoryGroups …
]

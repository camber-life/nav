import SwiftUI
import MapKit

public struct FavoriteItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public var iconName: String
    public var label: String
    public var address: String?
    public var city: String?
    public var state: String?
    
    // For routing:
    public var latitude: Double?
    public var longitude: Double?
    
    public var colorHex: String
    public var color: Color {
        get { Color.fromHex(colorHex) }
        set { colorHex = newValue.toHex() }
    }
    
    public init(id: UUID = UUID(),
                iconName: String,
                label: String,
                address: String? = nil,
                city: String? = nil,
                state: String? = nil,
                latitude: Double? = nil,
                longitude: Double? = nil,
                color: Color = .gray) {
        self.id = id
        self.iconName = iconName
        self.label = label
        self.address = address
        self.city = city
        self.state = state
        self.latitude = latitude
        self.longitude = longitude
        self.colorHex = color.toHex()
    }
    
    public func toMapItem() -> MKMapItem? {
        guard let lat = latitude, let lon = longitude else { return nil }
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let placemark = MKPlacemark(coordinate: coord)
        let item = MKMapItem(placemark: placemark)
        item.name = label
        return item
    }
}

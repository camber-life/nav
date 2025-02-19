import SwiftUI

struct ManageMapsView: View {
    // This stores the user's preferred map service persistently.
    @AppStorage("preferredMapService") private var preferredMapServiceRawValue: String = MapService.apple.rawValue

    enum MapService: String, CaseIterable, Identifiable {
        case apple = "Apple Maps"
        case google = "Google Maps"
        case open = "Open Maps"
        case mapbox = "Mapbox"
        
        var id: String { rawValue }
        
        // Use asset catalog images instead of system icons.
        var imageName: String {
            switch self {
            case .apple: return "AppleMaps"
            case .google: return "GoogleMaps"
            case .open: return "OpenStreetMaps"
            case .mapbox: return "MapBox"
            }
        }
    }
    
    // A computed property for convenience if needed.
    var preferredMapService: MapService {
        MapService(rawValue: preferredMapServiceRawValue) ?? .apple
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(MapService.allCases) { service in
                Button(action: {
                    // Update the preferred map service.
                    preferredMapServiceRawValue = service.rawValue
                }) {
                    HStack(spacing: 15) {
                        Image(service.imageName)  // Use asset catalog images.
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        
                        Text(service.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Show a capsule if this service is the default.
                        if service.rawValue == preferredMapServiceRawValue {
                            Text("Default")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.blue))
                        }
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Maps Settings")
    }
}

struct MapsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ManageMapsView()
        }
    }
}

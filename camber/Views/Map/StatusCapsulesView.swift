//
//  StatusCapsulesView.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import SwiftUI
import CoreLocation
import MapKit

struct StatusCapsulesView: View {
    @Binding var region: MKCoordinateRegion
    @ObservedObject var locationManager: LocationManager
    @StateObject private var weatherManager = WeatherManager()
    
    var body: some View {
        HStack(spacing: 12) {
            CapsuleView(text: speedText)
            CapsuleView(text: cardinalDirectionText)
            CapsuleView(text: temperatureText)
        }
        .onAppear { weatherManager.updateTemperature(for: region.center) }
        .onChange(of: region.center) { newCenter in
            weatherManager.updateTemperature(for: newCenter)
        }
    }
    
    var speedText: String {
        if let speed = locationManager.location?.speed, speed > 0 {
            return String(format: "%.0f mph", speed * 2.23694)
        }
        return "0 mph"
    }
    
    var cardinalDirectionText: String {
        let degrees: Double
        if let trueHeading = locationManager.heading?.trueHeading, trueHeading > 0 {
            degrees = trueHeading
        } else if let magneticHeading = locationManager.heading?.magneticHeading, magneticHeading > 0 {
            degrees = magneticHeading
        } else {
            degrees = 0
        }
        return cardinalDirection(from: degrees)
    }
    
    var temperatureText: String {
        if let temp = weatherManager.temperature {
            return String(format: "%.0f°F", temp)
        }
        return "--°F"
    }
    
    func cardinalDirection(from degrees: Double) -> String {
        let normalized = degrees.truncatingRemainder(dividingBy: 360)
        switch normalized {
        case 337.5..<360, 0..<22.5: return "N"
        case 22.5..<67.5: return "NE"
        case 67.5..<112.5: return "E"
        case 112.5..<157.5: return "SE"
        case 157.5..<202.5: return "S"
        case 202.5..<247.5: return "SW"
        case 247.5..<292.5: return "W"
        case 292.5..<337.5: return "NW"
        default: return "N"
        }
    }
}

struct CapsuleView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.headline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(.ultraThinMaterial))
            .shadow(radius: 2)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

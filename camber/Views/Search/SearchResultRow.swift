//
//  SearchResultRow.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/11/25.
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - SearchResultRow
/// Displays a row with:
///  - A circle icon (white SF Symbol on a colored background),
///  - Up to three lines of text:
///       1) item.name
///       2) item’s street address (or city/state if line1 == line2),
///       3) city/state (omitted if line2 is already city/state).
///  - The distance in miles at the trailing side.
struct SearchResultRow: View {
    let item: MKMapItem
    var userLocation: CLLocation?
    var onTap: () -> Void
    
    var body: some View {
        // Calculate the three “lines”
        let topLine    = item.name ?? "Unknown"
        let midLineRaw = streetAddressFor(item.placemark)
        let botLineRaw = cityStateFor(item.placemark)
        
        // If topLine == midLine, skip the mid line and shift city/state up
        let (line1, line2, line3) = consolidateLines(top: topLine,
                                                     mid: midLineRaw,
                                                     bot: botLineRaw)
        
        HStack {
            // Icon (white symbol on a circle background).
            categoryCircleIcon(item.pointOfInterestCategory)
                .frame(width: 32, height: 32)
            
            // Text lines
            VStack(alignment: .leading, spacing: 2) {
                Text(line1)
                    .font(.headline)
                
                if !line2.isEmpty {
                    Text(line2)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if !line3.isEmpty {
                    Text(line3)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.leading, 6)
            
            Spacer()
            
            // Distance
            VStack {
                Image(systemName: "location.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text(distanceString())
                    .font(.footnote)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
    
    // MARK: - Helpers
    
    /// Consolidates lines so if line1 == line2, we skip line2 and shift line3 up.
    private func consolidateLines(top: String,
                                  mid: String,
                                  bot: String) -> (String, String, String)
    {
        if top == mid && !top.isEmpty {
            // Use top for line1, skip mid, shift city/state up
            return (top, bot, "")
        } else {
            // The normal 3-line scenario
            return (top, mid, bot)
        }
    }
    
    /// Returns a string like “2.5 mi” based on userLocation → item distance.
    private func distanceString() -> String {
        guard let userLoc = userLocation else { return "--" }
        let dest = CLLocation(latitude: item.placemark.coordinate.latitude,
                              longitude: item.placemark.coordinate.longitude)
        let meters = userLoc.distance(from: dest)
        let miles = meters / 1609.34
        return String(format: "%.1f mi", miles)
    }
    
    /// Returns a street address (house # + street name).
    private func streetAddressFor(_ placemark: CLPlacemark) -> String {
        let sub = placemark.subThoroughfare ?? ""
        let thr = placemark.thoroughfare ?? ""
        let street = (sub + " " + thr).trimmingCharacters(in: .whitespaces)
        return street.isEmpty ? "No street" : street
    }
    
    /// Returns “City, State” or an empty string if unknown.
    private func cityStateFor(_ placemark: CLPlacemark) -> String {
        let city = placemark.locality ?? ""
        let state = placemark.administrativeArea ?? ""
        let combined = (city + ", " + state).trimmingCharacters(in: .whitespacesAndNewlines)
        return combined == "," ? "" : combined
    }
    
    // MARK: - Category Icon (White SF Symbol + Colored Circle)
    /// Returns a circle with a white SF Symbol inside. The circle color depends on the grouping,
    /// and the specific icon depends on the exact MKPointOfInterestCategory.
    private func categoryCircleIcon(_ cat: MKPointOfInterestCategory?) -> some View {
        let (iconName, groupColor) = categoryIconInfo(cat)
        
        return ZStack {
            Circle()
                .fill(groupColor)
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    /// Returns (systemImageName, circleColor) for each Apple category.
    /// Group them by color. Adjust as needed.
    private func categoryIconInfo(_ cat: MKPointOfInterestCategory?) -> (String, Color) {
        guard let c = cat else {
            return ("mappin.and.ellipse", .gray)
        }
        
        // FOOD & DRINK (Orange)
        switch c {
        case .bakery:         return ("takeoutbag.and.cup.and.straw.fill", .orange)
        case .brewery:        return ("wineglass", .orange)
        case .cafe:           return ("cup.and.saucer.fill", .orange)
        case .distillery:     return ("wineglass", .orange)
        case .foodMarket:     return ("cart.fill", .orange)
        case .restaurant:     return ("fork.knife", .orange)
        case .winery:         return ("wineglass", .orange)
            
        // ARTS & CULTURE (Purple)
        case .museum:         return ("building.columns", .purple)
        case .musicVenue:     return ("music.note.house.fill", .purple)
        case .theater:        return ("theatermasks.fill", .purple)
            
        // EDUCATION (Blue)
        case .library:        return ("books.vertical.fill", .blue)
        case .planetarium:    return ("sparkles", .blue)
        case .school:         return ("graduationcap.fill", .blue)
        case .university:     return ("graduationcap.fill", .blue)
            
        // ENTERTAINMENT (Pink)
        case .movieTheater:   return ("film.fill", .pink)
        case .nightlife:      return ("sparkles.tv", .pink)
            
        // HEALTH & SAFETY (Red)
        case .fireStation:    return ("flame.fill", .red)
        case .hospital:       return ("cross.fill", .red)
        case .pharmacy:       return ("cross.fill", .red)
        case .police:         return ("shield.fill", .red)
            
        // HISTORICAL & CULTURAL (Brown)
        case .castle:         return ("building.fill", .brown)
        case .fortress:       return ("building.fill", .brown)
        case .landmark:       return ("mappin.circle.fill", .brown)
        case .nationalMonument:
                               return ("mappin.circle.fill", .brown)
            
        // PERSONAL SERVICES (Indigo)
        case .animalService:  return ("hare.fill", .indigo)
        case .atm:            return ("dollarsign.circle.fill", .indigo)
        case .automotiveRepair: return ("wrench.and.screwdriver.fill", .indigo)
        case .bank:           return ("dollarsign.circle.fill", .indigo)
        case .beauty:         return ("face.smiling.fill", .indigo)
        case .evCharger:      return ("bolt.car.fill", .indigo)
        case .fitnessCenter:  return ("figure.walk", .indigo)
        case .laundry:        return ("takeoutbag.and.cup.and.straw.fill", .indigo)
        case .mailbox:        return ("envelope.circle.fill", .indigo)
        case .postOffice:     return ("envelope.fill", .indigo)
        case .restroom:       return ("figure.wave.circle.fill", .indigo)
        case .spa:            return ("leaf.fill", .indigo)
        case .store:          return ("bag.fill", .indigo)
            
        // PARKS & RECREATION (Green)
        case .amusementPark:  return ("figure.wave.circle", .green)
        case .aquarium:       return ("tortoise.fill", .green)
        case .beach:          return ("beach.umbrella.fill", .green)
        case .campground:     return ("tent.fill", .green)
        case .fairground:     return ("ferriswheel.fill", .green)
        case .marina:         return ("sailboat.fill", .green)
        case .nationalPark:   return ("leaf.fill", .green)
        case .park:           return ("leaf.fill", .green)
        case .rvPark:         return ("car.fill", .green)
        case .zoo:            return ("pawprint.fill", .green)
            
        // SPORTS (Mint)
        case .baseball:       return ("sportscourt.fill", .mint)
        case .basketball:     return ("sportscourt.fill", .mint)
        case .bowling:        return ("circle.grid.3x3.fill", .mint)
        case .goKart:         return ("figure.wave.circle.fill", .mint)
        case .golf:           return ("flag.fill", .mint)
        case .hiking:         return ("figure.hiking", .mint)
        case .miniGolf:       return ("flag.2.crossed.fill", .mint)
        case .rockClimbing:   return ("figure.climbing", .mint)
        case .skatePark:      return ("figure.stand.line.dotted.figure.stand", .mint)
        case .skating:        return ("figure.skating", .mint)
        case .skiing:         return ("figure.skiing.downhill", .mint)
        case .soccer:         return ("sportscourt.fill", .mint)
        case .stadium:        return ("sportscourt.fill", .mint)
        case .tennis:         return ("sportscourt.fill", .mint)
        case .volleyball:     return ("sportscourt.fill", .mint)
            
        // TRAVEL (Cyan)
        case .airport:        return ("airplane", .cyan)
        case .carRental:      return ("car.fill", .cyan)
        case .conventionCenter: return ("person.3.sequence.fill", .cyan)
        case .gasStation:     return ("fuelpump.fill", .cyan)
        case .hotel:          return ("bed.double.fill", .cyan)
        case .parking:        return ("parkingsign.circle.fill", .cyan)
        case .publicTransport:return ("bus.fill", .cyan)
            
        // WATER SPORTS (Blue)
        case .fishing:        return ("fishingpole", .blue)
        case .kayaking:       return ("figure.run.circle", .blue)
        case .surfing:        return ("waveform.path.ecg", .blue)
        case .swimming:       return ("figure.pool.swim", .blue)
            
        // EDUCATION or other categories not in your filter:
        default:
            return ("mappin.and.ellipse", .gray)
        }
    }
}

/// A small wrapper of a route step’s polyline + chosen color.
struct TrafficStepOverlay {
    let polyline: MKPolyline
    let color: UIColor
}

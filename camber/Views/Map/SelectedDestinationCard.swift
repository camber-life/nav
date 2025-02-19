import SwiftUI
import MapKit
import CoreLocation

struct SelectedDestinationCard: View {
    let mapItem: MKMapItem
    var userLocation: CLLocation?
    var navigationSteps: [NavigationStep]  // For routing info
    var onClose: () -> Void
    var onNavigate: () -> Void

    // Store the route's travel time and arrival time (ETA)
    @State private var routeTime: String = "--"
    @State private var eta: String = "--"

    // MARK: - Drag State for the green control.
    @State private var dragOffset: CGFloat = 0

    // Layout constants – adjust these as desired.
    private let buttonHeight: CGFloat = 46       // Fixed height for both green and close buttons.
    private let initialControlWidth: CGFloat = 46  // Green control starts as a square.
    private let cardHeight: CGFloat = 90           // Overall card height.

    // Computed max width and trigger width as screen width minus 30.
    private var maxControlWidth: CGFloat {
        UIScreen.main.bounds.width - 30
    }
    private var triggerWidth: CGFloat {
        UIScreen.main.bounds.width - 30
    }
    
    // Computed current width for the green control.
    private var currentControlWidth: CGFloat {
        initialControlWidth + dragOffset
    }
    
    // Compute drag progress (0 to 1)
    private var dragProgress: CGFloat {
        let maxOffset = maxControlWidth - initialControlWidth
        return dragOffset / maxOffset
    }

    var body: some View {
        // Using a ZStack so that the draggable control can overlay the info section and close button.
        ZStack(alignment: .leading) {
            // Background card content: info text on the left and close button on the right.
            HStack(spacing: 8) {
                leftInfoSection
                    .opacity(1 - dragProgress)
                    .scaleEffect(1 - dragProgress, anchor: .leading)
                    .animation(.easeOut, value: dragOffset)
                    .offset(x: 60)
                Spacer()
                closeButton
                    .opacity(
                        dragOffset > 0
                        ? (dragProgress < 0.8 ? 1 : max(0, 1 - (dragProgress - 0.8) / 0.2))
                        : 1
                    )
            }
            .padding(.horizontal)
            .frame(height: cardHeight)
            
            // Draggable green control (overlaid)
            draggableControl
                .frame(width: currentControlWidth, height: buttonHeight, alignment: .leading)
                .offset(x: 15)
        }
        .frame(height: cardHeight)
        .background(.thickMaterial)
        // Only round the top and bottom corners as desired.
        .clipShape(RoundedCorner(radius: 25))
        .shadow(radius: 5)
        .frame(maxWidth: .infinity)
        .onAppear { fetchRouteTime() }
    }
    
    // MARK: - Draggable Green Control
    private var draggableControl: some View {
        // The control now uses overlays so that the text is perfectly centered.
        Rectangle()
            .fill(Color.green)
            .frame(height: buttonHeight)
            .cornerRadius(15)
            // Center the "Let's Ride" text with equal spacing.
            .overlay(
                Text("Let's Ride")
                    .font(.headline)
                    .foregroundColor(.white)
                    .opacity(min(1, max(0, (dragProgress - 0.2) / 0.6)))
                    .animation(.easeIn, value: dragOffset),
                alignment: .center
            )
            // Motorcycle icon remains pinned to the trailing edge.
            .overlay(
                Image(systemName: "motorcycle")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .padding(.trailing, 6),
                alignment: .trailing
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let delta = value.translation.width
                        // Only allow expansion toward the trailing edge.
                        dragOffset = min(max(delta, 0), maxControlWidth - initialControlWidth)
                    }
                    .onEnded { _ in
                        if currentControlWidth >= triggerWidth {
                            withAnimation(.spring()) {
                                dragOffset = maxControlWidth - initialControlWidth
                            }
                            onNavigate()  // Trigger navigation action.
                        } else {
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                    }
            )
    }
    
    // MARK: - Left Info Section
    private var leftInfoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(mapItem.name ?? streetAddressFor(mapItem.placemark))
                .font(.headline)
                .lineLimit(1)
            // Display the travel time, ETA, and distance.
            Text("\(routeTime) • \(eta) • \(distanceString())")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
    
    // MARK: - Close Button (Trailing)
    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: dragOffset > 0 ? "mappin.and.ellipse" : "xmark")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, dragOffset > 0 ? 12 : 15)
                .padding(.horizontal, dragOffset > 0 ? 14 : 15)
                .background(dragOffset > 0 ? Color.blue : Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 4)
        }
    }
    
    // MARK: - Helpers for Distance, ETA, etc.
    private func distanceString() -> String {
        guard let userLoc = userLocation else { return "-- mi" }
        let dest = CLLocation(latitude: mapItem.placemark.coordinate.latitude,
                              longitude: mapItem.placemark.coordinate.longitude)
        let meters = userLoc.distance(from: dest)
        let miles = meters / 1609.34
        return "\(Int(miles.rounded())) mi"
    }
    
    private func fetchRouteTime() {
        guard let userLoc = userLocation else {
            self.routeTime = "N/A"
            self.eta = "No location"
            return
        }
        let req = MKDirections.Request()
        let userPL = MKPlacemark(coordinate: userLoc.coordinate)
        req.source = MKMapItem(placemark: userPL)
        req.destination = mapItem
        req.transportType = .automobile
        MKDirections(request: req).calculate { resp, err in
            DispatchQueue.main.async {
                if let err = err {
                    print("Error calculating route: \(err.localizedDescription)")
                    self.routeTime = "N/A"
                    self.eta = "ETA unavailable"
                } else if let route = resp?.routes.first {
                    let secs = route.expectedTravelTime
                    // Format the travel time (duration)
                    self.routeTime = formatTime(secs: secs)
                    // Calculate the ETA by adding the travel time to the current time.
                    let arrivalDate = Date().addingTimeInterval(secs)
                    let etaString = DateFormatter.localizedString(from: arrivalDate, dateStyle: .none, timeStyle: .short)
                    self.eta = etaString
                } else {
                    self.routeTime = "N/A"
                    self.eta = "ETA unavailable"
                }
            }
        }
    }
    
    private func formatTime(secs: TimeInterval) -> String {
        let mins = Int(secs / 60)
        if mins >= 60 {
            let hours = mins / 60
            let remainder = mins % 60
            return remainder == 0 ? "\(hours)h" : "\(hours)h \(remainder)m"
        } else {
            return "\(mins)m"
        }
    }
    
    private func streetAddressFor(_ placemark: CLPlacemark) -> String {
        let sub = placemark.subThoroughfare ?? ""
        let thr = placemark.thoroughfare ?? ""
        let street = (sub + " " + thr).trimmingCharacters(in: .whitespaces)
        return street.isEmpty ? "No street" : street
    }
}

struct SelectedItemCard_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let samplePlacemark = MKPlacemark(coordinate: sampleCoordinate)
        let sampleMapItem = MKMapItem(placemark: samplePlacemark)
        sampleMapItem.name = "Sample Destination"
        
        let sampleSteps: [NavigationStep] = [
            NavigationStep(arrowIcon: "arrow.turn.up.right", distance: "0.5 mi", streetName: "Main St", coordinate: CLLocationCoordinate2D(latitude: 37.7750, longitude: -122.4195)),
            NavigationStep(arrowIcon: "arrow.turn.up.left", distance: "1.2 mi", streetName: "2nd Ave", coordinate: CLLocationCoordinate2D(latitude: 37.7760, longitude: -122.4185)),
            NavigationStep(arrowIcon: "flag.fill", distance: "Destination", streetName: "Sample Destination", coordinate: CLLocationCoordinate2D(latitude: 37.7770, longitude: -122.4175))
        ]
        
        return SelectedDestinationCard(
            mapItem: sampleMapItem,
            userLocation: CLLocation(latitude: 37.7749, longitude: -122.4194),
            navigationSteps: sampleSteps,
            onClose: { print("Close tapped") },
            onNavigate: { print("Navigate triggered") }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

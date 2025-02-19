import SwiftUI
import MapKit
import CoreLocation

struct SelectedDestinationCard: View {
    let mapItem: MKMapItem
    var userLocation: CLLocation?
    var navigationSteps: [NavigationStep]  // For routing info
    var onClose: () -> Void
    var onNavigate: () -> Void

    // Route time and ETA state.
    @State private var routeTime: String = "--"
    @State private var eta: String = "--"
    // Store travel time in minutes (for the "min" value)
    @State private var travelTimeInMinutes: Int = 0

    // MARK: - Drag State for the green control (to trigger navigation mode).
    @State private var dragOffset: CGFloat = 0

    // States for controlling overlay expansion.
    @State private var isExpanded: Bool = false       // Controls overall card expansion.
    @State private var hasNavigated: Bool = false       // Used to fade out the green control.
    @State private var showExpandedInfo: Bool = false     // When true, shows the expanded overlay.

    // New states for the red and blue draggable controls (in expanded overlay).
    @State private var redDragOffset: CGFloat = 0
    @State private var blueDragOffset: CGFloat = 0

    // Layout constants.
    private let buttonHeight: CGFloat = 46         // Height for the green control.
    private let initialControlWidth: CGFloat = 46    // Green control starts as a square.
    private let normalCardHeight: CGFloat = 90       // Normal (pre-expanded) card height.
    private let expandedCardHeight: CGFloat = 100    // Fixed height for expanded mode.

    // Constants for the draggable controls in expanded mode.
    private let redMinWidth: CGFloat = 40
    private let blueMinWidth: CGFloat = 40

    // Computed properties for the green draggable control.
    private var maxControlWidth: CGFloat {
        UIScreen.main.bounds.width - 30
    }
    private var triggerWidth: CGFloat {
        UIScreen.main.bounds.width - 30
    }
    private var currentControlWidth: CGFloat {
        initialControlWidth + dragOffset
    }
    private var dragProgress: CGFloat {
        let maxOffset = maxControlWidth - initialControlWidth
        return dragOffset / maxOffset
    }
    
    // Computed miles to destination.
    private var milesToDestination: Int {
        guard let userLoc = userLocation else { return 0 }
        let dest = CLLocation(latitude: mapItem.placemark.coordinate.latitude,
                              longitude: mapItem.placemark.coordinate.longitude)
        let miles = userLoc.distance(from: dest) / 1609.34
        return Int(miles.rounded())
    }
    
    var body: some View {
        ZStack {
            if showExpandedInfo {
                // In expanded mode, show our new overlay with draggable red and blue controls.
                expandedOverlaySection
            } else {
                // Original view: shows the basic info with the green draggable control.
                ZStack(alignment: .leading) {
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
                    .frame(height: normalCardHeight)
                    
                    // Green draggable control (to trigger navigate mode)
                    if !hasNavigated {
                        draggableControl
                            .frame(width: currentControlWidth, height: buttonHeight)
                            .offset(x: 15)
                            .opacity(hasNavigated ? 0 : 1)
                    }
                }
                .frame(height: normalCardHeight)
            }
        }
        .frame(maxWidth: .infinity)
        // Constrain the card’s height.
        .frame(height: showExpandedInfo ? expandedCardHeight : normalCardHeight)
        .background(.thickMaterial)
        .clipShape(RoundedCorner(radius: 25))
        .shadow(radius: 5)
        .onAppear { fetchRouteTime() }
        .animation(.spring(), value: showExpandedInfo)
    }
    
    // MARK: - Green Draggable Control (to trigger navigation mode)
    private var draggableControl: some View {
        Rectangle()
            .fill(Color.green)
            .frame(height: buttonHeight)
            .cornerRadius(15)
            .overlay(
                Text("Let's Ride")
                    .font(.headline)
                    .foregroundColor(.white)
                    .opacity(min(1, max(0, (dragProgress - 0.2) / 0.6)))
                    .animation(.easeIn, value: dragOffset),
                alignment: .center
            )
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
                        // Only allow dragging to the right.
                        dragOffset = min(max(delta, 0), maxControlWidth - initialControlWidth)
                    }
                    .onEnded { _ in
                        if currentControlWidth >= triggerWidth {
                            withAnimation(.spring()) {
                                dragOffset = maxControlWidth - initialControlWidth
                            }
                            withAnimation(.easeIn(duration: 0.3)) {
                                hasNavigated = true
                            }
                            withAnimation(.spring()) {
                                isExpanded = true
                            }
                            // After a short delay, show the expanded overlay.
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring()) {
                                    showExpandedInfo = true
                                }
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
    
    // MARK: - Original Info Section (before expansion)
    private var leftInfoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(mapItem.name ?? streetAddressFor(mapItem.placemark))
                .font(.headline)
                .lineLimit(1)
            Text("\(routeTime) • \(eta) • \(distanceString())")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
    
    // MARK: - Close Button (trailing)
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
    
    // MARK: - Expanded Overlay Section with Draggable Red & Blue Controls
    private var expandedOverlaySection: some View {
        // Use GeometryReader to know the card’s dimensions.
        GeometryReader { geometry in
            let cardWidth = geometry.size.width
            let cardHeight = geometry.size.height
            let redCurrentWidth = redMinWidth + redDragOffset
            let blueCurrentWidth = blueMinWidth + blueDragOffset
            let redProgress = (redCurrentWidth - redMinWidth) / (cardWidth - redMinWidth)
            let blueProgress = (blueCurrentWidth - blueMinWidth) / (cardWidth - blueMinWidth)
            
            ZStack {
                // Central content: Title and info row, with extra horizontal padding.
                VStack(spacing: 16) {
                    Text(mapItem.name ?? streetAddressFor(mapItem.placemark))
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    HStack {
                        VStack {
                            Text("\(travelTimeInMinutes)")
                                .font(.headline)
                            Text("min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        VStack {
                            Text(eta)
                                .font(.headline)
                            Text("arrival")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        VStack {
                            Text("\(milesToDestination)")
                                .font(.headline)
                            Text("mi")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20) // Extra horizontal padding.
                }
                .frame(width: cardWidth, height: cardHeight)
                
                // Red draggable control (for End Route) on the left.
                redDraggableControl(cardWidth: cardWidth, cardHeight: cardHeight, currentWidth: redCurrentWidth, progress: redProgress)
                    .frame(width: redCurrentWidth, height: cardHeight)
                    .position(x: redCurrentWidth / 2, y: cardHeight / 2)
                
                // Blue draggable control (for Add Stop) positioned from the right edge.
                blueDraggableControl(cardWidth: cardWidth, cardHeight: cardHeight, currentWidth: blueCurrentWidth, progress: blueProgress)
                    .frame(width: blueCurrentWidth, height: cardHeight)
                    .position(x: cardWidth - blueCurrentWidth / 2, y: cardHeight / 2)
            }
        }
    }
    
    // MARK: - Red Draggable Control (for End Route)
    private func redDraggableControl(cardWidth: CGFloat, cardHeight: CGFloat, currentWidth: CGFloat, progress: CGFloat) -> some View {
        // Define a threshold (here 80% of card width).
        let threshold = cardWidth * 0.8
        return ZStack {
            Color.red.opacity(0.5 + progress)
            HStack(spacing: 4) {
                Text("End Route")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                    .opacity(progress)
                Spacer()
                Image(systemName: "xmark")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                    .offset(x: -5)
            }
            .padding(.horizontal, 8)
        }
        .cornerRadius(25)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let drag = value.translation.width
                    // Only allow dragging to the right.
                    redDragOffset = min(max(drag, 0), cardWidth - redMinWidth)
                }
                .onEnded { _ in
                    if currentWidth >= threshold {
                        withAnimation {
                            redDragOffset = cardWidth - redMinWidth
                        }
                        // Trigger End Route action.
                        withAnimation {
                            // Reset all overlay states.
                            showExpandedInfo = false
                            isExpanded = false
                            hasNavigated = false
                            dragOffset = 0
                            redDragOffset = 0
                            blueDragOffset = 0
                        }
                        onClose()
                        print("End Route triggered via drag")
                    } else {
                        withAnimation {
                            redDragOffset = 0
                        }
                    }
                }
        )
    }
    
    // MARK: - Blue Draggable Control (for Add Stop)
    private func blueDraggableControl(cardWidth: CGFloat, cardHeight: CGFloat, currentWidth: CGFloat, progress: CGFloat) -> some View {
        let threshold = cardWidth * 0.8
        return ZStack {
            Color.blue.opacity(0.5 + progress)
            // Here the plus icon is pinned on the left side of the blue control.
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                Text("Add Stop")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                    .opacity(progress)
                Spacer()
            }
            .padding(.horizontal, 8)
        }
        .cornerRadius(25)
        .gesture(
            DragGesture()
                .onChanged { value in
                    // For blue control, we want to measure leftward drag.
                    let translation = value.translation.width
                    let expansion = translation < 0 ? -translation : 0
                    blueDragOffset = min(expansion, cardWidth - blueMinWidth)
                }
                .onEnded { _ in
                    if currentWidth >= threshold {
                        withAnimation {
                            blueDragOffset = cardWidth - blueMinWidth
                        }
                        // Trigger Add Stop action.
                        print("Add Stop triggered via drag (present SearchView)")
                        // Reset the blue control.
                        withAnimation {
                            blueDragOffset = 0
                        }
                    } else {
                        withAnimation {
                            blueDragOffset = 0
                        }
                    }
                }
        )
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
                    self.routeTime = formatTime(secs: secs)
                    self.travelTimeInMinutes = Int(secs / 60)
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

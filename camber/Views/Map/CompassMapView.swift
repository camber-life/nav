//
//  CompassMapView.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//

import SwiftUI
import MapKit

///// A UIViewRepresentable that shows the map, routes, and pins.
struct CompassMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var userLocation: CLLocation?
    var heading: CLLocationDirection?
    @Binding var selectedItem: MKMapItem?
    @Binding var allowedCategories: [MKPointOfInterestCategory]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Show user location and force tracking mode to follow heading.
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: false)
        
        // Hide the default compass.
        mapView.showsCompass = false
        
        // Create and add a custom compass button.
        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .visible
        // Disable autoresizing mask to use Auto Layout.
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(compassButton)
        NSLayoutConstraint.activate([
            // Position the compass button 80 points from the top
            // and 16 points from the trailing edge.
            compassButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 120),
            compassButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20)
        ])
        
        mapView.isRotateEnabled = true
        mapView.showsTraffic = true
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: allowedCategories)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.updateRoute(on: mapView,
                                        userLoc: userLocation,
                                        selectedItem: selectedItem)
        if let heading = heading {
            var camera = mapView.camera
            camera.heading = heading
            mapView.setCamera(camera, animated: true)
        }
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: allowedCategories)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CompassMapView
        private var lastSelectedItem: MKMapItem? = nil
        private var currentOverlay: MKOverlay?
        private var destinationAnnotation: MKPointAnnotation?
        
        init(_ parent: CompassMapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            DispatchQueue.main.async { self.parent.region = mapView.region }
        }
        
        func updateRoute(on mapView: MKMapView,
                         userLoc: CLLocation?,
                         selectedItem: MKMapItem?) {
            if userLoc == nil || selectedItem == nil {
                removeOverlayAndPin(from: mapView)
                return
            }
            if selectedItem == lastSelectedItem { return }
            lastSelectedItem = selectedItem
            removeOverlayAndPin(from: mapView)
            let ann = MKPointAnnotation()
            ann.coordinate = selectedItem!.placemark.coordinate
            ann.title = selectedItem!.name
            destinationAnnotation = ann
            mapView.addAnnotation(ann)
            let req = MKDirections.Request()
            let userPL = MKPlacemark(coordinate: userLoc!.coordinate)
            req.source = MKMapItem(placemark: userPL)
            req.destination = selectedItem
            req.transportType = .automobile
            MKDirections(request: req).calculate { [weak self] resp, error in
                guard let self = self else { return }
                if let route = resp?.routes.first {
                    DispatchQueue.main.async {
                        mapView.addOverlay(route.polyline)
                        self.currentOverlay = route.polyline
                        self.fitAndCenterRoute(route, on: mapView)
                    }
                }
            }
        }
        
        private func removeOverlayAndPin(from mapView: MKMapView) {
            if let ov = currentOverlay { mapView.removeOverlay(ov); currentOverlay = nil }
            if let ann = destinationAnnotation { mapView.removeAnnotation(ann); destinationAnnotation = nil }
        }
        
        private func fitAndCenterRoute(_ route: MKRoute, on mapView: MKMapView) {
            let rect = route.polyline.boundingMapRect
            let insets = UIEdgeInsets(top: 60, left: 60, bottom: 300, right: 60)
            mapView.setVisibleMapRect(rect, edgePadding: insets, animated: false)
            let newAltitude = mapView.camera.altitude
            let midpoint = findHalfwayCoordinate(route: route)
            let cam = MKMapCamera(lookingAtCenter: midpoint,
                                  fromDistance: newAltitude,
                                  pitch: 0,
                                  heading: 0)
            mapView.setCamera(cam, animated: true)
        }
        
        private func findHalfwayCoordinate(route: MKRoute) -> CLLocationCoordinate2D {
            let total = route.distance, half = total / 2.0
            let pts = route.polyline.points(), cnt = route.polyline.pointCount
            var distSoFar = 0.0
            for i in 0..<(cnt - 1) {
                let p1 = pts[i], p2 = pts[i+1]
                let segDist = p1.distance(to: p2)
                if distSoFar + segDist >= half {
                    let fraction = (half - distSoFar) / segDist
                    let x = p1.x + fraction*(p2.x - p1.x)
                    let y = p1.y + fraction*(p2.y - p1.y)
                    return MKMapPoint(x: x, y: y).coordinate
                }
                distSoFar += segDist
            }
            return pts[cnt-1].coordinate
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let poly = overlay as? MKPolyline {
                let rend = MKPolylineRenderer(polyline: poly)
                rend.strokeColor = .blue
                rend.lineWidth = 5
                return rend
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            let rid = "TrafficDestPin"
            var pin = mapView.dequeueReusableAnnotationView(withIdentifier: rid) as? MKPinAnnotationView
            if pin == nil {
                pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: rid)
                pin!.canShowCallout = true
                pin!.pinTintColor = .red
            } else { pin!.annotation = annotation }
            return pin
        }
    }
}

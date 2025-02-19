//
//  LocationManager.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import Foundation
import CoreLocation

public class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published public var location: CLLocation?
    @Published public var heading: CLHeading?
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locs: [CLLocation]) {
        if let newLoc = locs.last {
            self.location = newLoc
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = newHeading
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error)")
    }
}

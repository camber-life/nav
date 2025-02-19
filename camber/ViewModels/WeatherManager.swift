//
//  WeatherManager.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import Foundation
import CoreLocation
import WeatherKit
import SwiftUI

public class WeatherManager: ObservableObject {
    @Published public var temperature: Double?
    
    private let weatherService = WeatherService()
    private var lastFetchDate: Date?
    private var lastCoordinate: CLLocationCoordinate2D?
    
    public func updateTemperature(for coordinate: CLLocationCoordinate2D) {
        let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if let last = lastCoordinate {
            let oldLocation = CLLocation(latitude: last.latitude, longitude: last.longitude)
            if newLocation.distance(from: oldLocation) < 100 { return }
        }
        if let lastFetch = lastFetchDate, Date().timeIntervalSince(lastFetch) < 600 { return }
        lastCoordinate = coordinate
        lastFetchDate = Date()
        Task {
            do {
                let weather = try await weatherService.weather(for: newLocation)
                let fahrenheit = weather.currentWeather.temperature.converted(to: .fahrenheit).value
                DispatchQueue.main.async { self.temperature = fahrenheit }
            } catch {
                print("WeatherKit error: \(error)")
            }
        }
    }
}

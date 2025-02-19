//
//  NavigationStepsCardView.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import SwiftUI

struct NavigationStepsCardView: View {
    let steps: [NavigationStep]
    @Binding var currentStepIndex: Int
    private let cardHeight: CGFloat = 160
    
    var body: some View {
        if steps.isEmpty {
            EmptyView()
        } else {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 0) {
                    Image(systemName: steps[currentStepIndex].arrowIcon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.blue)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(steps[currentStepIndex].distance)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(steps[currentStepIndex].streetName)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 12)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .frame(height: cardHeight)
                .background(Color.black)
                .cornerRadius(40)
                .shadow(color: Color.black.opacity(0.8), radius: 12, x: 0, y: 6)
                
                HStack {
                    Button(action: {
                        if currentStepIndex > 0 { currentStepIndex -= 1 }
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {
                        if currentStepIndex < steps.count - 1 { currentStepIndex += 1 }
                    }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .frame(maxHeight: cardHeight, alignment: .bottom)
            }
            .padding(.horizontal, 10)
            .offset(y: 10)
        }
    }
}
// MARK: - SynamicIslandView
/// This small capsule represents your “Dynamic Island.”
struct DynamicIslandView: View {
    var body: some View {
        Capsule()
            .fill(Color.black)
            .frame(width: 120, height: 35)
            .overlay(
                Text("Navigation")
                    .foregroundColor(.white)
                    .font(.subheadline)
            )
            .offset(y: 12)
    }
}

import Foundation
import MapKit

public class NavigationStepsViewModel: ObservableObject {
    @Published public var steps: [NavigationStep] = []
    
    public func calculateRouteSteps(from userLocation: CLLocation?, to destination: MKMapItem?) {
        guard let userLocation = userLocation, let destination = destination else {
            self.steps = []
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        request.destination = destination
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            if let route = response?.routes.first {
                let navSteps: [NavigationStep] = route.steps.filter { !$0.instructions.isEmpty }
                    .map { step in
                        let arrow = self?.arrowIcon(for: step) ?? "arrow.forward"
                        let distance = String(format: "%.1f mi", step.distance / 1609.34)
                        let street = self?.streetName(for: step.instructions) ?? step.instructions
                        // Use the first point in the step's polyline as the coordinate.
                        let coordinate: CLLocationCoordinate2D = {
                            if step.polyline.pointCount > 0 {
                                let firstPoint = step.polyline.points()[0]
                                return firstPoint.coordinate
                            } else {
                                // Fallback: use the destination coordinate.
                                return destination.placemark.coordinate
                            }
                        }()
                        return NavigationStep(arrowIcon: arrow,
                                              distance: distance,
                                              streetName: street,
                                              coordinate: coordinate)
                    }
                DispatchQueue.main.async {
                    self?.steps = navSteps
                }
            }
        }
    }
    
    private func arrowIcon(for step: MKRoute.Step) -> String {
        let ins = step.instructions.lowercased()
        if ins.contains("left") { return "arrow.turn.up.left" }
        if ins.contains("right") { return "arrow.turn.up.right" }
        return "arrow.up"
    }
    
    private func streetName(for instructions: String) -> String {
        if let range = instructions.lowercased().range(of: "onto ") {
            let after = instructions[range.upperBound...]
            return String(after).capitalized
        }
        return instructions
    }
}

public struct NavigationStep: Identifiable {
    public let id = UUID()
    public let arrowIcon: String
    public let distance: String
    public let streetName: String
    public let coordinate: CLLocationCoordinate2D  // <-- Add this property
}

//
//  MapSearchViewModel.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import Foundation
import MapKit

public class MapSearchViewModel: ObservableObject {
    @Published public var searchResults: [MKMapItem] = []
    
    public func search(for query: String, in region: MKCoordinateRegion) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                self.searchResults = response?.mapItems ?? []
            }
        }
    }
}

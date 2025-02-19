//
//  SearchView.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/11/25.
//


//
//  SearchView.swift
//  YourApp
//
//  Created by You on 2023-XX-XX.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @Binding var searchText: String
    @Binding var isPresented: Bool
    @ObservedObject var searchViewModel: MapSearchViewModel
    @Binding var region: MKCoordinateRegion
    
    var userLocation: CLLocation?
    var onSelectItem: (MKMapItem) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                MapSearchBar(searchText: $searchText, isEditing: .constant(true))
                    .padding()
                
                List(searchViewModel.searchResults, id: \.self) { item in
                    SearchResultRow(
                        item: item,
                        userLocation: userLocation,
                        onTap: {
                            onSelectItem(item)
                            isPresented = false
                            searchViewModel.searchResults = []
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                            to: nil, from: nil, for: nil)
                        }
                    )
                }
            }
            .navigationBarTitle("Search", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            })
        }
        .onChange(of: searchText) { newVal in
            searchViewModel.search(for: newVal, in: region)
        }
    }
}

struct MapSearchBar: View {
    @Binding var searchText: String
    @Binding var isEditing: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search destinations", text: $searchText, onEditingChanged: { editing in
                isEditing = editing
            })
            .autocapitalization(.none)
            .disableAutocorrection(true)
            
            if isEditing && !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

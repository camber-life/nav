//
//  ManageFavoritesView.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import SwiftUI
import MapKit

struct ManageFavoritesView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var userFavorites: [FavoriteItem]
    
    @State private var searchText: String = ""
    @State private var showSearchSheet = false
    @StateObject private var searchVM = MapSearchViewModel()
    @State private var searchRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
        span: ContentView.defaultSpan
    )
    
    @State private var editingFavorite: FavoriteItem? = nil
    @State private var selectedSearchResult: MKMapItem? = nil
    @State private var showFavoriteDetail = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Home & Work") {
                    if let homeIndex = userFavorites.firstIndex(where: { $0.label == "Home" }) {
                        FavoriteRow(favorite: userFavorites[homeIndex]) {
                            editingFavorite = userFavorites[homeIndex]
                            showSearchSheet = true
                        }
                    } else {
                        let placeholder = FavoriteItem(iconName: "house.fill", label: "Home", color: .blue)
                        FavoriteRow(favorite: placeholder) {
                            editingFavorite = placeholder
                            showSearchSheet = true
                        }
                    }
                    
                    if let workIndex = userFavorites.firstIndex(where: { $0.label == "Work" }) {
                        FavoriteRow(favorite: userFavorites[workIndex]) {
                            editingFavorite = userFavorites[workIndex]
                            showSearchSheet = true
                        }
                    } else {
                        let placeholder = FavoriteItem(iconName: "briefcase.fill", label: "Work", color: .brown)
                        FavoriteRow(favorite: placeholder) {
                            editingFavorite = placeholder
                            showSearchSheet = true
                        }
                    }
                }
                
                Section("Custom Favorites") {
                    ForEach(userFavorites.filter { $0.label != "Home" && $0.label != "Work" }, id: \.id) { fav in
                        FavoriteRow(favorite: fav) {
                            editingFavorite = fav
                            showSearchSheet = true
                        }
                    }
                    .onDelete { offsets in userFavorites.remove(atOffsets: offsets) }
                    
                    Button("Add New Favorite") {
                        let newFav = FavoriteItem(iconName: "mappin.circle.fill", label: "New Favorite", color: .gray)
                        editingFavorite = newFav
                        showSearchSheet = true
                    }
                }
            }
            .navigationTitle("Manage Favorites")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showSearchSheet) {
                SearchView(searchText: $searchText,
                           isPresented: $showSearchSheet,
                           searchViewModel: searchVM,
                           region: $searchRegion,
                           userLocation: nil) { mapItem in
                    selectedSearchResult = mapItem
                    showSearchSheet = false
                    showFavoriteDetail = true
                }
            }
            .sheet(isPresented: $showFavoriteDetail) {
                if let fav = editingFavorite, let mapItem = selectedSearchResult {
                    FavoriteDetailView(favorite: fav,
                                       mapItem: mapItem,
                                       userFavorites: $userFavorites,
                                       onSave: { updatedFav in
                        if updatedFav.label == "Home" {
                            if let i = userFavorites.firstIndex(where: { $0.label == "Home" }) {
                                userFavorites[i] = updatedFav
                            } else { userFavorites.append(updatedFav) }
                        } else if updatedFav.label == "Work" {
                            if let i = userFavorites.firstIndex(where: { $0.label == "Work" }) {
                                userFavorites[i] = updatedFav
                            } else { userFavorites.append(updatedFav) }
                        } else {
                            if let i = userFavorites.firstIndex(where: { $0.id == fav.id }) {
                                userFavorites[i] = updatedFav
                            } else { userFavorites.append(updatedFav) }
                        }
                        showFavoriteDetail = false
                    },
                                       onCancel: { showFavoriteDetail = false })
                } else {
                    Text("No selection made.").padding()
                }
            }
            .onAppear { ensureHomeWorkExist() }
        }
    }
    
    private func ensureHomeWorkExist() {
        if !userFavorites.contains(where: { $0.label == "Home" }) {
            let home = FavoriteItem(iconName: "house.fill", label: "Home", color: .blue)
            userFavorites.append(home)
        }
        if !userFavorites.contains(where: { $0.label == "Work" }) {
            let work = FavoriteItem(iconName: "briefcase.fill", label: "Work", color: .brown)
            userFavorites.append(work)
        }
    }
}

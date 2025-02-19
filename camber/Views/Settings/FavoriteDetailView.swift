//
//  FavoriteDetailView.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import SwiftUI
import MapKit

struct FavoriteDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State var favorite: FavoriteItem
    let mapItem: MKMapItem
    @Binding var userFavorites: [FavoriteItem]
    let onSave: (FavoriteItem) -> Void
    let onCancel: () -> Void
    
    var cityState: String {
        let c = mapItem.placemark.locality ?? ""
        let s = mapItem.placemark.administrativeArea ?? ""
        return "\(c), \(s)"
    }
    
    let possibleColors: [Color] = [.gray, .blue, .brown, .green, .pink, .purple, .mint, .orange, .yellow, .cyan]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Enter a name", text: $favorite.label)
                }
                Section(header: Text("Address")) {
                    Text(mapItem.name ?? "Unknown").font(.headline)
                    Text(streetAddressFor(mapItem.placemark))
                    Text(cityState)
                }
                Section(header: Text("Color")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(possibleColors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: favorite.color == color ? 3 : 0)
                                    )
                                    .onTapGesture { favorite.color = color }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favorite Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel(); dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        favorite.address = streetAddressFor(mapItem.placemark)
                        favorite.city = mapItem.placemark.locality
                        favorite.state = mapItem.placemark.administrativeArea
                        let coord = mapItem.placemark.coordinate
                        favorite.latitude = coord.latitude
                        favorite.longitude = coord.longitude
                        onSave(favorite)
                        dismiss()
                    }
                }
            }
        }
    }
    
    func streetAddressFor(_ placemark: CLPlacemark) -> String {
        let sub = placemark.subThoroughfare ?? ""
        let thr = placemark.thoroughfare ?? ""
        let st = (sub + " " + thr).trimmingCharacters(in: .whitespaces)
        return st.isEmpty ? "No street" : st
    }
}

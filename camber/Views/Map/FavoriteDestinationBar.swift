//
//  FavoriteDestinationBar.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import SwiftUI
import MapKit

struct FavoriteDestinationBar: View {
    @Binding var showFavorites: Bool
    @Binding var userFavorites: [FavoriteItem]
    let onSelectFavorite: (MKMapItem) -> Void
    
    private let expandedWidth = UIScreen.main.bounds.width - 30
    private let expandedHeight: CGFloat = 76
    
    var body: some View {
        if showFavorites {
            HStack(spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        if let home = userFavorites.first(where: { $0.label == "Home" }) {
                            FavoriteButton(fav: home, fallbackIcon: "house.fill", fallbackColor: .blue)
                        } else {
                            FavoriteButton(fav: nil, fallbackIcon: "house.fill", fallbackColor: .blue)
                        }
                        if let work = userFavorites.first(where: { $0.label == "Work" }) {
                            FavoriteButton(fav: work, fallbackIcon: "briefcase.fill", fallbackColor: .brown)
                        } else {
                            FavoriteButton(fav: nil, fallbackIcon: "briefcase.fill", fallbackColor: .brown)
                        }
                        ForEach(userFavorites.filter { $0.label != "Home" && $0.label != "Work" }, id: \.id) { fav in
                            FavoriteButton(fav: fav, fallbackIcon: nil, fallbackColor: .gray)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                Spacer(minLength: 8)
                Button(action: { withAnimation { showFavorites = false } }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(15)
                        .background(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 4)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(width: expandedWidth, height: expandedHeight)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(radius: 4)
            .transition(.move(edge: .trailing))
            .offset(x: 10)

        } else {
            Button(action: { withAnimation { showFavorites = true } }) {
                Image(systemName: "star.circle")
                    .offset(x: -15)
                    .font(.title2)
                    .padding(25)
                    .foregroundStyle(Color.white)
                    .background(Color.yellow.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 4)
            }
            .offset(x: 200)
        }
    }
}

extension FavoriteDestinationBar {
    @ViewBuilder
    private func FavoriteButton(fav: FavoriteItem?, fallbackIcon: String?, fallbackColor: Color) -> some View {
        Button(action: {
            if let item = fav?.toMapItem() {
                onSelectFavorite(item)
            }
        }) {
            if let f = fav {
                DestinationCircleIcon(systemName: f.iconName, label: f.label, color: f.color)
            } else if let fallbackIcon = fallbackIcon {
                DestinationCircleIcon(systemName: fallbackIcon, label: "Set Address", color: fallbackColor)
            }
        }
    }
}

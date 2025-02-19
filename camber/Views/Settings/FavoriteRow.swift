//
//  FavoriteRow.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import SwiftUI

struct FavoriteRow: View {
    let favorite: FavoriteItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    if favorite.address == nil {
                        Circle().fill(Color(.systemGray4)).frame(width: 40, height: 40)
                    } else {
                        Circle().fill(favorite.color).frame(width: 40, height: 40)
                    }
                    Image(systemName: favorite.iconName)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(favorite.label).font(.headline)
                    if let a = favorite.address, let c = favorite.city, let s = favorite.state {
                        Text("\(a), \(c), \(s)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Set Address")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }
}

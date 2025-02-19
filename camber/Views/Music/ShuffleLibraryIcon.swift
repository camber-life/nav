//
//  ShuffleLibraryIcon.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/11/25.
//


import SwiftUI

/// A simple “Shuffle Library” tile with a gradient background and text in the center.
struct ShuffleLibraryIcon: View {
    var body: some View {
        ZStack(alignment: .center) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.gray,
                    Color(white: 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 100, height: 100)
            .cornerRadius(12)
            
            Text("Shuffle\nLibrary")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(6)
        }
    }
}
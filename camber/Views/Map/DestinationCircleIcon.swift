//
//  DestinationCircleIcon.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import SwiftUI

struct DestinationCircleIcon: View {
    let systemName: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44)
                Image(systemName: systemName)
                    .foregroundColor(.white)
                    .font(.title3)
            }
            Text(label)
                .font(.caption2).bold()
                .foregroundColor(.primary)
        }
    }
}

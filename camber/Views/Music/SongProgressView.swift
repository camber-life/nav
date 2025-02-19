//
//  SongProgressView.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import SwiftUI

struct SongProgressView: View {
    let progress: Double
    let currentTime: TimeInterval
    let duration: TimeInterval
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 6)
                    .foregroundColor(Color.gray.opacity(0.5))
                Capsule()
                    .frame(width: CGFloat(progress) * UIScreen.main.bounds.width, height: 6)
                    .foregroundColor(.white)
            }
            HStack {
                Text(timeFormatted(currentTime))
                Spacer()
                Text(timeFormatted(duration))
            }
            .font(.caption)
            .foregroundColor(.white)
        }
        .frame(height: 30)
    }
    
    func timeFormatted(_ totalSeconds: TimeInterval) -> String {
        guard totalSeconds.isFinite else { return "0:00" }
        let seconds = Int(totalSeconds) % 60
        let minutes = Int(totalSeconds) / 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
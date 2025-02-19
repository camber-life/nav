//
//  PlaylistItemView.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/11/25.
//


import SwiftUI
import MediaPlayer

/// Displays a playlist icon (gradient) with the playlist’s name.
struct PlaylistItemView: View {
    var playlist: MPMediaPlaylist
    var seed: String
    
    var body: some View {
        DefaultPlaylistIcon(playlistName: playlist.name ?? "Unknown", seed: seed)
    }
}

// MARK: - DefaultPlaylistIcon
struct DefaultPlaylistIcon: View {
    let playlistName: String
    let seed: String
    
    private let gradientOptions: [(CGSize) -> AnyView] = [
        { size in AnyView(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue, Color.green]),
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing)
            .frame(width: size.width, height: size.height)) },
        { size in AnyView(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow]),
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing)
            .frame(width: size.width, height: size.height)) },
        { size in AnyView(LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.pink, Color.cyan]),
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing)
            .frame(width: size.width, height: size.height)) },
        { size in AnyView(LinearGradient(gradient: Gradient(colors: [Color.teal, Color.mint, Color.blue]),
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing)
            .frame(width: size.width, height: size.height)) },
        { size in AnyView(AngularGradient(gradient: Gradient(colors: [Color.mint, Color.orange, Color.purple]),
                                          center: .center)
            .frame(width: size.width, height: size.height)) },
        { size in AnyView(RadialGradient(gradient: Gradient(colors: [Color.yellow, Color.red, Color.black]),
                                         center: .center,
                                         startRadius: 0,
                                         endRadius: size.width / 2)
            .frame(width: size.width, height: size.height)) },
        { size in AnyView(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue, Color.purple, Color.pink]),
                                         startPoint: .bottomLeading,
                                         endPoint: .topTrailing)
            .frame(width: size.width, height: size.height)) },
        { size in AnyView(AngularGradient(gradient: Gradient(colors: [Color.orange, Color.red, Color.yellow, Color.orange]),
                                          center: .center)
            .frame(width: size.width, height: size.height)) },
        { size in AnyView(RadialGradient(gradient: Gradient(colors: [Color.blue, Color.gray, Color.black]),
                                         center: .center,
                                         startRadius: 0,
                                         endRadius: size.width / 2)
            .frame(width: size.width, height: size.height)) },
        { size in AnyView(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple, Color.indigo, Color.blue]),
                                         startPoint: .leading,
                                         endPoint: .trailing)
            .frame(width: size.width, height: size.height)) },
        { size in AnyView(AngularGradient(gradient: Gradient(colors: [Color.yellow, Color.orange, Color.red, Color.pink]),
                                          center: .center)
            .frame(width: size.width, height: size.height)) },
        { size in AnyView(LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.teal, Color.blue]),
                                         startPoint: .top,
                                         endPoint: .bottom)
            .frame(width: size.width, height: size.height)) },
        { size in AnyView(RadialGradient(gradient: Gradient(colors: [Color.orange, Color.mint, Color.purple]),
                                         center: .center,
                                         startRadius: 0,
                                         endRadius: size.width / 2)
            .frame(width: size.width, height: size.height)) }
    ]
    
    private var gradientView: some View {
        let index = abs(seed.hashValue) % gradientOptions.count
        return gradientOptions[index](CGSize(width: 100, height: 100))
    }
    
    private var lines: [String] {
        let words = playlistName.split(separator: " ").map { String($0) }
        guard words.count > 1 else { return [playlistName] }
        
        var result: [String] = []
        var i = 0
        while i < words.count {
            if i < words.count - 1, words[i].count == 3, words[i+1].count == 3 {
                result.append(words[i] + " " + words[i+1])
                i += 2
            } else {
                result.append(words[i])
                i += 1
            }
        }
        return result
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            gradientView
                .cornerRadius(12)
            VStack(alignment: .leading, spacing: 2) {
                let firstWord = lines.first?.split(separator: " ").first ?? ""
                ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                    if index == 0 {
                        Text(line)
                            .font(firstWord.count >= 10 ? .subheadline : .headline)
                            .fontWeight(.heavy)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    } else {
                        Text(line)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
            }
            .padding(6)
        }
        .frame(width: 100, height: 100)
    }
}

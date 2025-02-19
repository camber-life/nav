////
////  MusicPlayerViewModel 2.swift
////  camber
////
////  Created by Roddy Gonzalez on 2/15/25.
////
//
//
//import Foundation
//import MediaPlayer
//import SwiftUI
//
//class MusicPlayerViewModel: ObservableObject {
//    @Published var playbackState: MPMusicPlaybackState = .stopped
//    @Published var nowPlayingAlbumCover: UIImage? = nil
//    @Published var currentSongTitle: String = ""
//    @Published var currentArtistName: String = ""
//    
//    private var player = MPMusicPlayerController.systemMusicPlayer
//    
//    init() {
//        self.playbackState = player.playbackState
//        updateNowPlayingInfo()
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(playbackStateChanged),
//                                               name: .MPMusicPlayerControllerPlaybackStateDidChange,
//                                               object: player)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(nowPlayingItemChanged),
//                                               name: .MPMusicPlayerControllerNowPlayingItemDidChange,
//                                               object: player)
//        player.beginGeneratingPlaybackNotifications()
//    }
//    
//    @objc private func playbackStateChanged() {
//        DispatchQueue.main.async {
//            self.playbackState = self.player.playbackState
//            self.updateNowPlayingInfo()
//        }
//    }
//    
//    @objc private func nowPlayingItemChanged() {
//        DispatchQueue.main.async {
//            self.updateNowPlayingInfo()
//        }
//    }
//    
//    private func updateNowPlayingInfo() {
//        if let nowPlaying = player.nowPlayingItem {
//            if let artwork = nowPlaying.artwork,
//               let image = artwork.image(at: CGSize(width: 300, height: 300)) {
//                self.nowPlayingAlbumCover = image
//            } else {
//                self.nowPlayingAlbumCover = nil
//            }
//            self.currentSongTitle = nowPlaying.title ?? ""
//            self.currentArtistName = nowPlaying.artist ?? ""
//        } else {
//            self.nowPlayingAlbumCover = nil
//            self.currentSongTitle = ""
//            self.currentArtistName = ""
//        }
//    }
//    
//    deinit {
//        player.endGeneratingPlaybackNotifications()
//        NotificationCenter.default.removeObserver(self)
//    }
//}

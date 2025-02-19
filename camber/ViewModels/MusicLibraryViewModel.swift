//
//  MusicLibraryViewModel.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import Foundation
import MediaPlayer

public class MusicLibraryViewModel: ObservableObject {
    @Published public var playlists: [MPMediaPlaylist] = []
    
    public init() {
        requestAuthorization()
    }
    
    public func requestAuthorization() {
        MPMediaLibrary.requestAuthorization { status in
            if status == .authorized {
                self.fetchPlaylists()
            } else {
                print("Not authorized to access music library")
            }
        }
    }
    
    public func fetchPlaylists() {
        let query = MPMediaQuery.playlists()
        if let collections = query.collections as? [MPMediaPlaylist] {
            DispatchQueue.main.async {
                self.playlists = collections
            }
        }
    }
}

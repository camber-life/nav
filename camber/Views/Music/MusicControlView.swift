import SwiftUI
import MediaPlayer

struct MusicControlView: View {
    @EnvironmentObject var musicPlayerViewModel: MusicPlayerViewModel
    @EnvironmentObject var musicLibraryViewModel: MusicLibraryViewModel
    
    // Controls whether the playlist (or now placeholder) is showing.
    @Binding var showPlaylistSelector: Bool
    // The currently selected service from MusicServiceBar.
    @Binding var selectedService: MusicServiceBar.MusicService

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var refreshFlag: Bool = false

    var currentPlaybackTime: TimeInterval {
        MPMusicPlayerController.systemMusicPlayer.currentPlaybackTime
    }
    var playbackDuration: TimeInterval {
        MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.playbackDuration ?? 0
    }
    var playbackProgress: Double {
        guard playbackDuration > 0 else { return 0 }
        return currentPlaybackTime / playbackDuration
    }
    
    var body: some View {
        ZStack {
            backgroundView
                .padding(.bottom, -25)
            
            // The song info and progress view (which fade out when the selector is showing).
            controlModeView
                .offset(y: 35)
            
            // When the playlist selector is visible, show either the playlist
            // (for Apple Music) or a placeholder (for Spotify) with differing transitions.
            if showPlaylistSelector {
                Group {
                    if selectedService == .apple {
                        playlistView
                            .transition(.move(edge: .leading))
                    } else if selectedService == .spotify {
                        spotifyPlaceholderView
                            .transition(.move(edge: .trailing))
                    }
                }
                .offset(y: 40)
            }
        }
        .frame(height: 225)
        .onReceive(timer) { _ in refreshFlag.toggle() }
        // Animate changes when either binding toggles.
        .animation(.easeInOut, value: showPlaylistSelector)
        .animation(.easeInOut, value: selectedService)
    }
    
    // MARK: - Subviews
    
    private var backgroundView: some View {
        ZStack {
            if let cover = musicPlayerViewModel.nowPlayingAlbumCover {
                let blurRadius = musicPlayerViewModel.playbackState == .playing ? 3 : 7
                Image(uiImage: cover)
                    .resizable()
                    .scaledToFill()
                    .saturation(playbackProgress)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .blur(radius: CGFloat(blurRadius))
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                Color.black
            }
            Color.white.opacity(0.02)
                .blur(radius: 5)
        }
    }
    
    private var controlModeView: some View {
        GeometryReader { geo in
            VStack(spacing: 8) {
                Spacer(minLength: geo.size.height * 0.33)
                
                // This group contains the song title, artist, and progress view.
                Group {
                    if !musicPlayerViewModel.currentSongTitle.isEmpty {
                        let song = cleanSongTitle(musicPlayerViewModel.currentSongTitle)
                        VStack(spacing: 4) {
                            Text(song)
                                .font(song.count > 30 ? .title2 : .title)
                                .bold()
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            if !musicPlayerViewModel.currentArtistName.isEmpty {
                                let artist = musicPlayerViewModel.currentArtistName
                                Text(artist)
                                    .font(artist.count > 50 ? .subheadline : (artist.count > 40 ? .headline : (artist.count > 30 ? .title3 : .title2)))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    
                    Spacer().frame(height: 15)
                    
                    SongProgressView(progress: playbackProgress,
                                     currentTime: currentPlaybackTime,
                                     duration: playbackDuration)
                        .padding(.horizontal)
                }
                // When the playlist selector is showing, fade out (opacity 0) and slightly scale down.
                .scaleEffect(showPlaylistSelector ? 0.8 : 1.0)
                .opacity(showPlaylistSelector ? 0.0 : 1.0)
                .animation(.easeInOut, value: showPlaylistSelector)
                
                Spacer()
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .contentShape(Rectangle())
            .highPriorityGesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        if value.translation.width > 75 {
                            previousTrack()
                        } else if value.translation.width < -75 {
                            nextTrack()
                        }
                    }
            )
            .onTapGesture { togglePlayPause() }
        }
    }
    
    private var playlistView: some View {
        VStack {
            Spacer()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ShuffleLibraryIcon()
                        .onTapGesture { shuffleAllSongs() }
                    ForEach(Array(musicLibraryViewModel.playlists.enumerated()), id: \.element.persistentID) { index, playlist in
                        PlaylistItemView(playlist: playlist, seed: "\(playlist.persistentID)-\(index)")
                            .onTapGesture {
                                let player = MPMusicPlayerController.systemMusicPlayer
                                player.setQueue(with: playlist)
                                player.shuffleMode = .songs
                                player.play()
                            }
                    }
                }
                .padding(.horizontal)
            }
            Spacer()
        }
    }
    
    private var spotifyPlaceholderView: some View {
        VStack {
            Spacer()
            Text("Spotify coming soon")
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    // MARK: - Music Player Control Methods
    
    func previousTrack() {
        MPMusicPlayerController.systemMusicPlayer.skipToPreviousItem()
    }
    
    func togglePlayPause() {
        let player = MPMusicPlayerController.systemMusicPlayer
        if musicPlayerViewModel.playbackState == .playing {
            player.pause()
        } else {
            player.play()
        }
    }
    
    func nextTrack() {
        MPMusicPlayerController.systemMusicPlayer.skipToNextItem()
    }
    
    func shuffleAllSongs() {
        let query = MPMediaQuery.songs()
        let player = MPMusicPlayerController.systemMusicPlayer
        player.setQueue(with: query)
        player.shuffleMode = .songs
        player.play()
    }
    
    private func cleanSongTitle(_ title: String) -> String {
        var cleaned = title.replacingOccurrences(of: "\\(.*?\\)", with: "", options: .regularExpression)
        cleaned = cleaned.replacingOccurrences(of: "\\[.*?\\]", with: "", options: .regularExpression)
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

class MusicPlayerViewModel: ObservableObject {
    @Published var playbackState: MPMusicPlaybackState = .stopped
    @Published var nowPlayingAlbumCover: UIImage? = nil
    @Published var currentSongTitle: String = ""
    @Published var currentArtistName: String = ""
    
    private var player = MPMusicPlayerController.systemMusicPlayer
    
    // Cache artwork per track (keyed by persistentID)
    private var albumArtworkCache: [MPMediaEntityPersistentID: UIImage] = [:]
    // Track the current track’s persistentID
    private var currentNowPlayingID: MPMediaEntityPersistentID?
    
    init() {
        self.playbackState = player.playbackState
        updateNowPlayingInfo()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playbackStateChanged),
                                               name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                               object: player)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(nowPlayingItemChanged),
                                               name: .MPMusicPlayerControllerNowPlayingItemDidChange,
                                               object: player)
        player.beginGeneratingPlaybackNotifications()
    }
    
    @objc private func playbackStateChanged() {
        DispatchQueue.main.async {
            self.playbackState = self.player.playbackState
            self.updateNowPlayingInfo()
        }
    }
    
    @objc private func nowPlayingItemChanged() {
        DispatchQueue.main.async {
            self.updateNowPlayingInfo()
        }
    }
    
    private func updateNowPlayingInfo() {
        guard let nowPlaying = player.nowPlayingItem else {
            // No song playing – clear details.
            self.nowPlayingAlbumCover = nil
            self.currentSongTitle = ""
            self.currentArtistName = ""
            return
        }
        
        let newTrackID = nowPlaying.persistentID
        self.currentSongTitle = nowPlaying.title ?? ""
        self.currentArtistName = nowPlaying.artist ?? ""
        
        // Only update if the track really changed.
        if currentNowPlayingID != newTrackID {
            currentNowPlayingID = newTrackID
            
            // If we already fetched this track’s artwork, use it.
            if let cachedImage = albumArtworkCache[newTrackID] {
                self.nowPlayingAlbumCover = cachedImage
            } else {
                // Optionally, you could clear the cover here to avoid showing the old one:
                // self.nowPlayingAlbumCover = nil
                fetchArtwork(for: nowPlaying)
            }
        }
    }
    
    private func fetchArtwork(for nowPlaying: MPMediaItem) {
        let trackID = nowPlaying.persistentID
        // Attempt to fetch artwork at a desired size.
        if let artwork = nowPlaying.artwork,
           let image = artwork.image(at: CGSize(width: 300, height: 300)) {
            // Cache the image.
            albumArtworkCache[trackID] = image
            // Only update the published image if this track is still current.
            if currentNowPlayingID == trackID {
                DispatchQueue.main.async {
                    self.nowPlayingAlbumCover = image
                }
            }
        } else {
            // Artwork isn’t available yet; retry after a short delay.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Only retry if the track hasn't changed.
                if let currentItem = self.player.nowPlayingItem,
                   currentItem.persistentID == trackID {
                    self.fetchArtwork(for: nowPlaying)
                }
            }
        }
    }
    
    deinit {
        player.endGeneratingPlaybackNotifications()
        NotificationCenter.default.removeObserver(self)
    }
}

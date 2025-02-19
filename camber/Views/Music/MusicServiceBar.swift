import SwiftUI

struct MusicServiceBar: View {
    // Controls whether the expanded bar is visible.
    @Binding var showMusicServices: Bool
    @Binding var showPlaylistSelector: Bool
    // The currently selected music service.
    @Binding var selectedService: MusicService

    private let expandedWidth = UIScreen.main.bounds.width - 30
    private let expandedHeight: CGFloat = 65

    enum MusicService: String, CaseIterable, Identifiable {
        case apple = "Apple Music"
        case spotify = "Spotify"
        var id: String { self.rawValue }
        var icon: String {
            switch self {
            case .apple:
                return "applelogo" // SF Symbol for Apple logo
            case .spotify:
                return "music.note" // You could use a custom image if available
            }
        }
    }

    var body: some View {
        if showMusicServices {
            HStack(spacing: 12) {
                ForEach(MusicService.allCases) { service in
                    MusicServiceButton(service: service, isSelected: service == selectedService)
                        .onTapGesture {
                            withAnimation {
                                selectedService = service
                            }
                        }
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        showMusicServices.toggle()
                    }
                    showPlaylistSelector.toggle()
                }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(15)
                        .background(Color.red)
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
            .offset(x: -190)
        } else {
            Button(action: {
                withAnimation {
                    showMusicServices.toggle()
                }
                showPlaylistSelector.toggle()
            }) {
                Image(systemName: "play.circle")
                    .offset(x: -15)
                    .font(.title2)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 25)
                    .foregroundStyle(Color.white)
                    .background(Color.pink.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 4)
            }
            .offset(x: 0)
        }
    }
}

struct MusicServiceButton: View {
    let service: MusicServiceBar.MusicService
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: service.icon)
                .font(.title2)
            Text(service.rawValue)
                .font(.headline)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(isSelected ? Color.white.opacity(0.3) : Color.clear)
        .clipShape(Capsule())
    }
}

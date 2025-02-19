import SwiftUI
import MediaPlayer
import AuthenticationServices
import CryptoKit

struct ManageMusicView: View {
    // Linked state for each service
    @State private var appleLinked: Bool = false
    @State private var spotifyLinked: Bool = false
    @State private var amazonLinked: Bool = false
    @State private var pandoraLinked: Bool = false
    @State private var youtubeLinked: Bool = false
    @State private var defaultMusicService: MusicService = .apple
    
    // Spotify auth session & code verifier storage
    @State private var authSession: ASWebAuthenticationSession?
    @State private var spotifyCodeVerifier: String = ""
    
    enum MusicService: String, CaseIterable, Identifiable {
        case apple = "Apple Music"
        case spotify = "Spotify"
        case amazon = "Amazon Music"
        case pandora = "Pandora"
        case youtube = "YouTube Music"
        
        var id: String { rawValue }
        
        // Use asset catalog image names
        var imageName: String {
            switch self {
            case .apple:
                return "AppleMusic"
            case .spotify:
                return "Spotify"
            case .amazon:
                return "AmazonMusic"
            case .pandora:
                return "Pandora"
            case .youtube:
                return "YouTubeMusic"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(MusicService.allCases) { service in
                SettingsMusicServiceButton(
                    service: service,
                    isLinked: isLinked(service),
                    isDefault: service == defaultMusicService,
                    action: {
                        if service == .apple {
                            // Handle Apple Music linking
                            if MPMediaLibrary.authorizationStatus() == .authorized {
                                appleLinked = true
                                defaultMusicService = service
                            } else {
                                MPMediaLibrary.requestAuthorization { status in
                                    DispatchQueue.main.async {
                                        if status == .authorized {
                                            appleLinked = true
                                            defaultMusicService = service
                                        }
                                    }
                                }
                            }
                        } else if service == .spotify {
                            // Initiate Spotify OAuth flow
                            startSpotifyAuth()
                        } else {
                            // Simulate linking for Amazon, Pandora, and YouTube Music
                            if !isLinked(service) {
                                link(service)
                            } else {
                                defaultMusicService = service
                            }
                        }
                    }
                )
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Music Settings")
        .onAppear {
            // Check Apple Music authorization on appear.
            if MPMediaLibrary.authorizationStatus() == .authorized {
                appleLinked = true
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func isLinked(_ service: MusicService) -> Bool {
        switch service {
        case .apple:   return appleLinked
        case .spotify: return spotifyLinked
        case .amazon:  return amazonLinked
        case .pandora: return pandoraLinked
        case .youtube: return youtubeLinked
        }
    }
    
    private func link(_ service: MusicService) {
        switch service {
        case .apple:   appleLinked = true
        case .spotify: spotifyLinked = true
        case .amazon:  amazonLinked = true
        case .pandora: pandoraLinked = true
        case .youtube: youtubeLinked = true
        }
        defaultMusicService = service
    }
    
    // MARK: - Spotify Authentication
    
    /// Starts the Spotify OAuth flow using ASWebAuthenticationSession.
    func startSpotifyAuth() {
        // Generate a random code verifier and corresponding code challenge
        let codeVerifier = randomString(length: 128)
        let codeChallenge = self.codeChallenge(from: codeVerifier)
        spotifyCodeVerifier = codeVerifier
        
        // Build the Spotify authorization URL
        let clientID = "9228ec8b87d2437a8c96c499b1ff4709"  // Replace with your client ID
        let redirectURI = "camber://callback"      // Must match your URL type in Info.plist
        let scope = "playlist-read-private user-library-read"
        let state = UUID().uuidString
        let authURLString = "https://accounts.spotify.com/authorize?response_type=code&client_id=\(clientID)&redirect_uri=\(redirectURI)&scope=\(scope)&state=\(state)&code_challenge=\(codeChallenge)&code_challenge_method=S256"
        
        guard let authURL = URL(string: authURLString) else { return }
        
        // Initialize the session with the correct callback URL scheme ("camber")
        authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "camber") { callbackURL, error in
            if let error = error {
                print("Spotify auth error: \(error)")
                return
            }
            if let callbackURL = callbackURL,
               let queryItems = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems,
               let code = queryItems.first(where: { $0.name == "code" })?.value {
                // Exchange the authorization code for an access token.
                exchangeCodeForToken(code: code, codeVerifier: codeVerifier)
            }
        }
        // Set the presentation context provider before starting the session.
        authSession?.presentationContextProvider = AuthenticationContextProvider()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.authSession?.start()
        }
    }
    
    /// Exchanges the authorization code for an access token.
    func exchangeCodeForToken(code: String, codeVerifier: String) {
        let clientID = "9228ec8b87d2437a8c96c499b1ff4709"  // Replace with your client ID
        let tokenURL = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        
        let parameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": "camber://callback",
            "client_id": clientID,
            "code_verifier": codeVerifier
        ]
        let bodyString = parameters.compactMap { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Token exchange error: \(error)")
                return
            }
            guard let data = data else {
                print("No data in token exchange")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Spotify token response: \(json)")
                    if let _ = json["access_token"] as? String {
                        DispatchQueue.main.async {
                            spotifyLinked = true
                            defaultMusicService = .spotify
                            // Save the access token securely for subsequent API calls.
                        }
                    }
                }
            } catch {
                print("Error parsing token response: \(error)")
            }
        }.resume()
    }
    
    /// Generates a random alphanumeric string of the given length.
    func randomString(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
    
    /// Generates a code challenge from a code verifier using SHA256 and base64 URL encoding.
    func codeChallenge(from codeVerifier: String) -> String {
        let data = Data(codeVerifier.utf8)
        let hashed = SHA256.hash(data: data)
        let hashData = Data(hashed)
        let base64 = hashData.base64EncodedString()
        let safeBase64 = base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return safeBase64
    }
}

// MARK: - Helper: Authentication Context Provider

class AuthenticationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
        print("Connected Scenes: \(scenes)")
        if let windowScene = scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            print("Found key window: \(window)")
            return window
        }
        print("No key window found, returning a fallback window.")
        return UIWindow()  // This fallback is not ideal.
    }
}

struct SettingsMusicServiceButton: View {
    let service: ManageMusicView.MusicService
    let isLinked: Bool
    let isDefault: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Service Icon from the asset catalog
                Image(service.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                
                Text(service.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Show capsule on trailing edge:
                if isLinked {
                    if isDefault {
                        Text("Default")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.blue))
                    }
                } else {
                    Text("Link Account")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.red))
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(12)
        }
    }
}

struct ManageMusicView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ManageMusicView()
        }
    }
}

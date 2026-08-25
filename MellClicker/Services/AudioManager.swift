import AVFoundation
import UIKit

/// High-performance audio manager managing concurrent, low-latency audio playback
/// for `tap.mp3` and `chekunec.mp3` using AVFoundation without blocking the main thread.
final class AudioManager: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioManager()
    
    private var tapPlayers: [AVAudioPlayer] = []
    private let tapPlayerPoolSize = 6
    private var currentTapIndex = 0
    
    private var chekunecPlayer: AVAudioPlayer?
    private let audioQueue = DispatchQueue(label: "com.mellclicker.audioQueue", qos: .userInitiated)
    
    private override init() {
        super.init()
        setupAudioSession()
        preloadAudioFiles()
    }
    
    // MARK: - Audio Session Configuration
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // Ambient category ensures audio plays concurrently with other apps and respects silent switch
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("[AudioManager] Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Preloading
    
    private func preloadAudioFiles() {
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 1. Preload Pool for tap.mp3 for ultra-low latency rapid tapping
            if let tapURL = Bundle.main.url(forResource: "tap", withExtension: "mp3") {
                var pool: [AVAudioPlayer] = []
                for _ in 0..<self.tapPlayerPoolSize {
                    if let player = try? AVAudioPlayer(contentsOf: tapURL) {
                        player.prepareToPlay()
                        pool.append(player)
                    }
                }
                DispatchQueue.main.async {
                    self.tapPlayers = pool
                }
            } else {
                print("[AudioManager] Warning: tap.mp3 not found in main bundle.")
            }
            
            // 2. Preload chekunec.mp3
            if let chekunecURL = Bundle.main.url(forResource: "chekunec", withExtension: "mp3") {
                if let player = try? AVAudioPlayer(contentsOf: chekunecURL) {
                    player.prepareToPlay()
                    DispatchQueue.main.async {
                        self.chekunecPlayer = player
                    }
                }
            } else {
                print("[AudioManager] Warning: chekunec.mp3 not found in main bundle.")
            }
        }
    }
    
    // MARK: - Public Playback Methods
    
    /// Plays the tap sound effect with minimum latency.
    func playTap() {
        guard !tapPlayers.isEmpty else {
            // Fallback if pool wasn't ready yet or initialized on demand
            playDirect(resource: "tap")
            return
        }
        
        audioQueue.async { [weak self] in
            guard let self = self, !self.tapPlayers.isEmpty else { return }
            
            let player = self.tapPlayers[self.currentTapIndex]
            self.currentTapIndex = (self.currentTapIndex + 1) % self.tapPlayers.count
            
            if player.isPlaying {
                player.currentTime = 0
            }
            player.play()
        }
    }
    
    /// Plays the chekunec auto-click sound effect.
    func playChekunec() {
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let player = self.chekunecPlayer {
                if player.isPlaying {
                    player.currentTime = 0
                }
                player.play()
            } else {
                self.playDirect(resource: "chekunec")
            }
        }
    }
    
    // MARK: - Fallback Direct Player
    
    private func playDirect(resource: String) {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "mp3") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
        } catch {
            print("[AudioManager] Direct play error: \(error)")
        }
    }
}

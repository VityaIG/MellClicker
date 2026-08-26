import Foundation
import AVFoundation
import UIKit

/// High-performance audio manager managing concurrent, low-latency audio playback
/// for tap.mp3 and chekunec.mp3 using AVFoundation.
final class AudioManager: NSObject {
    static let shared = AudioManager()
    
    private var tapPlayers: [AVAudioPlayer] = []
    private let tapPlayerPoolSize = 6
    private var currentTapIndex = 0
    
    private var chekunecPlayer: AVAudioPlayer?
    private var tempPlayers: [AVAudioPlayer] = []
    
    private override init() {
        super.init()
        setupAudioSession()
        preloadAudioFiles()
    }
    
    // MARK: - Audio Session Configuration
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("[AudioManager] Failed to configure AVAudioSession: \(error)")
        }
    }
    
    // MARK: - Preloading
    
    private func preloadAudioFiles() {
        // 1. Preload tap pool
        if let tapURL = Bundle.main.url(forResource: "tap", withExtension: "mp3") {
            var pool: [AVAudioPlayer] = []
            for _ in 0..<tapPlayerPoolSize {
                if let player = try? AVAudioPlayer(contentsOf: tapURL) {
                    player.prepareToPlay()
                    pool.append(player)
                }
            }
            self.tapPlayers = pool
        }
        
        // 2. Preload chekunec
        if let chekunecURL = Bundle.main.url(forResource: "chekunec", withExtension: "mp3") {
            if let player = try? AVAudioPlayer(contentsOf: chekunecURL) {
                player.prepareToPlay()
                self.chekunecPlayer = player
            }
        }
    }
    
    // MARK: - Public Playback Methods
    
    func playTap() {
        guard !tapPlayers.isEmpty else {
            playDirect(resource: "tap")
            return
        }
        
        let player = tapPlayers[currentTapIndex]
        currentTapIndex = (currentTapIndex + 1) % tapPlayers.count
        
        if player.isPlaying {
            player.currentTime = 0
        }
        player.play()
    }
    
    func playChekunec() {
        if let player = chekunecPlayer {
            if player.isPlaying {
                player.currentTime = 0
            }
            player.play()
        } else {
            playDirect(resource: "chekunec")
        }
    }
    
    private func playDirect(resource: String) {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "mp3") else { return }
        if let player = try? AVAudioPlayer(contentsOf: url) {
            player.prepareToPlay()
            player.play()
            tempPlayers.append(player)
            tempPlayers.removeAll(where: { !$0.isPlaying })
        }
    }
}

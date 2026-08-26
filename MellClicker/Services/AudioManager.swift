import Foundation
import AVFoundation
import AudioToolbox
import UIKit

/// High-performance audio manager managing concurrent, low-latency audio playback
/// for tap.mp3 and chekunec.mp3 using AVFoundation with reliable fallback.
final class AudioManager: NSObject {
    static let shared = AudioManager()
    
    private var tapPlayers: [AVAudioPlayer] = []
    private let tapPlayerPoolSize = 8
    private var currentTapIndex = 0
    
    private var chekunecPlayer: AVAudioPlayer?
    private var isAudioSessionConfigured = false
    
    private override init() {
        super.init()
        setupAudioSession()
        preloadAudioFiles()
    }
    
    // MARK: - Audio Session Configuration
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // Set playback category with ambient / mix options so it plays even in silent mode
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            isAudioSessionConfigured = true
        } catch {
            print("[AudioManager] Failed to configure AVAudioSession: \(error)")
        }
    }
    
    private func ensureAudioSessionActive() {
        if !isAudioSessionConfigured {
            setupAudioSession()
        }
    }
    
    // MARK: - File Path Resolution
    
    private func findAudioURL(filename: String) -> URL? {
        // 1. Direct bundle resource (tap.mp3 or tap)
        if let url = Bundle.main.url(forResource: filename, withExtension: "mp3") {
            return url
        }
        // 2. Resource inside Audio subfolder
        if let url = Bundle.main.url(forResource: filename, withExtension: "mp3", subdirectory: "Audio") {
            return url
        }
        // 3. Fallback search via Bundle path
        if let path = Bundle.main.path(forResource: filename, ofType: "mp3") {
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    // MARK: - Preloading
    
    private func preloadAudioFiles() {
        // 1. Preload tap pool
        if let tapURL = findAudioURL(filename: "tap") {
            var pool: [AVAudioPlayer] = []
            for _ in 0..<tapPlayerPoolSize {
                do {
                    let player = try AVAudioPlayer(contentsOf: tapURL)
                    player.volume = 1.0
                    player.prepareToPlay()
                    pool.append(player)
                } catch {
                    print("[AudioManager] Error loading tap.mp3 player: \(error)")
                }
            }
            self.tapPlayers = pool
        }
        
        // 2. Preload chekunec
        if let chekunecURL = findAudioURL(filename: "chekunec") {
            do {
                let player = try AVAudioPlayer(contentsOf: chekunecURL)
                player.volume = 1.0
                player.prepareToPlay()
                self.chekunecPlayer = player
            } catch {
                print("[AudioManager] Error loading chekunec.mp3: \(error)")
            }
        }
    }
    
    // MARK: - Public Playback Methods
    
    /// Plays the tap.mp3 sound on manual button clicks
    func playTap() {
        ensureAudioSessionActive()
        
        if tapPlayers.isEmpty {
            preloadAudioFiles()
        }
        
        guard !tapPlayers.isEmpty else {
            // Native system tap fallback if asset is unavailable
            AudioServicesPlaySystemSound(1104)
            return
        }
        
        let player = tapPlayers[currentTapIndex]
        currentTapIndex = (currentTapIndex + 1) % tapPlayers.count
        
        if player.isPlaying {
            player.currentTime = 0
        }
        
        if !player.play() {
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    /// Plays the chekunec.mp3 sound on auto clicker ticks
    func playChekunec() {
        ensureAudioSessionActive()
        
        if chekunecPlayer == nil {
            preloadAudioFiles()
        }
        
        if let player = chekunecPlayer {
            if player.isPlaying {
                player.currentTime = 0
            }
            if !player.play() {
                AudioServicesPlaySystemSound(1016)
            }
        } else {
            // Native system pop fallback if asset is unavailable
            AudioServicesPlaySystemSound(1016)
        }
    }
}

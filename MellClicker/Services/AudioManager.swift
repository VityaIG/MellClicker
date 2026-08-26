import Foundation
import AVFoundation
import AudioToolbox
import UIKit

/// High-performance audio manager supporting multi-channel playback for tap.mp3 and chekunec.mp3.
/// Uses AVAudioSession category .playback (ignores silent switch) with fallback to low-level SystemSoundID.
final class AudioManager: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioManager()
    
    // MARK: - Audio Players Pool
    private var tapPlayers: [AVAudioPlayer] = []
    private let tapPlayerPoolSize = 10
    private var currentTapIndex = 0
    
    private var chekunecPlayers: [AVAudioPlayer] = []
    private let chekunecPlayerPoolSize = 4
    private var currentChekunecIndex = 0
    
    // SystemSoundID fallback handles
    private var tapSystemSoundID: SystemSoundID = 0
    private var chekunecSystemSoundID: SystemSoundID = 0
    
    private var isSessionActive = false
    
    private override init() {
        super.init()
        configureAudioSession()
        preloadAllSounds()
    }
    
    // MARK: - Audio Session Setup
    
    /// Sets .playback category so audio plays even when the device silent hardware switch is ON
    func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try session.setActive(true, options: [])
            isSessionActive = true
        } catch {
            print("[AudioManager] AudioSession error: \(error.localizedDescription)")
            // Fallback attempt without duckOthers
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)
                isSessionActive = true
            } catch {
                print("[AudioManager] AudioSession fallback failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - URL Resolvers
    
    private func locateSoundURL(name: String) -> URL? {
        let extensions = ["mp3", "m4a", "wav", "caf"]
        let subdirectories: [String?] = [nil, "Audio", "Resources", "Resources/Audio"]
        
        for ext in extensions {
            for sub in subdirectories {
                if let sub = sub {
                    if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: sub) {
                        return url
                    }
                } else {
                    if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                        return url
                    }
                }
            }
        }
        
        // Try direct file path search
        for ext in extensions {
            if let path = Bundle.main.path(forResource: name, ofType: ext) {
                return URL(fileURLWithPath: path)
            }
        }
        
        return nil
    }
    
    // MARK: - Preloading
    
    private func preloadAllSounds() {
        // 1. Preload tap.mp3
        if let tapURL = locateSoundURL(name: "tap") {
            // Register SystemSoundID
            AudioServicesCreateSystemSoundID(tapURL as CFURL, &tapSystemSoundID)
            
            // Create AVPlayer pool
            var pool: [AVAudioPlayer] = []
            for _ in 0..<tapPlayerPoolSize {
                if let data = try? Data(contentsOf: tapURL),
                   let player = try? AVAudioPlayer(data: data) {
                    player.volume = 1.0
                    player.prepareToPlay()
                    pool.append(player)
                } else if let player = try? AVAudioPlayer(contentsOf: tapURL) {
                    player.volume = 1.0
                    player.prepareToPlay()
                    pool.append(player)
                }
            }
            self.tapPlayers = pool
        }
        
        // 2. Preload chekunec.mp3
        if let chekunecURL = locateSoundURL(name: "chekunec") {
            // Register SystemSoundID
            AudioServicesCreateSystemSoundID(chekunecURL as CFURL, &chekunecSystemSoundID)
            
            var pool: [AVAudioPlayer] = []
            for _ in 0..<chekunecPlayerPoolSize {
                if let data = try? Data(contentsOf: chekunecURL),
                   let player = try? AVAudioPlayer(data: data) {
                    player.volume = 1.0
                    player.prepareToPlay()
                    pool.append(player)
                } else if let player = try? AVAudioPlayer(contentsOf: chekunecURL) {
                    player.volume = 1.0
                    player.prepareToPlay()
                    pool.append(player)
                }
            }
            self.chekunecPlayers = pool
        }
    }
    
    // MARK: - Playback Methods
    
    /// Plays tap.mp3 on every tap
    func playTap() {
        if !isSessionActive {
            configureAudioSession()
        }
        
        if tapPlayers.isEmpty {
            preloadAllSounds()
        }
        
        var played = false
        
        if !tapPlayers.isEmpty {
            let player = tapPlayers[currentTapIndex]
            currentTapIndex = (currentTapIndex + 1) % tapPlayers.count
            
            if player.isPlaying {
                player.currentTime = 0
            }
            played = player.play()
        }
        
        if !played {
            if tapSystemSoundID != 0 {
                AudioServicesPlaySystemSound(tapSystemSoundID)
            } else {
                // Native UI Keyboard click sound
                AudioServicesPlaySystemSound(1104)
            }
        }
    }
    
    /// Plays chekunec.mp3 on auto-clicker interval
    func playChekunec() {
        if !isSessionActive {
            configureAudioSession()
        }
        
        if chekunecPlayers.isEmpty {
            preloadAllSounds()
        }
        
        var played = false
        
        if !chekunecPlayers.isEmpty {
            let player = chekunecPlayers[currentChekunecIndex]
            currentChekunecIndex = (currentChekunecIndex + 1) % chekunecPlayers.count
            
            if player.isPlaying {
                player.currentTime = 0
            }
            played = player.play()
        }
        
        if !played {
            if chekunecSystemSoundID != 0 {
                AudioServicesPlaySystemSound(chekunecSystemSoundID)
            } else {
                // Native pop system sound
                AudioServicesPlaySystemSound(1016)
            }
        }
    }
}

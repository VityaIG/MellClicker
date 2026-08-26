import Foundation
import AVFoundation
import AudioToolbox

/// Audio manager for sound effects in MellClicker iOS with low latency and fallback
final class AudioManager {
    static let shared = AudioManager()
    
    private var tapPlayers: [AVAudioPlayer] = []
    private var tapIndex: Int = 0
    private var chekunecPlayers: [AVAudioPlayer] = []
    private var chekunecIndex: Int = 0
    
    private var tapSystemSoundID: SystemSoundID = 0
    private var chekunecSystemSoundID: SystemSoundID = 0
    
    private init() {
        configureAudioSession()
        prepareAudioPlayers()
    }
    
    func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // playback category ensures audio plays even if the iPhone silent switch (mute) is turned on
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    private func findAudioURL(for name: String, ext: String) -> URL? {
        let main = Bundle.main
        if let url = main.url(forResource: name, withExtension: ext, subdirectory: "Audio") {
            return url
        }
        if let url = main.url(forResource: name, withExtension: ext, subdirectory: "Resources/Audio") {
            return url
        }
        if let url = main.url(forResource: name, withExtension: ext) {
            return url
        }
        return nil
    }
    
    private func prepareAudioPlayers() {
        // Prepare Tap players (Pool of 4 players for rapid spam clicking)
        if let tapUrl = findAudioURL(for: "tap", ext: "mp3") {
            tapPlayers.removeAll()
            for _ in 0..<4 {
                if let player = try? AVAudioPlayer(contentsOf: tapUrl) {
                    player.prepareToPlay()
                    tapPlayers.append(player)
                }
            }
            AudioServicesCreateSystemSoundID(tapUrl as CFURL, &tapSystemSoundID)
        }
        
        // Prepare Chekunec players
        if let chekunecUrl = findAudioURL(for: "chekunec", ext: "mp3") {
            chekunecPlayers.removeAll()
            for _ in 0..<2 {
                if let player = try? AVAudioPlayer(contentsOf: chekunecUrl) {
                    player.prepareToPlay()
                    chekunecPlayers.append(player)
                }
            }
            AudioServicesCreateSystemSoundID(chekunecUrl as CFURL, &chekunecSystemSoundID)
        }
    }
    
    func playTap() {
        if tapPlayers.isEmpty {
            prepareAudioPlayers()
        }
        
        if !tapPlayers.isEmpty {
            let player = tapPlayers[tapIndex]
            tapIndex = (tapIndex + 1) % tapPlayers.count
            player.currentTime = 0
            player.play()
        } else if tapSystemSoundID != 0 {
            AudioServicesPlaySystemSound(tapSystemSoundID)
        }
    }
    
    func playChekunec() {
        if chekunecPlayers.isEmpty {
            prepareAudioPlayers()
        }
        
        if !chekunecPlayers.isEmpty {
            let player = chekunecPlayers[chekunecIndex]
            chekunecIndex = (chekunecIndex + 1) % chekunecPlayers.count
            player.currentTime = 0
            player.play()
        } else if chekunecSystemSoundID != 0 {
            AudioServicesPlaySystemSound(chekunecSystemSoundID)
        }
    }
}


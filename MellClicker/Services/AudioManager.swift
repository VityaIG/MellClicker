import Foundation
import AVFoundation

/// Audio manager for sound effects in MellClicker iOS
final class AudioManager {
    static let shared = AudioManager()
    
    private var tapPlayer: AVAudioPlayer?
    private var chekunecPlayer: AVAudioPlayer?
    
    private init() {
        configureAudioSession()
        prepareAudioPlayers()
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    private func prepareAudioPlayers() {
        if let tapUrl = Bundle.main.url(forResource: "tap", withExtension: "mp3", subdirectory: "Audio") ?? Bundle.main.url(forResource: "tap", withExtension: "mp3") {
            tapPlayer = try? AVAudioPlayer(contentsOf: tapUrl)
            tapPlayer?.prepareToPlay()
        }
        
        if let chekunecUrl = Bundle.main.url(forResource: "chekunec", withExtension: "mp3", subdirectory: "Audio") ?? Bundle.main.url(forResource: "chekunec", withExtension: "mp3") {
            chekunecPlayer = try? AVAudioPlayer(contentsOf: chekunecUrl)
            chekunecPlayer?.prepareToPlay()
        }
    }
    
    func playTap() {
        guard let player = tapPlayer else {
            prepareAudioPlayers()
            tapPlayer?.currentTime = 0
            tapPlayer?.play()
            return
        }
        if player.isPlaying {
            player.currentTime = 0
        }
        player.play()
    }
    
    func playChekunec() {
        guard let player = chekunecPlayer else {
            prepareAudioPlayers()
            chekunecPlayer?.currentTime = 0
            chekunecPlayer?.play()
            return
        }
        if player.isPlaying {
            player.currentTime = 0
        }
        player.play()
    }
}


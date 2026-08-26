import Foundation
import AVFoundation
import AudioToolbox
import UIKit

// MARK: - Embedded Audio Data Fallback

private enum EmbeddedAudio {
    static let tapWavBase64 = "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z//K/8T/v/+6/7X/sP+s/6f/pP+g/5z/mf+W/5T/kf+P/43/jP+K/4n/if+I/4j/h/+H/4j/iP+J/4r/i/+M/43/j/+R/5L/lP+W/5j/m/+d/5//ov+k/6b/qf+r/67/sP+z/7X/uP+6/73/v//B/8T/xv/I/8r/zP/O/9D/0v/U/9X/1//Y/9r/2//c/97/3//g/+H/4v/j/+T/5f/l/+b/5//o/+j/6f/p/+r/6//r/+z/7P/t/+7/7v/v/+//8P/x//L/8v/z//T/9f/2//f/+P/5//r/+//8//3//v8AAAEAAgAEAAUABgAIAAkACwAMAA4ADwARABIAFAAVABcAGAAaABsAHAAeAB8AIQAiACMAJAAlACYAJwAoACkAKgArACwALAAtAC0ALgAuAC4ALwAvAC8ALwAvAC4ALgAuAC4ALQAtACwAKwArACoAKQAoACcAJgAlACQAIwAiACEAIAAfAB0AHAAbABkAGAAXABYAFAATABIAEAAPAA4ADQALAAoACQAIAAcABQAEAAMAAgABAAAA//////7//f/8//z/+//6//r/+f/5//j/+P/3//f/9v/2//b/9v/1//X/9f/1//X/9f/1//X/9f/1//X/9f/1//X/9f/1//b/9v/2//b/9v/2//f/9//3//f/9//3//j/+P/4//j/+P/4//n/+f/5//n/+f/5//r/+v/6//r/+v/6//r/+v/6//v/+//7//v/+//7//v/+//7//v/+//7//v/+//8//z//P/8//z//P/8//z//P/8//z//P/8//z//P/9//3//f/9//3//f/9//3//f/9//3//f/+//7//v/+//7//v/+//7//v/+//7//////////////////////////////////////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    static let chekunecWavBase64 = "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1//V/9L/zv/J/8P/u/+y/6r/ov+c/5r/m/+g/6r/uf/L/+D/+P8PACUAOABIAFQAWwBdAFwAVwBQAEgAQAA4ADEAKwAnACQAIQAfABwAGAAUAA8ACQACAPz/9f/w/+v/5//l/+L/4f/f/9z/2P/U/8//yf/C/73/uf+2/7f/uv/B/8v/2P/o//j/CQAYACYAMgA6AEAAQgBBAD4AOQAzAC0AKAAjAB8AGwAZABcAFQATABEADgAKAAYAAgD9//n/9f/y/+//7f/s/+v/6f/o/+X/4//f/9v/1//T/9D/z//P/9H/1v/c/+X/7//5/wQADwAYACAAJQApACoAKgAoACUAIQAdABoAFgAUABIAEAAPAA0ADAALAAkABwAEAAEA/v/8//n/9//2//T/9P/z//L/8f/w/+7/7P/q/+j/5f/k/+P/4//k/+b/6v/v//X/+/8CAAgADQARABUAFwAYABgAFgAVABMAEAAOAAwACwAJAAkACAAHAAYABgAFAAMAAgABAP///v/8//v/+//6//n/+f/5//j/+P/3//b/9f/0//P/8v/y//L/8v/0//X/+P/6//3/AAADAAUABwAJAAoACgAKAAkACQAIAAcABgAFAAQABAADAAMAAwACAAIAAQABAAEAAAD//////v/+//7//v/9//3//f/9//3//f/9//z//P/8//z//P/8//z//P/9//3//v///wAAAAABAAEAAQACAAIAAgABAAEAAQABAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//////////////////////////////////////////8="
}

/// High-performance audio manager supporting multi-channel playback for tap and chekunec sounds.
/// Configured with .playback category (bypasses hardware mute switch) and redundant player pool + SystemSound fallback.
final class AudioManager: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioManager()
    
    // MARK: - Audio Players Pool
    private var tapPlayers: [AVAudioPlayer] = []
    private let tapPlayerPoolSize = 16
    private var currentTapIndex = 0
    
    private var chekunecPlayers: [AVAudioPlayer] = []
    private let chekunecPlayerPoolSize = 8
    private var currentChekunecIndex = 0
    
    // SystemSoundID fallback handles
    private var tapSystemSoundID: SystemSoundID = 0
    private var chekunecSystemSoundID: SystemSoundID = 0
    
    private var tapData: Data?
    private var chekunecData: Data?
    
    private override init() {
        super.init()
        configureAudioSession()
        setupAudioDataAndPlayers()
        registerLifecycleObservers()
    }
    
    // MARK: - Audio Session Configuration
    
    /// Configures AVAudioSession to .playback category so sound plays regardless of physical silent switch
    func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true, options: [])
        } catch {
            print("[AudioManager] AVAudioSession config notice: (error.localizedDescription)")
        }
    }
    
    private func registerLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.configureAudioSession()
        }
        
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
            }
            if type == .ended {
                self?.configureAudioSession()
            }
        }
    }
    
    // MARK: - Data & Player Initialization
    
    private func getAudioData(for name: String) -> Data? {
        let extensions = ["wav", "mp3", "m4a", "caf"]
        
        // 1. Direct bundle search
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext),
               let data = try? Data(contentsOf: url), !data.isEmpty {
                return data
            }
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Audio"),
               let data = try? Data(contentsOf: url), !data.isEmpty {
                return data
            }
            if let path = Bundle.main.path(forResource: name, ofType: ext),
               let data = try? Data(contentsOf: URL(fileURLWithPath: path)), !data.isEmpty {
                return data
            }
        }
        
        // 2. Recursive bundle directory search
        if let resourcePath = Bundle.main.resourcePath {
            let fm = FileManager.default
            if let enumerator = fm.enumerator(atPath: resourcePath) {
                for case let file as String in enumerator {
                    if file.hasSuffix("/(name).wav") || file.hasSuffix("(name).wav") ||
                       file.hasSuffix("/(name).mp3") || file.hasSuffix("(name).mp3") {
                        let fullPath = (resourcePath as NSString).appendingPathComponent(file)
                        if let data = try? Data(contentsOf: URL(fileURLWithPath: fullPath)), !data.isEmpty {
                            return data
                        }
                    }
                }
            }
        }
        
        // 3. Guaranteed Embedded Base64 binary fallback
        if name == "tap", let data = Data(base64Encoded: EmbeddedAudio.tapWavBase64) {
            return data
        } else if name == "chekunec", let data = Data(base64Encoded: EmbeddedAudio.chekunecWavBase64) {
            return data
        }
        
        return nil
    }
    
    private func setupAudioDataAndPlayers() {
        // 1. Setup Tap
        if let data = getAudioData(for: "tap") {
            self.tapData = data
            var pool: [AVAudioPlayer] = []
            for _ in 0..<tapPlayerPoolSize {
                if let player = try? AVAudioPlayer(data: data) {
                    player.volume = 1.0
                    player.prepareToPlay()
                    pool.append(player)
                }
            }
            self.tapPlayers = pool
            
            // Register SystemSoundID from temporary WAV file
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("mc_tap.wav")
            if (try? data.write(to: tempURL)) != nil {
                AudioServicesCreateSystemSoundID(tempURL as CFURL, &tapSystemSoundID)
            }
        }
        
        // 2. Setup Chekunec
        if let data = getAudioData(for: "chekunec") {
            self.chekunecData = data
            var pool: [AVAudioPlayer] = []
            for _ in 0..<chekunecPlayerPoolSize {
                if let player = try? AVAudioPlayer(data: data) {
                    player.volume = 1.0
                    player.prepareToPlay()
                    pool.append(player)
                }
            }
            self.chekunecPlayers = pool
            
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("mc_chekunec.wav")
            if (try? data.write(to: tempURL)) != nil {
                AudioServicesCreateSystemSoundID(tempURL as CFURL, &chekunecSystemSoundID)
            }
        }
    }
    
    // MARK: - Playback Methods
    
    /// Plays tap sound on user click
    func playTap() {
        if tapPlayers.isEmpty {
            setupAudioDataAndPlayers()
        }
        
        var played = false
        
        if !tapPlayers.isEmpty {
            let player = tapPlayers[currentTapIndex]
            currentTapIndex = (currentTapIndex + 1) % tapPlayers.count
            
            player.currentTime = 0
            player.volume = 1.0
            played = player.play()
        }
        
        // Fallback: spawn dynamic player
        if !played {
            if let data = tapData, let freshPlayer = try? AVAudioPlayer(data: data) {
                freshPlayer.volume = 1.0
                freshPlayer.play()
                played = true
            }
        }
        
        // Fallback: SystemSound
        if !played && tapSystemSoundID != 0 {
            AudioServicesPlaySystemSound(tapSystemSoundID)
        }
    }
    
    /// Plays chekunec sound on auto-click interval or purchase
    func playChekunec() {
        if chekunecPlayers.isEmpty {
            setupAudioDataAndPlayers()
        }
        
        var played = false
        
        if !chekunecPlayers.isEmpty {
            let player = chekunecPlayers[currentChekunecIndex]
            currentChekunecIndex = (currentChekunecIndex + 1) % chekunecPlayers.count
            
            player.currentTime = 0
            player.volume = 1.0
            played = player.play()
        }
        
        if !played {
            if let data = chekunecData, let freshPlayer = try? AVAudioPlayer(data: data) {
                freshPlayer.volume = 1.0
                freshPlayer.play()
                played = true
            }
        }
        
        if !played && chekunecSystemSoundID != 0 {
            AudioServicesPlaySystemSound(chekunecSystemSoundID)
        }
    }
}

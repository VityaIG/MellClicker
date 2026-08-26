import Foundation

/// Clean stub manager for sound effects (Sounds completely disabled per configuration)
final class AudioManager {
    static let shared = AudioManager()
    
    private init() {}
    
    func configureAudioSession() {
        // No-op
    }
    
    func playTap() {
        // Sounds completely disabled
    }
    
    func playChekunec() {
        // Sounds completely disabled
    }
}

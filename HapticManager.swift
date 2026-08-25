import UIKit

/// Manages native iOS haptic feedback using UIImpactFeedbackGenerator and UINotificationFeedbackGenerator.
final class HapticManager {
    static let shared = HapticManager()
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    
    private init() {
        lightImpact.prepare()
        mediumImpact.prepare()
    }
    
    /// Triggers feedback on user click
    func tapFeedback() {
        mediumImpact.impactOccurred()
    }
    
    /// Triggers feedback on successful purchase
    func purchaseSuccess() {
        notification.notificationOccurred(.success)
    }
    
    /// Triggers feedback on error/insufficient funds
    func purchaseFailure() {
        notification.notificationOccurred(.warning)
    }
    
    /// Triggers feedback on destructive actions (e.g., reset)
    func resetFeedback() {
        heavyImpact.impactOccurred()
    }
}

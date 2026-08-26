import Foundation
import SwiftUI
import Combine
import AudioToolbox
import UIKit

/// Main Game ViewModel coordinating state, local persistence via UserDefaults,
/// passive auto-click intervals, and audio/haptic events.
final class GameViewModel: ObservableObject {
    
    // MARK: - State Properties
    
    @Published var balance: Int {
        didSet {
            UserDefaults.standard.set(balance, forKey: Keys.balance)
        }
    }
    
    @Published var clickMultiplier: Int {
        didSet {
            UserDefaults.standard.set(clickMultiplier, forKey: Keys.clickMultiplier)
        }
    }
    
    @Published var chekushkaCost: Int {
        didSet {
            UserDefaults.standard.set(chekushkaCost, forKey: Keys.chekushkaCost)
        }
    }
    
    @Published var autoClickerCount: Int {
        didSet {
            UserDefaults.standard.set(autoClickerCount, forKey: Keys.autoClickerCount)
        }
    }
    
    @Published var chekunecCost: Int {
        didSet {
            UserDefaults.standard.set(chekunecCost, forKey: Keys.chekunecCost)
        }
    }
    
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: Keys.isSoundEnabled)
        }
    }
    
    @Published var isHapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticsEnabled, forKey: Keys.isHapticsEnabled)
        }
    }
    
    // MARK: - Base Configuration Constants
    
    let baseChekushkaCost: Int = 100
    let baseChekunecCost: Int = 250
    
    // MARK: - Computed Helpers
    
    var passiveIncomePerSecond: Int {
        return autoClickerCount * 1
    }
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: balance)) ?? "\(balance)"
    }
    
    // MARK: - Private Constants & Timers
    
    private enum Keys {
        static let balance = "mc_balance"
        static let clickMultiplier = "mc_clickMultiplier"
        static let chekushkaCost = "mc_chekushkaCost"
        static let autoClickerCount = "mc_autoClickerCount"
        static let chekunecCost = "mc_chekunecCost"
        static let isSoundEnabled = "mc_isSoundEnabled"
        static let isHapticsEnabled = "mc_isHapticsEnabled"
    }
    
    private var timerSubscription: AnyCancellable?
    
    // MARK: - Initialization & Persistence Loading
    
    init() {
        let defaults = UserDefaults.standard
        
        self.balance = defaults.object(forKey: Keys.balance) != nil ? max(0, defaults.integer(forKey: Keys.balance)) : 0
        self.clickMultiplier = defaults.object(forKey: Keys.clickMultiplier) != nil ? max(1, defaults.integer(forKey: Keys.clickMultiplier)) : 1
        self.chekushkaCost = defaults.object(forKey: Keys.chekushkaCost) != nil ? max(100, defaults.integer(forKey: Keys.chekushkaCost)) : 100
        self.autoClickerCount = defaults.object(forKey: Keys.autoClickerCount) != nil ? max(0, defaults.integer(forKey: Keys.autoClickerCount)) : 0
        self.chekunecCost = defaults.object(forKey: Keys.chekunecCost) != nil ? max(250, defaults.integer(forKey: Keys.chekunecCost)) : 250
        
        self.isSoundEnabled = defaults.object(forKey: Keys.isSoundEnabled) != nil ? defaults.bool(forKey: Keys.isSoundEnabled) : true
        self.isHapticsEnabled = defaults.object(forKey: Keys.isHapticsEnabled) != nil ? defaults.bool(forKey: Keys.isHapticsEnabled) : true
        
        startAutoClickerTimer()
    }
    
    // MARK: - Timer / Passive Income
    
    private func startAutoClickerTimer() {
        timerSubscription?.cancel()
        
        // Runs on a background publisher loop every 1.0 second
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.processAutoClick()
            }
    }
    
    private func processAutoClick() {
        guard autoClickerCount > 0 else { return }
        
        let passiveIncome = self.passiveIncomePerSecond
        balance += passiveIncome
        
        if isSoundEnabled {
            AudioManager.shared.playChekunec()
        }
    }
    
    // MARK: - User Actions
    
    /// Handles manual button tap
    func click() {
        balance += clickMultiplier
        
        if isSoundEnabled {
            AudioManager.shared.playTap()
        }
        
        if isHapticsEnabled {
            HapticManager.shared.tapFeedback()
        }
    }
    
    /// Purchases "Чекушка" multiplier upgrade (doubles the tap power, cost * 2)
    func buyChekushka() {
        guard balance >= chekushkaCost else {
            if isHapticsEnabled { HapticManager.shared.purchaseFailure() }
            return
        }
        
        balance -= chekushkaCost
        clickMultiplier *= 2
        chekushkaCost *= 2
        
        if isHapticsEnabled { HapticManager.shared.purchaseSuccess() }
        if isSoundEnabled { AudioManager.shared.playTap() }
    }
    
    /// Purchases "Чекунец" auto-clicker unit
    func buyChekunec() {
        guard balance >= chekunecCost else {
            if isHapticsEnabled { HapticManager.shared.purchaseFailure() }
            return
        }
        
        balance -= chekunecCost
        autoClickerCount += 1
        // Progressive scaling formula: base * 1.20^count
        chekunecCost = Int(Double(baseChekunecCost) * pow(1.20, Double(autoClickerCount)))
        
        if isHapticsEnabled { HapticManager.shared.purchaseSuccess() }
        if isSoundEnabled { AudioManager.shared.playChekunec() }
    }
    
    /// Resets all progress back to factory defaults
    func resetProgress() {
        balance = 0
        clickMultiplier = 1
        chekushkaCost = baseChekushkaCost
        autoClickerCount = 0
        chekunecCost = baseChekunecCost
        
        if isHapticsEnabled {
            HapticManager.shared.resetFeedback()
        }
    }
}

import Foundation
import Combine
import SwiftUI

/// Main Game ViewModel managing game state, currency, upgrades, auto-click timers, and persistence.
@MainActor
final class GameViewModel: ObservableObject {
    
    // MARK: - Published State
    
    /// Total balance (coins/points)
    @Published var balance: Int {
        didSet {
            UserDefaults.standard.set(balance, forKey: Keys.balance)
        }
    }
    
    /// Current multiplier for manual taps (Upgraded via "Чекушка")
    @Published var clickMultiplier: Int {
        didSet {
            UserDefaults.standard.set(clickMultiplier, forKey: Keys.clickMultiplier)
        }
    }
    
    /// Cost for the next "Чекушка" upgrade (Formula: cost * 2)
    @Published var chekushkaCost: Int {
        didSet {
            UserDefaults.standard.set(chekushkaCost, forKey: Keys.chekushkaCost)
        }
    }
    
    /// Number of active "Чекунец" auto-clickers owned
    @Published var autoClickerCount: Int {
        didSet {
            UserDefaults.standard.set(autoClickerCount, forKey: Keys.autoClickerCount)
        }
    }
    
    /// Cost for the next "Чекунец" auto-clicker
    @Published var chekunecCost: Int {
        didSet {
            UserDefaults.standard.set(chekunecCost, forKey: Keys.chekunecCost)
        }
    }
    
    /// Sound FX toggle
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: Keys.isSoundEnabled)
        }
    }
    
    /// Haptic feedback toggle
    @Published var isHapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticsEnabled, forKey: Keys.isHapticsEnabled)
        }
    }
    
    // MARK: - Computed Properties
    
    /// Passive income generated per second (each Chekunec provides 1 * clickMultiplier or fixed passive clicks)
    var passiveIncomePerSecond: Int {
        return autoClickerCount * 1
    }
    
    /// Formatted balance string with thousand separators
    var formattedBalance: String {
        return NumberFormatter.localizedString(from: NSNumber(value: balance), number: .decimal)
    }
    
    // MARK: - Private Properties
    
    private var timerSubscription: AnyCancellable?
    private let baseChekushkaCost = 100
    private let baseChekunecCost = 250
    
    // MARK: - Storage Keys
    
    private enum Keys {
        static let balance = "MellClicker_balance"
        static let clickMultiplier = "MellClicker_clickMultiplier"
        static let chekushkaCost = "MellClicker_chekushkaCost"
        static let autoClickerCount = "MellClicker_autoClickerCount"
        static let chekunecCost = "MellClicker_chekunecCost"
        static let isSoundEnabled = "MellClicker_isSoundEnabled"
        static let isHapticsEnabled = "MellClicker_isHapticsEnabled"
    }
    
    // MARK: - Initialization
    
    init() {
        let defaults = UserDefaults.standard
        
        // Load stored state or set initial defaults
        self.balance = defaults.object(forKey: Keys.balance) != nil ? defaults.integer(forKey: Keys.balance) : 0
        self.clickMultiplier = defaults.object(forKey: Keys.clickMultiplier) != nil ? max(1, defaults.integer(forKey: Keys.clickMultiplier)) : 1
        self.chekushkaCost = defaults.object(forKey: Keys.chekushkaCost) != nil ? max(100, defaults.integer(forKey: Keys.chekushkaCost)) : 100
        self.autoClickerCount = defaults.object(forKey: Keys.autoClickerCount) != nil ? defaults.integer(forKey: Keys.autoClickerCount) : 0
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
        // Progressive scaling formula: base * 1.25^count or standard arithmetic scale
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

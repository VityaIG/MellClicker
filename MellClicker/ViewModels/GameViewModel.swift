import Foundation
import SwiftUI
import Combine
import AudioToolbox
import UIKit

// MARK: - Accent Theme Definition

enum AccentTheme: String, CaseIterable, Identifiable {
    case white = "Базовый (Ч/Б)"
    case orange = "Оранжевый"
    case blue = "Синий"
    case green = "Зеленый"
    case purple = "Фиолетовый"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .white: return .primary
        case .orange: return .orange
        case .blue: return .blue
        case .green: return .green
        case .purple: return .purple
        }
    }
    
    var textColor: Color {
        switch self {
        case .white: return Color(uiColor: .systemBackground)
        default: return .white
        }
    }
}

// MARK: - Leaderboard Entry Model

struct LeaderboardEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var score: Int
    var isUser: Bool
    var avatarColorHex: String
    
    init(id: UUID = UUID(), name: String, score: Int, isUser: Bool = false, avatarColorHex: String = "#FF9500") {
        self.id = id
        self.name = name
        self.score = score
        self.isUser = isUser
        self.avatarColorHex = avatarColorHex
    }
}

// MARK: - Main Game ViewModel

final class GameViewModel: ObservableObject {
    
    // MARK: - Published Game State
    
    @Published var balance: Int {
        didSet {
            UserDefaults.standard.set(balance, forKey: Keys.balance)
            updateUserLeaderboardScore()
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
    
    // MARK: - Published Stats & Combo System
    
    @Published var comboClicks: Int = 0
    @Published var totalClicks: Int {
        didSet {
            UserDefaults.standard.set(totalClicks, forKey: Keys.totalClicks)
        }
    }
    
    @Published var maxCombo: Int {
        didSet {
            UserDefaults.standard.set(maxCombo, forKey: Keys.maxCombo)
        }
    }
    
    @Published var totalPassiveEarned: Int {
        didSet {
            UserDefaults.standard.set(totalPassiveEarned, forKey: Keys.totalPassiveEarned)
        }
    }
    
    // MARK: - Published Settings State
    
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
    
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: Keys.isDarkMode)
        }
    }
    
    @Published var accentThemeRawValue: String {
        didSet {
            UserDefaults.standard.set(accentThemeRawValue, forKey: Keys.accentTheme)
        }
    }
    
    // MARK: - Published Profile & Onboarding State
    
    @Published var username: String {
        didSet {
            UserDefaults.standard.set(username, forKey: Keys.username)
            updateUserLeaderboardName()
        }
    }
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding)
        }
    }
    
    @Published var showOnboarding: Bool = false
    
    // MARK: - Published Leaderboard
    
    @Published var leaderboard: [LeaderboardEntry] = []
    
    // MARK: - Base Configuration Constants
    
    let baseChekushkaCost: Int = 100
    let baseChekunecCost: Int = 1000 // Substantially higher starting cost for duplicate auto-clicker
    
    // MARK: - Computed Theme Helpers
    
    var currentAccentColor: Color {
        AccentTheme(rawValue: accentThemeRawValue)?.color ?? .primary
    }
    
    var currentAccentTextColor: Color {
        AccentTheme(rawValue: accentThemeRawValue)?.textColor ?? Color(uiColor: .systemBackground)
    }
    
    // MARK: - Computed Helpers & Combo Math
    
    var effectiveUsername: String {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Игрок" : trimmed
    }
    
    func isUsernameTaken(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return leaderboard.contains { !$0.isUser && $0.name.lowercased() == trimmed }
    }
    
    var passiveIncomePerSecond: Int {
        return autoClickerCount
    }
    
    var comboMultiplier: Double {
        if comboClicks >= 50 {
            return 3.0
        } else if comboClicks >= 25 {
            return 2.0
        } else if comboClicks >= 10 {
            return 1.5
        } else {
            return 1.0
        }
    }
    
    var isFrenzyActive: Bool {
        comboClicks >= 25
    }
    
    var comboTitle: String {
        if comboClicks >= 50 {
            return "💥 FRENZY x3.0!"
        } else if comboClicks >= 25 {
            return "🔥 МЕГА x2.0!"
        } else if comboClicks >= 10 {
            return "⚡️ КОМБО x1.5!"
        } else {
            return ""
        }
    }
    
    var effectiveClickPower: Int {
        let multiplied = Double(clickMultiplier) * comboMultiplier
        return max(1, Int(multiplied))
    }
    
    var playerRankTitle: String {
        if balance >= 10_000_000 {
            return "🌌 Легенда Меллстроя"
        } else if balance >= 1_000_000 {
            return "👑 Король Кликеров"
        } else if balance >= 100_000 {
            return "💰 Олигарх"
        } else if balance >= 10_000 {
            return "⚡️ Гроза Чекунцов"
        } else if balance >= 1_000 {
            return "🍺 Любитель Чекушек"
        } else {
            return "🍼 Новичок"
        }
    }
    
    var formattedBalance: String {
        formatNumber(balance)
    }
    
    var formattedChekushkaCost: String {
        formatNumber(chekushkaCost)
    }
    
    var formattedChekunecCost: String {
        formatNumber(chekunecCost)
    }
    
    var userRank: Int {
        let sorted = sortedLeaderboard
        if let index = sorted.firstIndex(where: { $0.isUser }) {
            return index + 1
        }
        return 1
    }
    
    var sortedLeaderboard: [LeaderboardEntry] {
        leaderboard.sorted { $0.score > $1.score }
    }
    
    func formatNumber(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: num)) ?? "\(num)"
    }
    
    // MARK: - Private Keys & Timers
    
    private enum Keys {
        static let balance = "mc_balance"
        static let clickMultiplier = "mc_clickMultiplier"
        static let chekushkaCost = "mc_chekushkaCost"
        static let autoClickerCount = "mc_autoClickerCount"
        static let chekunecCost = "mc_chekunecCost"
        static let isSoundEnabled = "mc_isSoundEnabled"
        static let isHapticsEnabled = "mc_isHapticsEnabled"
        static let isDarkMode = "mc_isDarkMode"
        static let accentTheme = "mc_accentTheme"
        static let username = "mc_username"
        static let hasCompletedOnboarding = "mc_hasCompletedOnboarding"
        static let leaderboardData = "mc_leaderboardData"
        static let totalClicks = "mc_totalClicks"
        static let maxCombo = "mc_maxCombo"
        static let totalPassiveEarned = "mc_totalPassiveEarned"
    }
    
    private var timerSubscription: AnyCancellable?
    private var comboDecayWorkItem: DispatchWorkItem?
    
    // MARK: - Initialization & Persistence Loading
    
    init() {
        let defaults = UserDefaults.standard
        
        self.balance = defaults.object(forKey: Keys.balance) != nil ? max(0, defaults.integer(forKey: Keys.balance)) : 0
        self.clickMultiplier = defaults.object(forKey: Keys.clickMultiplier) != nil ? max(1, defaults.integer(forKey: Keys.clickMultiplier)) : 1
        self.chekushkaCost = defaults.object(forKey: Keys.chekushkaCost) != nil ? max(100, defaults.integer(forKey: Keys.chekushkaCost)) : 100
        self.autoClickerCount = defaults.object(forKey: Keys.autoClickerCount) != nil ? max(0, defaults.integer(forKey: Keys.autoClickerCount)) : 0
        self.chekunecCost = defaults.object(forKey: Keys.chekunecCost) != nil ? max(1000, defaults.integer(forKey: Keys.chekunecCost)) : 1000
        
        self.totalClicks = defaults.integer(forKey: Keys.totalClicks)
        self.maxCombo = defaults.integer(forKey: Keys.maxCombo)
        self.totalPassiveEarned = defaults.integer(forKey: Keys.totalPassiveEarned)
        
        self.isSoundEnabled = defaults.object(forKey: Keys.isSoundEnabled) != nil ? defaults.bool(forKey: Keys.isSoundEnabled) : true
        self.isHapticsEnabled = defaults.object(forKey: Keys.isHapticsEnabled) != nil ? defaults.bool(forKey: Keys.isHapticsEnabled) : true
        self.isDarkMode = defaults.object(forKey: Keys.isDarkMode) != nil ? defaults.bool(forKey: Keys.isDarkMode) : true
        self.accentThemeRawValue = defaults.string(forKey: Keys.accentTheme) ?? AccentTheme.white.rawValue
        
        self.username = defaults.string(forKey: Keys.username) ?? ""
        let completed = defaults.bool(forKey: Keys.hasCompletedOnboarding)
        self.hasCompletedOnboarding = completed
        
        // Show onboarding if never completed before
        if !completed {
            self.showOnboarding = true
        }
        
        loadLeaderboard()
        startAutoClickerTimer()
    }
    
    // MARK: - Leaderboard Management
    
    private func loadLeaderboard() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: Keys.leaderboardData),
           let saved = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) {
            // Keep only the user entry or dynamic real players
            self.leaderboard = saved.filter { $0.isUser }
        } else {
            self.leaderboard = []
        }
        
        // Ensure user entry exists
        syncUserEntryInLeaderboard()
    }
    
    func saveLeaderboard() {
        if let encoded = try? JSONEncoder().encode(leaderboard) {
            UserDefaults.standard.set(encoded, forKey: Keys.leaderboardData)
        }
    }
    
    private func syncUserEntryInLeaderboard() {
        let displayName = username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Вы" : username
        
        if let index = leaderboard.firstIndex(where: { $0.isUser }) {
            leaderboard[index].name = displayName
            leaderboard[index].score = balance
        } else {
            let userEntry = LeaderboardEntry(
                name: displayName,
                score: balance,
                isUser: true,
                avatarColorHex: "#34C759"
            )
            leaderboard.append(userEntry)
        }
    }
    
    private func updateUserLeaderboardScore() {
        if let index = leaderboard.firstIndex(where: { $0.isUser }) {
            leaderboard[index].score = balance
            saveLeaderboard()
        }
    }
    
    private func updateUserLeaderboardName() {
        let displayName = username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Вы" : username
        if let index = leaderboard.firstIndex(where: { $0.isUser }) {
            leaderboard[index].name = displayName
            saveLeaderboard()
        }
    }
    
    // MARK: - Auto-Clicker Timer (Passive Income)
    
    private func startAutoClickerTimer() {
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.handleAutoClickerTick()
            }
    }
    
    private func handleAutoClickerTick() {
        guard autoClickerCount > 0 else { return }
        
        let passiveIncome = self.passiveIncomePerSecond
        balance += passiveIncome
        totalPassiveEarned += passiveIncome
        
        if isSoundEnabled {
            AudioManager.shared.playChekunec()
        }
    }
    
    // MARK: - User Actions
    
    /// Handles manual button tap with combo system
    func click() {
        let power = effectiveClickPower
        balance += power
        totalClicks += 1
        
        // Combo increment
        comboClicks += 1
        if comboClicks > maxCombo {
            maxCombo = comboClicks
        }
        
        // Reset combo decay timer
        comboDecayWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                self.comboClicks = 0
            }
        }
        comboDecayWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: workItem)
        
        if isSoundEnabled {
            AudioManager.shared.playTap()
        }
        
        if isHapticsEnabled {
            if isFrenzyActive {
                HapticManager.shared.purchaseSuccess()
            } else {
                HapticManager.shared.tapFeedback()
            }
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
    
    /// Purchases "Чекунец" auto-clicker unit (doubles the auto-click count/power and doubles cost)
    func buyChekunec() {
        guard balance >= chekunecCost else {
            if isHapticsEnabled { HapticManager.shared.purchaseFailure() }
            return
        }
        
        balance -= chekunecCost
        
        // Duplication mechanic: 0 -> 1 -> 2 -> 4 -> 8 -> 16...
        if autoClickerCount == 0 {
            autoClickerCount = 1
        } else {
            autoClickerCount *= 2
        }
        
        // Price doubles per purchase
        chekunecCost *= 2
        
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
        comboClicks = 0
        
        syncUserEntryInLeaderboard()
        saveLeaderboard()
        
        if isHapticsEnabled {
            HapticManager.shared.resetFeedback()
        }
    }
}

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
    let baseChekunecCost: Int = 250
    
    // MARK: - Computed Theme Helpers
    
    var currentAccentColor: Color {
        AccentTheme(rawValue: accentThemeRawValue)?.color ?? .primary
    }
    
    var currentAccentTextColor: Color {
        AccentTheme(rawValue: accentThemeRawValue)?.textColor ?? Color(uiColor: .systemBackground)
    }
    
    // MARK: - Computed Helpers
    
    var passiveIncomePerSecond: Int {
        return autoClickerCount * 1
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
        return sorted.count + 1
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
           let saved = try? JSONDecoder().decode([LeaderboardEntry].self, from: data),
           !saved.isEmpty {
            self.leaderboard = saved
        } else {
            // Seed initial realistic community leaderboard
            self.leaderboard = [
                LeaderboardEntry(name: "Mellstroy", score: 5000000, isUser: false, avatarColorHex: "#FF3B30"),
                LeaderboardEntry(name: "Папич", score: 2500000, isUser: false, avatarColorHex: "#5856D6"),
                LeaderboardEntry(name: "Zubareff", score: 1800000, isUser: false, avatarColorHex: "#FF9500"),
                LeaderboardEntry(name: "Buster", score: 950000, isUser: false, avatarColorHex: "#34C759"),
                LeaderboardEntry(name: "Kuertov", score: 420000, isUser: false, avatarColorHex: "#007AFF"),
                LeaderboardEntry(name: "VityaV", score: 250000, isUser: false, avatarColorHex: "#AF52DE"),
                LeaderboardEntry(name: "FrameTamer", score: 120000, isUser: false, avatarColorHex: "#FF2D55"),
                LeaderboardEntry(name: "Shadowkek", score: 75000, isUser: false, avatarColorHex: "#5AC8FA"),
                LeaderboardEntry(name: "Evelone", score: 35000, isUser: false, avatarColorHex: "#FFCC00"),
                LeaderboardEntry(name: "Bratishkin", score: 15000, isUser: false, avatarColorHex: "#FF9500")
            ]
        }
        
        // Ensure user entry exists
        syncUserEntryInLeaderboard()
        saveLeaderboard()
    }
    
    func saveLeaderboard() {
        if let data = try? JSONEncoder().encode(leaderboard) {
            UserDefaults.standard.set(data, forKey: Keys.leaderboardData)
        }
    }
    
    private func syncUserEntryInLeaderboard() {
        let displayName = effectiveUsername
        if let index = leaderboard.firstIndex(where: { $0.isUser }) {
            leaderboard[index].name = displayName
            leaderboard[index].score = balance
        } else {
            let userEntry = LeaderboardEntry(
                name: displayName,
                score: balance,
                isUser: true,
                avatarColorHex: "#007AFF"
            )
            leaderboard.append(userEntry)
        }
    }
    
    private func updateUserLeaderboardScore() {
        if let index = leaderboard.firstIndex(where: { $0.isUser }) {
            if leaderboard[index].score != balance {
                leaderboard[index].score = balance
                saveLeaderboard()
            }
        } else {
            syncUserEntryInLeaderboard()
        }
    }
    
    private func updateUserLeaderboardName() {
        let displayName = effectiveUsername
        if let index = leaderboard.firstIndex(where: { $0.isUser }) {
            leaderboard[index].name = displayName
            saveLeaderboard()
        }
    }
    
    var effectiveUsername: String {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Игрок" : trimmed
    }
    
    /// Checks if a nickname is already taken by another player in the leaderboard (case-insensitive)
    func isUsernameTaken(_ candidate: String) -> Bool {
        let trimmed = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false } // Empty name is allowed
        
        return leaderboard.contains { entry in
            !entry.isUser && entry.name.compare(trimmed, options: .caseInsensitive) == .orderedSame
        }
    }
    
    /// Sets user's name if valid and completes onboarding
    func finishOnboarding(withName chosenName: String) {
        let trimmed = chosenName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.username = trimmed
        self.hasCompletedOnboarding = true
        self.showOnboarding = false
        syncUserEntryInLeaderboard()
        saveLeaderboard()
        
        if isHapticsEnabled {
            HapticManager.shared.purchaseSuccess()
        }
    }
    
    // MARK: - Timer / Passive Income
    
    private func startAutoClickerTimer() {
        timerSubscription?.cancel()
        
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
        
        syncUserEntryInLeaderboard()
        saveLeaderboard()
        
        if isHapticsEnabled {
            HapticManager.shared.resetFeedback()
        }
    }
}

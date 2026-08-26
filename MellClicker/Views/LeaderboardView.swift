import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var searchText: String = ""
    
    var sortedEntries: [LeaderboardEntry] {
        viewModel.sortedLeaderboard
    }
    
    var filteredEntries: [LeaderboardEntry] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return sortedEntries
        } else {
            return sortedEntries.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackgroundView(viewModel: viewModel)
                
                ScrollView {
                    VStack(spacing: 18) {
                        
                        // MARK: - Online Sync Status Banner
                        HStack {
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.3))
                                        .frame(width: 14, height: 14)
                                    
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                }
                                
                                Text(viewModel.leaderboardSyncStatus)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Button {
                                Task {
                                    await viewModel.refreshOnlineLeaderboard()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    if viewModel.isSyncingLeaderboard {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.caption.weight(.bold))
                                    }
                                    Text("Обновить")
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundColor(viewModel.currentAccentColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(viewModel.currentAccentColor.opacity(0.12))
                                .clipShape(Capsule())
                            }
                            .disabled(viewModel.isSyncingLeaderboard)
                        }
                        .padding(.horizontal, 6)
                        
                        // MARK: - User Status Card
                        UserRankBanner(
                            viewModel: viewModel,
                            rank: viewModel.userRank,
                            name: viewModel.effectiveUsername,
                            score: viewModel.formattedBalance
                        )
                        
                        // MARK: - Top 3 Podium (if not searching and 3+ players)
                        if searchText.isEmpty && sortedEntries.count >= 3 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("ТОП ИГРОКОВ ОНЛАЙН")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 4)
                                
                                TopThreePodium(
                                    first: sortedEntries[0],
                                    second: sortedEntries[1],
                                    third: sortedEntries[2],
                                    viewModel: viewModel
                                )
                            }
                        }
                        
                        // MARK: - Rankings List
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(searchText.isEmpty ? "ТАБЛИЦА РЕЙТИНГА" : "РЕЗУЛЬТАТЫ ПОИСКА")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("Всего игроков: \(sortedEntries.count)")
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 4)
                            
                            if filteredEntries.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "person.slash")
                                        .font(.system(size: 36))
                                        .foregroundColor(.secondary)
                                    Text("Игроки не найдены")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(Array(filteredEntries.enumerated()), id: \.element.id) { index, entry in
                                        let actualRank = (sortedEntries.firstIndex(where: { $0.id == entry.id }) ?? index) + 1
                                        
                                        LeaderboardRow(
                                            rank: actualRank,
                                            entry: entry,
                                            viewModel: viewModel
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .refreshable {
                await viewModel.refreshOnlineLeaderboard()
            }
            .task {
                await viewModel.refreshOnlineLeaderboard()
            }
            .searchable(text: $searchText, prompt: "Поиск по игрокам")
            .navigationTitle("Таблица лидеров")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - User Rank Banner

private struct UserRankBanner: View {
    @ObservedObject var viewModel: GameViewModel
    let rank: Int
    let name: String
    let score: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(viewModel.currentAccentColor)
                    .frame(width: 52, height: 52)
                    .shadow(color: viewModel.currentAccentColor.opacity(0.35), radius: 6, x: 0, y: 3)
                
                Text(String(name.prefix(1)).uppercased())
                    .font(.title3.weight(.black))
                    .foregroundColor(viewModel.currentAccentTextColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(name)
                        .font(.headline.weight(.bold))
                    
                    Text("ВЫ")
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(viewModel.currentAccentColor.opacity(0.2))
                        .foregroundColor(viewModel.currentAccentColor)
                        .clipShape(Capsule())
                }
                
                Text(viewModel.playerRankTitle)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "circle.circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundColor(viewModel.currentAccentColor)
                    Text(score)
                        .font(.headline.weight(.heavy))
                        .foregroundColor(.primary)
                }
                
                Text("Ранг #\(rank)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(viewModel.currentAccentColor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(viewModel.currentAccentColor.opacity(0.4), lineWidth: 1.5)
                )
        )
    }
}

// MARK: - Top Three Podium

private struct TopThreePodium: View {
    let first: LeaderboardEntry
    let second: LeaderboardEntry
    let third: LeaderboardEntry
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            // Rank 2: Silver
            PodiumColumn(
                entry: second,
                rank: 2,
                height: 120,
                color: Color(red: 0.75, green: 0.75, blue: 0.78),
                badgeIcon: "🥈",
                viewModel: viewModel
            )
            
            // Rank 1: Gold (Highest)
            PodiumColumn(
                entry: first,
                rank: 1,
                height: 145,
                color: Color(red: 1.0, green: 0.84, blue: 0.0),
                badgeIcon: "👑",
                viewModel: viewModel
            )
            
            // Rank 3: Bronze
            PodiumColumn(
                entry: third,
                rank: 3,
                height: 100,
                color: Color(red: 0.80, green: 0.50, blue: 0.20),
                badgeIcon: "🥉",
                viewModel: viewModel
            )
        }
        .padding(.vertical, 8)
    }
}

private struct PodiumColumn: View {
    let entry: LeaderboardEntry
    let rank: Int
    let height: CGFloat
    let color: Color
    let badgeIcon: String
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 6) {
            Text(badgeIcon)
                .font(.system(size: rank == 1 ? 26 : 22))
            
            ZStack {
                Circle()
                    .fill(Color(hex: entry.avatarColorHex) ?? viewModel.currentAccentColor)
                    .frame(width: rank == 1 ? 46 : 40, height: rank == 1 ? 46 : 40)
                    .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 3)
                
                Text(String(entry.name.prefix(1)).uppercased())
                    .font(.system(size: rank == 1 ? 16 : 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(entry.name)
                .font(.system(size: 11, weight: .bold))
                .lineLimit(1)
                .foregroundColor(.primary)
            
            Text("\(viewModel.formatNumber(entry.score))")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundColor(color)
                .lineLimit(1)
            
            // Pillar box
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.25), color.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(color.opacity(0.4), lineWidth: 1)
                    )
                
                Text("#\(rank)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(color)
            }
            .frame(height: height)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Leaderboard Row

private struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        HStack(spacing: 14) {
            // Rank Number
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(rankColor(rank).opacity(0.2))
                        .frame(width: 28, height: 28)
                }
                
                Text("#\(rank)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(rankColor(rank))
            }
            .frame(width: 32)
            
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: entry.avatarColorHex) ?? viewModel.currentAccentColor)
                    .frame(width: 38, height: 38)
                
                Text(String(entry.name.prefix(1)).uppercased())
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Name
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(entry.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if entry.isUser || entry.id == viewModel.playerId {
                        Text("ВЫ")
                            .font(.system(size: 9, weight: .black))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(viewModel.currentAccentColor.opacity(0.2))
                            .foregroundColor(viewModel.currentAccentColor)
                            .clipShape(Capsule())
                    }
                }
            }
            
            Spacer()
            
            // Score
            HStack(spacing: 4) {
                Image(systemName: "circle.circle.fill")
                    .font(.system(size: 11))
                    .foregroundColor(viewModel.currentAccentColor)
                
                Text(viewModel.formatNumber(entry.score))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    (entry.isUser || entry.id == viewModel.playerId)
                        ? viewModel.currentAccentColor.opacity(0.12)
                        : Color(uiColor: .secondarySystemGroupedBackground).opacity(0.85)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            (entry.isUser || entry.id == viewModel.playerId)
                                ? viewModel.currentAccentColor.opacity(0.4)
                                : Color.clear,
                            lineWidth: 1.5
                        )
                )
        )
    }
    
    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.78) // Silver
        case 3: return Color(red: 0.80, green: 0.50, blue: 0.20) // Bronze
        default: return .secondary
        }
    }
}

// MARK: - Color Hex Helper

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

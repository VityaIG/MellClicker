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
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - User Status Card
                    UserRankBanner(
                        viewModel: viewModel,
                        rank: viewModel.userRank,
                        name: viewModel.effectiveUsername,
                        score: viewModel.formattedBalance
                    )
                    
                    // MARK: - Top 3 Podium (if not searching)
                    if searchText.isEmpty && sortedEntries.count >= 3 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ТОП ИГРОКОВ")
                                .font(.caption.weight(.semibold))
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
                            Text(searchText.isEmpty ? "ВСЕ УЧАСТНИКИ" : "РЕЗУЛЬТАТЫ ПОИСКА")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("Всего: \(sortedEntries.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 4)
                        
                        VStack(spacing: 8) {
                            ForEach(Array(filteredEntries.enumerated()), id: \.element.id) { index, entry in
                                // Find actual global rank in sorted array
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
                .padding()
            }
            .searchable(text: $searchText, prompt: "Поиск по игрокам")
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
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
            // Rank badge
            ZStack {
                Circle()
                    .fill(viewModel.currentAccentColor)
                    .frame(width: 52, height: 52)
                
                VStack(spacing: 0) {
                    Text("#\(rank)")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(viewModel.currentAccentTextColor)
                    Text("РАНГ")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(viewModel.currentAccentTextColor.opacity(0.8))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(name)
                        .font(.headline.weight(.bold))
                        .lineLimit(1)
                    
                    Text("ВЫ")
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(viewModel.currentAccentColor.opacity(0.2))
                        .foregroundColor(viewModel.currentAccentColor)
                        .clipShape(Capsule())
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "circle.circle.fill")
                        .font(.caption)
                        .foregroundColor(viewModel.currentAccentColor)
                    Text("\(score) монет")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if viewModel.passiveIncomePerSecond > 0 {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("ДОХОД")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)
                    Text("+\(viewModel.passiveIncomePerSecond)/с")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(viewModel.currentAccentColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(10)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(viewModel.currentAccentColor.opacity(0.4), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Top 3 Podium

private struct TopThreePodium: View {
    let first: LeaderboardEntry
    let second: LeaderboardEntry
    let third: LeaderboardEntry
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            // 2nd Place
            PodiumColumn(
                rank: 2,
                entry: second,
                medal: "🥈",
                badgeColor: Color(uiColor: .systemGray2),
                height: 140,
                viewModel: viewModel
            )
            
            // 1st Place
            PodiumColumn(
                rank: 1,
                entry: first,
                medal: "👑",
                badgeColor: Color.yellow,
                height: 165,
                viewModel: viewModel
            )
            
            // 3rd Place
            PodiumColumn(
                rank: 3,
                entry: third,
                medal: "🥉",
                badgeColor: Color.orange.opacity(0.8),
                height: 120,
                viewModel: viewModel
            )
        }
        .padding(.vertical, 8)
    }
}

private struct PodiumColumn: View {
    let rank: Int
    let entry: LeaderboardEntry
    let medal: String
    let badgeColor: Color
    let height: CGFloat
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            // Medal / Crown
            Text(medal)
                .font(.system(size: rank == 1 ? 28 : 22))
            
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: entry.avatarColorHex) ?? .gray)
                    .frame(width: rank == 1 ? 52 : 44, height: rank == 1 ? 52 : 44)
                
                Text(String(entry.name.prefix(1)).uppercased())
                    .font(.system(size: rank == 1 ? 20 : 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Name
            Text(entry.name)
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            // Score
            HStack(spacing: 2) {
                Image(systemName: "circle.circle.fill")
                    .font(.system(size: 9))
                    .foregroundColor(viewModel.currentAccentColor)
                Text(formatCompact(entry.score))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            // Podium base
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(entry.isUser ? viewModel.currentAccentColor : Color.clear, lineWidth: 1.5)
                    )
                
                Text("#\(rank)")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(badgeColor)
            }
            .frame(height: height * 0.4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    private func formatCompact(_ score: Int) -> String {
        if score >= 1_000_000 {
            return String(format: "%.1fM", Double(score) / 1_000_000.0)
        } else if score >= 1_000 {
            return String(format: "%.1fK", Double(score) / 1_000.0)
        } else {
            return "\(score)"
        }
    }
}

// MARK: - Leaderboard Row

private struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    @ObservedObject var viewModel: GameViewModel
    
    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(uiColor: .systemGray2)
        case 3: return .orange
        default: return .secondary
        }
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Rank Number
            Text("\(rank)")
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(rankColor)
                .frame(width: 32, alignment: .center)
            
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: entry.avatarColorHex) ?? .gray)
                    .frame(width: 40, height: 40)
                
                Text(String(entry.name.prefix(1)).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Player info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(entry.name)
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                    
                    if entry.isUser {
                        Text("ВЫ")
                            .font(.system(size: 9, weight: .black))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(viewModel.currentAccentColor.opacity(0.2))
                            .foregroundColor(viewModel.currentAccentColor)
                            .clipShape(Capsule())
                    }
                }
                
                Text(rankSubtitle(for: rank))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Score
            HStack(spacing: 4) {
                Image(systemName: "circle.circle.fill")
                    .font(.caption2)
                    .foregroundColor(viewModel.currentAccentColor)
                Text(viewModel.formatNumber(entry.score))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(entry.isUser ? viewModel.currentAccentColor.opacity(0.08) : Color(uiColor: .secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(entry.isUser ? viewModel.currentAccentColor.opacity(0.5) : Color.clear, lineWidth: 1.5)
                )
        )
    }
    
    private func rankSubtitle(for rank: Int) -> String {
        switch rank {
        case 1: return "Абсолютный чемпион"
        case 2...3: return "Мастер кликов"
        case 4...10: return "Элитный кликер"
        default: return "Участник"
        }
    }
}

// MARK: - Color Hex Helper

private extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

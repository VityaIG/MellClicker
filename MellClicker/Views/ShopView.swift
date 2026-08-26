import SwiftUI

struct ShopView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackgroundView(viewModel: viewModel)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - Balance Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ТЕКУЩИЙ БАЛАНС")
                                .font(.caption.weight(.black))
                                .foregroundColor(.secondary)
                                .tracking(1.5)
                            
                            HStack(spacing: 10) {
                                Image(systemName: "circle.circle.fill")
                                    .foregroundColor(viewModel.currentAccentColor)
                                    .font(.title)
                                
                                Text(viewModel.formattedBalance)
                                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                            }
                            
                            HStack(spacing: 16) {
                                HStack(spacing: 4) {
                                    Image(systemName: "hand.tap.fill")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("Клик: x\(viewModel.clickMultiplier)")
                                        .font(.caption.weight(.semibold))
                                }
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "bolt.fill")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("Автодоход: +\(viewModel.autoClickerCount)/сек")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(viewModel.autoClickerCount > 0 ? viewModel.currentAccentColor : .secondary)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.88))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .strokeBorder(viewModel.currentAccentColor.opacity(0.2), lineWidth: 1)
                                )
                        )
                        
                        // MARK: - Shop Items
                        VStack(alignment: .leading, spacing: 14) {
                            Text("УЛУЧШЕНИЯ")
                                .font(.caption.weight(.black))
                                .foregroundColor(.secondary)
                                .tracking(1.5)
                                .padding(.horizontal, 4)
                            
                            // Item 1: Chekushka (x2 Click Power)
                            ShopItemCard(
                                viewModel: viewModel,
                                icon: "hand.tap.fill",
                                iconColor: viewModel.currentAccentColor,
                                title: "Чекушка",
                                description: "Удваивает базовую силу каждого нажатия.",
                                stats: "Множитель: x\(viewModel.clickMultiplier) -> x\(viewModel.clickMultiplier * 2)",
                                cost: viewModel.formattedChekushkaCost,
                                rawCost: viewModel.chekushkaCost,
                                canAfford: viewModel.balance >= viewModel.chekushkaCost,
                                action: { viewModel.buyChekushka() }
                            )
                            
                            // Item 2: Chekunec (Duplicating Auto-Clicker x2)
                            let currentRate = viewModel.autoClickerCount
                            let nextRate = currentRate == 0 ? 1 : currentRate * 2
                            ShopItemCard(
                                viewModel: viewModel,
                                icon: "bolt.fill",
                                iconColor: .blue,
                                title: "Чекунец",
                                description: "Удваивает автоматический доход монет каждую секунду.",
                                stats: "Автодоход: +\(currentRate) -> +\(nextRate)/сек (x2)",
                                cost: viewModel.formattedChekunecCost,
                                rawCost: viewModel.chekunecCost,
                                canAfford: viewModel.balance >= viewModel.chekunecCost,
                                action: { viewModel.buyChekunec() }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Магазин")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ShopItemCard: View {
    @ObservedObject var viewModel: GameViewModel
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let stats: String
    let cost: String
    let rawCost: Int
    let canAfford: Bool
    let action: () -> Void
    
    var progress: Double {
        if canAfford { return 1.0 }
        guard rawCost > 0 else { return 0.0 }
        return min(1.0, max(0.0, Double(viewModel.balance) / Double(rawCost)))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(iconColor.opacity(0.18))
                        .frame(width: 54, height: 54)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(iconColor)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline.weight(.bold))
                    
                    Text(stats)
                        .font(.caption.weight(.bold))
                        .foregroundColor(iconColor)
                    
                    Text(description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Buy Button
                Button(action: action) {
                    VStack(spacing: 2) {
                        Text("Купить")
                            .font(.system(size: 11, weight: .black))
                            .textCase(.uppercase)
                        
                        HStack(spacing: 2) {
                            Image(systemName: "circle.circle.fill")
                                .font(.system(size: 9))
                            Text(cost)
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(minWidth: 84)
                    .background(canAfford ? iconColor : Color(uiColor: .systemGray5))
                    .foregroundColor(canAfford ? viewModel.currentAccentTextColor : .secondary)
                    .clipShape(Capsule())
                    .shadow(color: canAfford ? iconColor.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 3)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!canAfford)
            }
            
            // Progress to next purchase
            if !canAfford {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(uiColor: .systemGray5))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(iconColor)
                            .frame(width: geo.size.width * CGFloat(progress), height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(canAfford ? iconColor.opacity(0.35) : Color.clear, lineWidth: 1.5)
                )
        )
    }
}

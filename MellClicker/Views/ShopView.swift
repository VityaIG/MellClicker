import SwiftUI

struct ShopView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Balance Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Текущий баланс")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "circle.circle.fill")
                                .foregroundColor(viewModel.currentAccentColor)
                                .font(.title)
                            
                            Text(viewModel.formattedBalance)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    
                    // MARK: - Shop Items
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Улучшения")
                            .font(.title2.weight(.bold))
                            .padding(.top, 8)
                        
                        // Item 1: Chekushka
                        ShopItemCard(
                            viewModel: viewModel,
                            icon: "hand.tap.fill",
                            iconColor: viewModel.currentAccentColor,
                            title: "Чекушка",
                            description: "Каждая покупка удваивает силу клика.",
                            stats: "Множитель: x\(viewModel.clickMultiplier) -> x\(viewModel.clickMultiplier * 2)",
                            cost: viewModel.formattedChekushkaCost,
                            canAfford: viewModel.balance >= viewModel.chekushkaCost,
                            action: { viewModel.buyChekushka() }
                        )
                        
                        // Item 2: Chekunec
                        ShopItemCard(
                            viewModel: viewModel,
                            icon: "bolt.fill",
                            iconColor: .blue,
                            title: "Чекунец",
                            description: "Автоматически приносит +1/сек.",
                            stats: "Куплено: \(viewModel.autoClickerCount) шт. (+1/сек)",
                            cost: viewModel.formattedChekunecCost,
                            canAfford: viewModel.balance >= viewModel.chekunecCost,
                            action: { viewModel.buyChekunec() }
                        )
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
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
    let canAfford: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(stats)
                    .font(.caption.weight(.medium))
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
                        .font(.caption2.weight(.bold))
                        .textCase(.uppercase)
                    
                    HStack(spacing: 2) {
                        Image(systemName: "circle.circle.fill")
                            .font(.system(size: 10))
                        Text(cost)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(minWidth: 80)
                .background(canAfford ? iconColor : Color(uiColor: .systemGray5))
                .foregroundColor(canAfford ? viewModel.currentAccentTextColor : .secondary)
                .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!canAfford)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

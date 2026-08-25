import SwiftUI

/// Shop View providing upgrades ("Чекушка" and "Чекунец") using native iOS List and Section components.
struct ShopView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Current Balance Header
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Доступный баланс")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "circle.circle.fill")
                                    .foregroundColor(.orange)
                                Text(viewModel.formattedBalance)
                                    .font(.title2.weight(.bold))
                                    .contentTransition(.numericText())
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Пассивный доход")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("+\(viewModel.passiveIncomePerSecond) / сек")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Manual Click Upgrade: Чекушка
                Section(
                    header: Text("Улучшения клика"),
                    footer: Text("Каждая «Чекушка» удваивает количество очков, получаемых за одно нажатие.")
                ) {
                    HStack(spacing: 16) {
                        // Icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "flame.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Чекушка")
                                .font(.headline)
                            
                            Text("Множитель: x\(viewModel.clickMultiplier) → x\(viewModel.clickMultiplier * 2)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Buy Button
                        Button(action: {
                            viewModel.buyChekushka()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "circle.circle.fill")
                                    .font(.caption2)
                                Text("\(viewModel.chekushkaCost)")
                                    .font(.subheadline.weight(.bold))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(viewModel.balance >= viewModel.chekushkaCost ? Color.orange : Color(uiColor: .systemGray5))
                            .foregroundColor(viewModel.balance >= viewModel.chekushkaCost ? .white : .secondary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(viewModel.balance < viewModel.chekushkaCost)
                    }
                    .padding(.vertical, 6)
                }
                
                // MARK: - Auto-Clicker Upgrade: Чекунец
                Section(
                    header: Text("Автоматизация"),
                    footer: Text("«Чекунец» автоматически приносит очки каждую секунду и воспроизводит фирменный звук.")
                ) {
                    HStack(spacing: 16) {
                        // Icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "bolt.badge.clock.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.blue)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Чекунец")
                                .font(.headline)
                            
                            Text("Куплено: \(viewModel.autoClickerCount) шт. (+1/сек)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Buy Button
                        Button(action: {
                            viewModel.buyChekunec()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "circle.circle.fill")
                                    .font(.caption2)
                                Text("\(viewModel.chekunecCost)")
                                    .font(.subheadline.weight(.bold))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(viewModel.balance >= viewModel.chekunecCost ? Color.blue : Color(uiColor: .systemGray5))
                            .foregroundColor(viewModel.balance >= viewModel.chekunecCost ? .white : .secondary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(viewModel.balance < viewModel.chekunecCost)
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Магазин")
        }
    }
}

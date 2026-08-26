import SwiftUI
import UIKit

/// Shop View managing purchases for "Чекушка" (multiplier x2) and "Чекунец" (passive +1/s auto-clicker).
struct ShopView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Баланс
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Текущий баланс")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "circle.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                                
                                Text(viewModel.formattedBalance)
                                    .font(.title2.weight(.bold))
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Товар 1: Чекушка
                Section(header: Text("Улучшение клика"), footer: Text("Каждая покупка удваивает силу каждого вашего нажатия.")) {
                    HStack(spacing: 16) {
                        // Icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.orange)
                        }
                        
                        // Title & Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Чекушка")
                                .font(.headline)
                            
                            Text("Текущий множитель: x\(viewModel.clickMultiplier) (станет x\(viewModel.clickMultiplier * 2))")
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
                                Text("\(viewModel.formattedChekushkaCost)")
                                    .font(.subheadline.weight(.bold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
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
                
                // MARK: - Товар 2: Чекунец
                Section(header: Text("Автокликер (Пассивный доход)"), footer: Text("Каждый купленный Чекунец автоматически приносит +1 к балансу каждую секунду.")) {
                    HStack(spacing: 16) {
                        // Icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.blue)
                        }
                        
                        // Title & Info
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
                                Text("\(viewModel.formattedChekunecCost)")
                                    .font(.subheadline.weight(.bold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
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

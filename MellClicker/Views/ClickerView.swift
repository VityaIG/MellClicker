import SwiftUI
import UIKit

/// Model representing an individual floating "+X" animated particle when tapping.
struct FloatingNumber: Identifiable {
    let id: UUID
    let text: String
    var offset: CGSize
    var opacity: Double
    
    init(id: UUID = UUID(), text: String, offset: CGSize, opacity: Double) {
        self.id = id
        self.text = text
        self.offset = offset
        self.opacity = opacity
    }
}

/// The main Clicker Tab view featuring dynamic balance, circular action button, and spring animations.
struct ClickerView: View {
    @ObservedObject var viewModel: GameViewModel
    
    @State private var isPressed: Bool = false
    @State private var floatingNumbers: [FloatingNumber] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background subtle gradient
                LinearGradient(
                    colors: [
                        Color(uiColor: .systemGroupedBackground),
                        Color(uiColor: .secondarySystemGroupedBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // MARK: - Top Balance Display
                    VStack(spacing: 8) {
                        Text("БАЛАНС")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.5)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "circle.circle.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.orange)
                            
                            Text(viewModel.formattedBalance)
                                .font(.system(size: 42, weight: .heavy, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                        
                        // Passive Rate & Multiplier Badges
                        HStack(spacing: 12) {
                            Label("+\(viewModel.clickMultiplier) / клик", systemImage: "hand.tap.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial, in: Capsule())
                            
                            if viewModel.autoClickerCount > 0 {
                                Label("+\(viewModel.passiveIncomePerSecond) / сек", systemImage: "bolt.fill")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.ultraThinMaterial, in: Capsule())
                            }
                        }
                    }
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // MARK: - Main Clicker Button with Floating Particles
                    ZStack {
                        // Floating "+Multiplier" numbers layer
                        ForEach(floatingNumbers) { item in
                            Text(item.text)
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(.orange)
                                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                                .offset(item.offset)
                                .opacity(item.opacity)
                        }
                        
                        // Circular Click Button
                        Button(action: handleTap) {
                            ZStack {
                                // Background shadow ring
                                Circle()
                                    .fill(Color(uiColor: .systemBackground))
                                    .shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 12)
                                
                                // Image Asset
                                Image("MellButton")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 250, height: 250)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.orange.opacity(0.35), lineWidth: 4)
                                    )
                            }
                            .frame(width: 250, height: 250)
                            .scaleEffect(isPressed ? 0.90 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.5, blendDuration: 0), value: isPressed)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                    
                    // MARK: - Bottom Quick Info Card
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Чекушка (Сила)")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                            Text("x\(viewModel.clickMultiplier)")
                                .font(.headline.weight(.bold))
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Чекунец (Авто)")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                            Text("\(viewModel.autoClickerCount) шт.")
                                .font(.headline.weight(.bold))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    )
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Кликер")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Tap Interaction
    
    private func handleTap() {
        viewModel.click()
        
        isPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            isPressed = false
        }
        
        spawnFloatingNumber()
    }
    
    private func spawnFloatingNumber() {
        let randomX = CGFloat.random(in: -50...50)
        let initialOffset = CGSize(width: randomX, height: 0)
        let newNumber = FloatingNumber(
            text: "+\(viewModel.clickMultiplier)",
            offset: initialOffset,
            opacity: 1.0
        )
        
        floatingNumbers.append(newNumber)
        
        withAnimation(.easeOut(duration: 0.75)) {
            if let index = floatingNumbers.firstIndex(where: { $0.id == newNumber.id }) {
                floatingNumbers[index].offset = CGSize(width: randomX + CGFloat.random(in: -20...20), height: -120)
                floatingNumbers[index].opacity = 0.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            floatingNumbers.removeAll(where: { $0.id == newNumber.id })
        }
    }
}

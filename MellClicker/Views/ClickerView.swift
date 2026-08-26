import SwiftUI
import UIKit

struct FloatingNumber: Identifiable {
    let id: UUID
    let text: String
    var offset: CGSize
    var opacity: Double
    var scale: CGFloat
    
    init(id: UUID = UUID(), text: String, offset: CGSize, opacity: Double, scale: CGFloat = 1.0) {
        self.id = id
        self.text = text
        self.offset = offset
        self.opacity = opacity
        self.scale = scale
    }
}

struct ClickerView: View {
    @ObservedObject var viewModel: GameViewModel
    
    @State private var isPressed: Bool = false
    @State private var floatingNumbers: [FloatingNumber] = []
    
    // For the glow effect
    @State private var glowPulse: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Rich Background Gradient
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
                                .font(.system(size: 46, weight: .heavy, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
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
                    
                    // MARK: - Main Clicker Button with Glow and Particles
                    ZStack {
                        // Ambient Glow Effect
                        Circle()
                            .fill(Color.orange.opacity(0.4))
                            .frame(width: 250, height: 250)
                            .blur(radius: isPressed ? 40 : 20)
                            .scaleEffect(isPressed ? 1.1 : 1.0)
                            .animation(.easeOut(duration: 0.2), value: isPressed)
                        
                        // Pulse animation for passive income indication
                        if viewModel.autoClickerCount > 0 {
                            Circle()
                                .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                                .frame(width: 250, height: 250)
                                .scaleEffect(glowPulse ? 1.4 : 1.0)
                                .opacity(glowPulse ? 0 : 1)
                                .onAppear {
                                    withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                                        glowPulse = true
                                    }
                                }
                        }
                        
                        // Floating "+Multiplier" numbers layer
                        ForEach(floatingNumbers) { item in
                            Text(item.text)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.orange)
                                .shadow(color: .orange.opacity(0.5), radius: 8, x: 0, y: 0)
                                .offset(item.offset)
                                .scaleEffect(item.scale)
                                .opacity(item.opacity)
                        }
                        
                        // Circular Click Button
                        Button(action: handleTap) {
                            ZStack {
                                // Background shadow ring
                                Circle()
                                    .fill(Color(uiColor: .systemBackground))
                                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                                
                                // Image Asset
                                Image("MellButton")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 250, height: 250)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: [.orange, .yellow],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 6
                                            )
                                    )
                            }
                            .frame(width: 250, height: 250)
                            .scaleEffect(isPressed ? 0.88 : 1.0)
                            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: isPressed)
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
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            isPressed = false
        }
        
        spawnFloatingNumber()
    }
    
    private func spawnFloatingNumber() {
        let randomX = CGFloat.random(in: -70...70)
        let initialOffset = CGSize(width: randomX, height: -20)
        
        let newNumber = FloatingNumber(
            text: "+\(viewModel.clickMultiplier)",
            offset: initialOffset,
            opacity: 1.0,
            scale: 0.5
        )
        
        floatingNumbers.append(newNumber)
        
        withAnimation(.easeOut(duration: 0.6)) {
            if let index = floatingNumbers.firstIndex(where: { $0.id == newNumber.id }) {
                floatingNumbers[index].offset = CGSize(width: randomX + CGFloat.random(in: -30...30), height: -160)
                floatingNumbers[index].opacity = 0.0
                floatingNumbers[index].scale = 1.3
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            floatingNumbers.removeAll(where: { $0.id == newNumber.id })
        }
    }
}

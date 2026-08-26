import SwiftUI
import UIKit

struct FloatingNumber: Identifiable {
    let id: UUID
    let text: String
    var offset: CGSize
    var opacity: Double
    var scale: CGFloat
    var isFrenzy: Bool
    
    init(id: UUID = UUID(), text: String, offset: CGSize, opacity: Double, scale: CGFloat = 1.0, isFrenzy: Bool = false) {
        self.id = id
        self.text = text
        self.offset = offset
        self.opacity = opacity
        self.scale = scale
        self.isFrenzy = isFrenzy
    }
}

struct ClickerView: View {
    @ObservedObject var viewModel: GameViewModel
    
    @State private var isPressed: Bool = false
    @State private var floatingNumbers: [FloatingNumber] = []
    @State private var glowPulse: Bool = false
    @State private var frenzyFlameRotation: Double = 0
    @State private var buttonRotationAngle: Double = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Dynamic Background
                AnimatedBackgroundView(viewModel: viewModel, isClickerScreen: true)
                
                VStack(spacing: 16) {
                    // MARK: - Rank & Title Badge
                    HStack(spacing: 6) {
                        Text(viewModel.playerRankTitle)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(viewModel.currentAccentColor)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(viewModel.currentAccentColor.opacity(0.16))
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(viewModel.currentAccentColor.opacity(0.35), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.top, 8)
                    
                    // MARK: - Top Balance Display
                    VStack(spacing: 6) {
                        Text("БАЛАНС")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(2.0)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "circle.circle.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(viewModel.currentAccentColor)
                            
                            Text(viewModel.formattedBalance)
                                .font(.system(size: 46, weight: .heavy, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.4)
                        }
                        
                        // Rates and Multipliers
                        HStack(spacing: 10) {
                            Label("+\(viewModel.clickMultiplier) / клик", systemImage: "hand.tap.fill")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial, in: Capsule())
                            
                            if viewModel.autoClickerCount > 0 {
                                Label("+\(viewModel.passiveIncomePerSecond) / сек", systemImage: "bolt.fill")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(viewModel.currentAccentColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.ultraThinMaterial, in: Capsule())
                            }
                        }
                    }
                    
                    // MARK: - Dynamic Combo & Frenzy Bar
                    if viewModel.comboClicks > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: viewModel.isFrenzyActive ? "flame.fill" : "bolt.fill")
                                .foregroundColor(viewModel.isFrenzyActive ? .orange : viewModel.currentAccentColor)
                                .font(.system(size: 14, weight: .bold))
                            
                            Text(viewModel.comboTitle.isEmpty ? "Комбо: \(viewModel.comboClicks)x" : viewModel.comboTitle)
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundColor(viewModel.isFrenzyActive ? .orange : viewModel.currentAccentColor)
                            
                            Text("(+\(viewModel.effectiveClickPower) монет)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(viewModel.isFrenzyActive ? Color.orange.opacity(0.2) : Color(uiColor: .secondarySystemGroupedBackground))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            viewModel.isFrenzyActive ? Color.orange.opacity(0.8) : viewModel.currentAccentColor.opacity(0.3),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // Keep layout space stable
                        Color.clear.frame(height: 33)
                    }
                    
                    Spacer()
                    
                    // MARK: - Main Clicker Button with Dynamic Halos and Floating Numbers
                    ZStack {
                        // Frenzy Flame Halo
                        if viewModel.isFrenzyActive {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.yellow.opacity(0.8), .orange.opacity(0.5), .red.opacity(0.2), .clear],
                                        center: .center,
                                        startRadius: 80,
                                        endRadius: 170
                                    )
                                )
                                .frame(width: 340, height: 340)
                                .blur(radius: 24)
                                .rotationEffect(.degrees(frenzyFlameRotation))
                                .onAppear {
                                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                                        frenzyFlameRotation = 360
                                    }
                                }
                        }
                        
                        // Ambient Pulsing Core Glow
                        Circle()
                            .fill(viewModel.currentAccentColor.opacity(viewModel.isFrenzyActive ? 0.65 : 0.35))
                            .frame(width: 260, height: 260)
                            .blur(radius: isPressed ? 45 : 24)
                            .scaleEffect(isPressed ? 1.15 : 1.0)
                            .animation(.easeOut(duration: 0.16), value: isPressed)
                        
                        // Pulse ring for passive auto-clicker income
                        if viewModel.autoClickerCount > 0 {
                            Circle()
                                .stroke(viewModel.currentAccentColor.opacity(0.4), lineWidth: 2.5)
                                .frame(width: 250, height: 250)
                                .scaleEffect(glowPulse ? 1.4 : 1.0)
                                .opacity(glowPulse ? 0 : 0.8)
                                .onAppear {
                                    withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
                                        glowPulse = true
                                    }
                                }
                        }
                        
                        // Floating Numbers Layer
                        ForEach(floatingNumbers) { item in
                            Text(item.text)
                                .font(.system(size: item.isFrenzy ? 32 : 28, weight: .black, design: .rounded))
                                .foregroundColor(item.isFrenzy ? .orange : viewModel.currentAccentColor)
                                .shadow(color: (item.isFrenzy ? Color.orange : viewModel.currentAccentColor).opacity(0.6), radius: 8, x: 0, y: 0)
                                .offset(item.offset)
                                .scaleEffect(item.scale)
                                .opacity(item.opacity)
                        }
                        
                        // Clicker Button
                        Button(action: handleTap) {
                            ZStack {
                                Circle()
                                    .fill(Color(uiColor: .systemBackground))
                                    .shadow(
                                        color: viewModel.isFrenzyActive ? Color.orange.opacity(0.5) : Color.black.opacity(0.25),
                                        radius: viewModel.isFrenzyActive ? 30 : 20,
                                        x: 0,
                                        y: 8
                                    )
                                
                                Image("MellButton")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 250, height: 250)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: viewModel.isFrenzyActive
                                                        ? [.yellow, .orange, .red]
                                                        : [viewModel.currentAccentColor, viewModel.currentAccentColor.opacity(0.6)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: viewModel.isFrenzyActive ? 8 : 5
                                            )
                                    )
                            }
                            .frame(width: 250, height: 250)
                            .scaleEffect(isPressed ? 0.85 : 1.0)
                            .rotationEffect(.degrees(buttonRotationAngle))
                            .animation(.interactiveSpring(response: 0.22, dampingFraction: 0.42, blendDuration: 0), value: isPressed)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                    
                    // MARK: - Bottom Stats Info Bar
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Чекушка (Сила)")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.secondary)
                            Text("x\(viewModel.clickMultiplier)")
                                .font(.headline.weight(.heavy))
                        }
                        
                        Divider()
                            .frame(height: 28)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Чекунец (Авто)")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.secondary)
                            Text("+\(viewModel.autoClickerCount)/сек")
                                .font(.headline.weight(.heavy))
                                .foregroundColor(viewModel.autoClickerCount > 0 ? viewModel.currentAccentColor : .primary)
                        }
                        
                        Divider()
                            .frame(height: 28)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Рекорд комбо")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.secondary)
                            Text("\(viewModel.maxCombo)x")
                                .font(.headline.weight(.heavy))
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.9))
                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Кликер")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Tap Interaction
    
    private func handleTap() {
        let earned = viewModel.effectiveClickPower
        let wasFrenzy = viewModel.isFrenzyActive
        
        viewModel.click()
        
        isPressed = true
        withAnimation(.easeInOut(duration: 0.08)) {
            buttonRotationAngle = Double.random(in: -3.5...3.5)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            isPressed = false
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                buttonRotationAngle = 0
            }
        }
        
        spawnFloatingNumber(earned: earned, isFrenzy: wasFrenzy)
    }
    
    private func spawnFloatingNumber(earned: Int, isFrenzy: Bool) {
        let randomX = CGFloat.random(in: -75...75)
        let initialOffset = CGSize(width: randomX, height: -25)
        
        let text = isFrenzy ? "+\(earned) 🔥" : "+\(earned)"
        let newNumber = FloatingNumber(
            text: text,
            offset: initialOffset,
            opacity: 1.0,
            scale: 0.6,
            isFrenzy: isFrenzy
        )
        
        floatingNumbers.append(newNumber)
        
        withAnimation(.easeOut(duration: 0.55)) {
            if let index = floatingNumbers.firstIndex(where: { $0.id == newNumber.id }) {
                floatingNumbers[index].offset = CGSize(width: randomX + CGFloat.random(in: -25...25), height: -165)
                floatingNumbers[index].opacity = 0.0
                floatingNumbers[index].scale = isFrenzy ? 1.4 : 1.2
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            floatingNumbers.removeAll(where: { $0.id == newNumber.id })
        }
    }
}

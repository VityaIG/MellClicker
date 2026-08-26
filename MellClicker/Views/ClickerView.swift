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
    @State private var haloRotation: Double = 0
    @State private var buttonRotationAngle: Double = 0
    @State private var buttonTiltX: Double = 0
    @State private var buttonTiltY: Double = 0
    
    // Combo milestones: 10, 25, 50
    private var nextMilestone: Int {
        if viewModel.comboClicks < 10 { return 10 }
        if viewModel.comboClicks < 25 { return 25 }
        if viewModel.comboClicks < 50 { return 50 }
        return 100
    }
    
    private var prevMilestone: Int {
        if viewModel.comboClicks < 10 { return 0 }
        if viewModel.comboClicks < 25 { return 10 }
        if viewModel.comboClicks < 50 { return 25 }
        return 50
    }
    
    private var comboProgress: Double {
        let current = Double(viewModel.comboClicks - prevMilestone)
        let total = Double(nextMilestone - prevMilestone)
        return min(max(current / total, 0.0), 1.0)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Dynamic Background
                AnimatedBackgroundView(viewModel: viewModel, isClickerScreen: true)
                
                VStack(spacing: 12) {
                    // MARK: - Top Balance Display (Clean & Prominent without rank badge)
                    VStack(spacing: 8) {
                        Text("БАЛАНС")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(2.5)
                            .padding(.top, 4)
                        
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [viewModel.currentAccentColor, viewModel.currentAccentColor.opacity(0.4)],
                                            center: .center,
                                            startRadius: 2,
                                            endRadius: 18
                                        )
                                    )
                                    .frame(width: 38, height: 38)
                                    .shadow(color: viewModel.currentAccentColor.opacity(0.5), radius: 8, x: 0, y: 2)
                                
                                Image(systemName: "circle.circle.fill")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text(viewModel.formattedBalance)
                                .font(.system(size: 48, weight: .heavy, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.4)
                        }
                        
                        // Rates and Multipliers in polished frosted capsules
                        HStack(spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(viewModel.currentAccentColor)
                                Text("+\(viewModel.clickMultiplier) / клик")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.85))
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                                    )
                            )
                            
                            if viewModel.autoClickerCount > 0 {
                                HStack(spacing: 6) {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.orange)
                                    Text("+\(viewModel.passiveIncomePerSecond) / сек")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(viewModel.currentAccentColor)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule()
                                        .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.85))
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(Color.orange.opacity(0.25), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    
                    // MARK: - Premium Dynamic Combo HUD Bar
                    if viewModel.comboClicks > 0 {
                        VStack(spacing: 5) {
                            HStack(spacing: 8) {
                                // Dynamic animated icon
                                ZStack {
                                    Circle()
                                        .fill(viewModel.isFrenzyActive ? Color.red : Color.orange)
                                        .frame(width: 24, height: 24)
                                        .shadow(color: (viewModel.isFrenzyActive ? Color.red : Color.orange).opacity(0.6), radius: 6)
                                    
                                    Image(systemName: viewModel.isFrenzyActive ? "flame.fill" : "bolt.fill")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundColor(.white)
                                }
                                
                                // Combo Title & Multiplier
                                Text(viewModel.comboTitle.isEmpty ? "Комбо: \(viewModel.comboClicks)x" : viewModel.comboTitle)
                                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                                    .foregroundColor(viewModel.isFrenzyActive ? .orange : .primary)
                                
                                Spacer()
                                
                                // Power bonus
                                Text("+\(viewModel.effectiveClickPower) монет")
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(viewModel.isFrenzyActive ? .orange : viewModel.currentAccentColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill((viewModel.isFrenzyActive ? Color.orange : viewModel.currentAccentColor).opacity(0.18))
                                    )
                            }
                            
                            // Visual progress bar to next combo rank
                            GeometryReader { barProxy in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.secondary.opacity(0.18))
                                        .frame(height: 6)
                                    
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: viewModel.isFrenzyActive
                                                    ? [.orange, .red, .yellow]
                                                    : [viewModel.currentAccentColor, .orange],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: max(8, barProxy.size.width * CGFloat(comboProgress)), height: 6)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: comboProgress)
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.92))
                                .shadow(
                                    color: (viewModel.isFrenzyActive ? Color.orange : viewModel.currentAccentColor).opacity(0.2),
                                    radius: 12,
                                    x: 0,
                                    y: 4
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: viewModel.isFrenzyActive
                                                    ? [Color.orange.opacity(0.9), Color.red.opacity(0.7)]
                                                    : [viewModel.currentAccentColor.opacity(0.5), Color.clear],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: viewModel.isFrenzyActive ? 1.5 : 1.0
                                        )
                                )
                        )
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                    } else {
                        Color.clear.frame(height: 48)
                    }
                    
                    Spacer()
                    
                    // MARK: - Next-Gen Main Clicker Button with Layered Depth & Reactive Lighting
                    ZStack {
                        // Level 1: Outer Reactive Energy Halo (Rotates during frenzy)
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: viewModel.isFrenzyActive
                                        ? [Color.yellow.opacity(0.85), Color.orange.opacity(0.6), Color.red.opacity(0.25), Color.clear]
                                        : [viewModel.currentAccentColor.opacity(0.55), viewModel.currentAccentColor.opacity(0.2), Color.clear],
                                    center: .center,
                                    startRadius: 60,
                                    endRadius: 185
                                )
                            )
                            .frame(width: 350, height: 350)
                            .blur(radius: viewModel.isFrenzyActive ? 30 : 25)
                            .scaleEffect(isPressed ? 1.18 : (viewModel.isFrenzyActive ? 1.08 : 1.0))
                            .rotationEffect(.degrees(haloRotation))
                            .onAppear {
                                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                                    haloRotation = 360
                                }
                            }
                        
                        // Level 2: Auto-clicker continuous shockwave ring
                        if viewModel.autoClickerCount > 0 {
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [viewModel.currentAccentColor.opacity(0.8), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 270, height: 270)
                                .scaleEffect(glowPulse ? 1.45 : 0.98)
                                .opacity(glowPulse ? 0 : 0.9)
                                .onAppear {
                                    withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
                                        glowPulse = true
                                    }
                                }
                        }
                        
                        // Level 3: Dynamic Floating Numbers
                        ForEach(floatingNumbers) { item in
                            HStack(spacing: 4) {
                                Text(item.text)
                                    .font(.system(size: item.isFrenzy ? 34 : 28, weight: .black, design: .rounded))
                                    .foregroundColor(item.isFrenzy ? .yellow : viewModel.currentAccentColor)
                                    .shadow(color: (item.isFrenzy ? Color.orange : viewModel.currentAccentColor).opacity(0.8), radius: 10, x: 0, y: 0)
                            }
                            .offset(item.offset)
                            .scaleEffect(item.scale)
                            .opacity(item.opacity)
                        }
                        
                        // Level 4: The Core 3D Tactile Button
                        Button(action: handleTap) {
                            ZStack {
                                // Ambient base shadow drop
                                Circle()
                                    .fill(Color(uiColor: .systemBackground))
                                    .shadow(
                                        color: viewModel.isFrenzyActive
                                            ? Color.orange.opacity(0.6)
                                            : Color.black.opacity(isPressed ? 0.15 : 0.35),
                                        radius: isPressed ? 12 : (viewModel.isFrenzyActive ? 32 : 24),
                                        x: 0,
                                        y: isPressed ? 4 : 12
                                    )
                                
                                // High-res Button Image Artwork
                                Image("MellButton")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 254, height: 254)
                                    .clipShape(Circle())
                                
                                // Bevel & Specular Gloss Glass Layer
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(isPressed ? 0.05 : 0.30),
                                                Color.clear,
                                                Color.black.opacity(0.20)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 254, height: 254)
                                
                                // Luxury Metallic Accent Rim
                                Circle()
                                    .strokeBorder(
                                        AngularGradient(
                                            colors: viewModel.isFrenzyActive
                                                ? [.yellow, .orange, .red, .purple, .yellow]
                                                : [
                                                    Color.white.opacity(0.8),
                                                    viewModel.currentAccentColor,
                                                    viewModel.currentAccentColor.opacity(0.4),
                                                    Color.white.opacity(0.9),
                                                    viewModel.currentAccentColor
                                                  ],
                                            center: .center
                                        ),
                                        lineWidth: viewModel.isFrenzyActive ? 7 : 5
                                    )
                                    .frame(width: 254, height: 254)
                            }
                            .frame(width: 254, height: 254)
                            .scaleEffect(isPressed ? 0.88 : 1.0)
                            .rotationEffect(.degrees(buttonRotationAngle))
                            .rotation3DEffect(.degrees(buttonTiltX), axis: (x: 1, y: 0, z: 0))
                            .rotation3DEffect(.degrees(buttonTiltY), axis: (x: 0, y: 1, z: 0))
                            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.45, blendDuration: 0), value: isPressed)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                    
                    // MARK: - Bottom Stats Info Bar (Apple HIG Glassmorphism)
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Чекушка (Сила)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            Text("x\(viewModel.clickMultiplier)")
                                .font(.system(size: 17, weight: .heavy, design: .rounded))
                        }
                        
                        Divider()
                            .frame(height: 28)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Чекунец (Авто)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            Text("+\(viewModel.autoClickerCount)/сек")
                                .font(.system(size: 17, weight: .heavy, design: .rounded))
                                .foregroundColor(viewModel.autoClickerCount > 0 ? viewModel.currentAccentColor : .primary)
                        }
                        
                        Divider()
                            .frame(height: 28)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Рекорд комбо")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            Text("\(viewModel.maxCombo)x")
                                .font(.system(size: 17, weight: .heavy, design: .rounded))
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.92))
                            .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    )
                    .padding(.bottom, 12)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Кликер")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Tap Interaction Logic
    
    private func handleTap() {
        let earned = viewModel.effectiveClickPower
        let wasFrenzy = viewModel.isFrenzyActive
        
        viewModel.click()
        
        isPressed = true
        withAnimation(.easeInOut(duration: 0.06)) {
            buttonRotationAngle = Double.random(in: -4.0...4.0)
            buttonTiltX = Double.random(in: -6.0...6.0)
            buttonTiltY = Double.random(in: -6.0...6.0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            isPressed = false
            withAnimation(.spring(response: 0.24, dampingFraction: 0.52)) {
                buttonRotationAngle = 0
                buttonTiltX = 0
                buttonTiltY = 0
            }
        }
        
        spawnFloatingNumber(earned: earned, isFrenzy: wasFrenzy)
    }
    
    private func spawnFloatingNumber(earned: Int, isFrenzy: Bool) {
        let randomX = CGFloat.random(in: -80...80)
        let initialOffset = CGSize(width: randomX, height: -20)
        
        let text = isFrenzy ? "+\(earned) 🔥" : "+\(earned)"
        let newNumber = FloatingNumber(
            text: text,
            offset: initialOffset,
            opacity: 1.0,
            scale: 0.5,
            isFrenzy: isFrenzy
        )
        
        floatingNumbers.append(newNumber)
        
        withAnimation(.easeOut(duration: 0.6)) {
            if let index = floatingNumbers.firstIndex(where: { $0.id == newNumber.id }) {
                floatingNumbers[index].offset = CGSize(width: randomX + CGFloat.random(in: -30...30), height: -180)
                floatingNumbers[index].opacity = 0.0
                floatingNumbers[index].scale = isFrenzy ? 1.45 : 1.25
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            floatingNumbers.removeAll(where: { $0.id == newNumber.id })
        }
    }
}

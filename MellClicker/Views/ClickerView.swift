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
                // High-performance power-efficient background
                AnimatedBackgroundView(viewModel: viewModel, isClickerScreen: true)
                
                VStack(spacing: 16) {
                    // MARK: - Top Balance Display (Spaced down from nav bar)
                    VStack(spacing: 8) {
                        Text("БАЛАНС")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(2.5)
                        
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
                                
                                Image(systemName: "circle.circle.fill")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text(viewModel.formattedBalance)
                                .font(.system(size: 48, weight: .heavy, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.4)
                        }
                        
                        // Rates and Multipliers in frosted capsules
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
                    .padding(.top, 28)
                    
                    // MARK: - Dynamic Combo HUD Bar (Can be toggled in Settings)
                    if viewModel.showComboHUD && viewModel.comboClicks > 0 {
                        VStack(spacing: 5) {
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(viewModel.isFrenzyActive ? Color.red : Color.orange)
                                        .frame(width: 24, height: 24)
                                    
                                    Image(systemName: viewModel.isFrenzyActive ? "flame.fill" : "bolt.fill")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundColor(.white)
                                }
                                
                                Text(viewModel.comboTitle.isEmpty ? "Комбо: \(viewModel.comboClicks)x" : viewModel.comboTitle)
                                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                                    .foregroundColor(viewModel.isFrenzyActive ? .orange : .primary)
                                
                                Spacer()
                                
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
                            
                            // Visual progress bar
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
                                    color: (viewModel.isFrenzyActive ? Color.orange : viewModel.currentAccentColor).opacity(0.15),
                                    radius: 8,
                                    x: 0,
                                    y: 3
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: viewModel.isFrenzyActive
                                                    ? [Color.orange.opacity(0.9), Color.red.opacity(0.7)]
                                                    : [viewModel.currentAccentColor.opacity(0.4), Color.clear],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.0
                                        )
                                )
                        )
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                    } else {
                        Color.clear.frame(height: viewModel.showComboHUD ? 44 : 10)
                    }
                    
                    Spacer()
                    
                    // MARK: - Optimized 3D Main Clicker Button
                    ZStack {
                        // Ambient Reactive Aura
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: viewModel.isFrenzyActive
                                        ? [Color.orange.opacity(0.5), Color.clear]
                                        : [viewModel.currentAccentColor.opacity(0.3), Color.clear],
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 300, height: 300)
                            .scaleEffect(isPressed ? 1.15 : (viewModel.isFrenzyActive ? 1.05 : 1.0))
                            .animation(.easeOut(duration: 0.15), value: isPressed)
                        
                        // Floating Numbers Layer
                        ForEach(floatingNumbers) { item in
                            HStack(spacing: 4) {
                                Text(item.text)
                                    .font(.system(size: item.isFrenzy ? 34 : 28, weight: .black, design: .rounded))
                                    .foregroundColor(item.isFrenzy ? .yellow : viewModel.currentAccentColor)
                                    .shadow(color: (item.isFrenzy ? Color.orange : viewModel.currentAccentColor).opacity(0.8), radius: 8, x: 0, y: 0)
                            }
                            .offset(item.offset)
                            .scaleEffect(item.scale)
                            .opacity(item.opacity)
                        }
                        
                        // Core 3D Button
                        Button(action: handleTap) {
                            ZStack {
                                Circle()
                                    .fill(Color(uiColor: .systemBackground))
                                    .shadow(
                                        color: viewModel.isFrenzyActive
                                            ? Color.orange.opacity(0.5)
                                            : Color.black.opacity(isPressed ? 0.15 : 0.3),
                                        radius: isPressed ? 8 : (viewModel.isFrenzyActive ? 24 : 18),
                                        x: 0,
                                        y: isPressed ? 3 : 10
                                    )
                                
                                Image("MellButton")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 254, height: 254)
                                    .clipShape(Circle())
                                
                                // Gloss shine
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(isPressed ? 0.05 : 0.25),
                                                Color.clear,
                                                Color.black.opacity(0.15)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 254, height: 254)
                                
                                // Metallic Rim
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
                                        lineWidth: viewModel.isFrenzyActive ? 6 : 4.5
                                    )
                                    .frame(width: 254, height: 254)
                            }
                            .frame(width: 254, height: 254)
                            .scaleEffect(isPressed ? 0.90 : 1.0)
                            .rotationEffect(.degrees(buttonRotationAngle))
                            .rotation3DEffect(.degrees(buttonTiltX), axis: (x: 1, y: 0, z: 0))
                            .rotation3DEffect(.degrees(buttonTiltY), axis: (x: 0, y: 1, z: 0))
                            .animation(.interactiveSpring(response: 0.18, dampingFraction: 0.5, blendDuration: 0), value: isPressed)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                    
                    // MARK: - Bottom Stats Info Bar
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
                            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
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
        
        // Solid physical compression without accumulation
        withAnimation(.easeOut(duration: 0.06)) {
            isPressed = true
            buttonRotationAngle = Double.random(in: -1.5...1.5)
            buttonTiltX = Double.random(in: -2.0...2.0)
            buttonTiltY = Double.random(in: -2.0...2.0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.6)) {
                isPressed = false
                buttonRotationAngle = 0
                buttonTiltX = 0
                buttonTiltY = 0
            }
        }
        
        spawnFloatingNumber(earned: earned, isFrenzy: wasFrenzy)
    }
    
    private func spawnFloatingNumber(earned: Int, isFrenzy: Bool) {
        let randomX = CGFloat.random(in: -50...50)
        let initialOffset = CGSize(width: randomX, height: -30)
        
        let text = isFrenzy ? "+\(earned) 🔥" : "+\(earned)"
        let newNumber = FloatingNumber(
            text: text,
            offset: initialOffset,
            opacity: 1.0,
            scale: 0.7,
            isFrenzy: isFrenzy
        )
        
        // Cap max floating numbers to 6 to keep UI clean and memory minimal
        if floatingNumbers.count >= 6 {
            floatingNumbers.removeFirst()
        }
        floatingNumbers.append(newNumber)
        
        withAnimation(.easeOut(duration: 0.5)) {
            if let index = floatingNumbers.firstIndex(where: { $0.id == newNumber.id }) {
                floatingNumbers[index].offset = CGSize(width: randomX, height: -120)
                floatingNumbers[index].opacity = 0.0
                floatingNumbers[index].scale = isFrenzy ? 1.25 : 1.1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.52) {
            floatingNumbers.removeAll(where: { $0.id == newNumber.id })
        }
    }
}

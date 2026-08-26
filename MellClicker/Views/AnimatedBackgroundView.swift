import SwiftUI

/// Background particle item representing a floating star/spark in the background
struct BackgroundSpark: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var speed: Double
}

/// A high-performance luxury animated background featuring drifting ambient energy orbs,
/// rising stardust particles, and reactive pulses.
struct AnimatedBackgroundView: View {
    @ObservedObject var viewModel: GameViewModel
    var isClickerScreen: Bool = false
    
    @State private var orb1Offset = CGSize(width: -80, height: -120)
    @State private var orb2Offset = CGSize(width: 100, height: 140)
    @State private var orb3Offset = CGSize(width: 40, height: -60)
    
    @State private var sparks: [BackgroundSpark] = (0..<18).map { _ in
        BackgroundSpark(
            x: CGFloat.random(in: 0.05...0.95),
            y: CGFloat.random(in: 0.1...0.9),
            size: CGFloat.random(in: 2...6),
            opacity: Double.random(in: 0.15...0.6),
            speed: Double.random(in: 3...7)
        )
    }
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            
            ZStack {
                // Base background color
                (viewModel.isDarkMode ? Color(red: 0.06, green: 0.07, blue: 0.10) : Color(uiColor: .systemGroupedBackground))
                    .ignoresSafeArea()
                
                // MARK: - Floating Ambient Energy Orbs
                // Orb 1: Theme Accent
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                viewModel.currentAccentColor.opacity(viewModel.isDarkMode ? 0.30 : 0.20),
                                viewModel.currentAccentColor.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 180
                        )
                    )
                    .frame(width: 360, height: 360)
                    .offset(orb1Offset)
                    .blur(radius: 50)
                
                // Orb 2: Warm Gold / Frenzy Flame
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (viewModel.isFrenzyActive ? Color.red : Color.orange).opacity(viewModel.isDarkMode ? 0.25 : 0.16),
                                Color.orange.opacity(0.04),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)
                    .offset(orb2Offset)
                    .blur(radius: 60)
                
                // Orb 3: Deep Emerald / Sapphire Accent
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.purple.opacity(viewModel.isDarkMode ? 0.20 : 0.10),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                    .offset(orb3Offset)
                    .blur(radius: 55)
                
                // MARK: - Rising Star Dust Particles
                ForEach(sparks) { spark in
                    Circle()
                        .fill(viewModel.isFrenzyActive ? Color.yellow : viewModel.currentAccentColor)
                        .frame(width: spark.size, height: spark.size)
                        .position(x: spark.x * width, y: spark.y * height)
                        .opacity(spark.opacity)
                        .blur(radius: spark.size > 4 ? 0.8 : 0.2)
                        .shadow(color: viewModel.currentAccentColor.opacity(0.4), radius: spark.size)
                }
                
                // Subtle Grid/Vignette Overlay
                RadialGradient(
                    colors: [
                        Color.clear,
                        (viewModel.isDarkMode ? Color.black : Color.white).opacity(0.18)
                    ],
                    center: .center,
                    startRadius: min(width, height) * 0.4,
                    endRadius: max(width, height) * 0.8
                )
                .ignoresSafeArea()
            }
            .onAppear {
                startOrbAnimations()
                startParticleAnimation()
            }
        }
    }
    
    private func startOrbAnimations() {
        withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
            orb1Offset = CGSize(width: 90, height: 80)
        }
        withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
            orb2Offset = CGSize(width: -80, height: -90)
        }
        withAnimation(.easeInOut(duration: 11).repeatForever(autoreverses: true)) {
            orb3Offset = CGSize(width: -60, height: 110)
        }
    }
    
    private func startParticleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            for i in 0..<sparks.count {
                sparks[i].y -= 0.002 * CGFloat(sparks[i].speed / 4.0)
                if sparks[i].y < -0.05 {
                    sparks[i].y = 1.05
                    sparks[i].x = CGFloat.random(in: 0.05...0.95)
                }
            }
        }
    }
}

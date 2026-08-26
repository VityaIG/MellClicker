import SwiftUI

/// A battery-optimized, high-performance ambient background designed for smooth 120 FPS
/// without CPU heating or heavy continuous GPU compositing.
struct AnimatedBackgroundView: View {
    @ObservedObject var viewModel: GameViewModel
    var isClickerScreen: Bool = false
    
    var body: some View {
        ZStack {
            // Base background color adhering to theme mode
            (viewModel.isDarkMode ? Color(red: 0.06, green: 0.07, blue: 0.10) : Color(uiColor: .systemGroupedBackground))
                .ignoresSafeArea()
            
            // Efficient static ambient radial gradient for soft depth
            RadialGradient(
                colors: [
                    viewModel.currentAccentColor.opacity(viewModel.isDarkMode ? 0.15 : 0.08),
                    Color.clear
                ],
                center: .top,
                startRadius: 40,
                endRadius: 420
            )
            .ignoresSafeArea()
            
            if viewModel.isFrenzyActive {
                RadialGradient(
                    colors: [
                        Color.orange.opacity(viewModel.isDarkMode ? 0.18 : 0.10),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: 300
                )
                .ignoresSafeArea()
                .transition(.opacity)
            }
        }
    }
}

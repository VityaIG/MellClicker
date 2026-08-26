import SwiftUI

/// Main Content View hosting the native iOS TabView and coordinating navigation between tabs.
struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var selectedTab: TabItem = .clicker
    
    enum TabItem: Int, CaseIterable {
        case clicker
        case shop
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Кликер
            ClickerView(viewModel: viewModel)
                .tabItem {
                    Label("Кликер", systemImage: "hand.tap.fill")
                }
                .tag(TabItem.clicker)
            
            // Tab 2: Магазин
            ShopView(viewModel: viewModel)
                .tabItem {
                    Label("Магазин", systemImage: "cart.fill")
                }
                .badge(viewModel.balance >= viewModel.chekushkaCost || viewModel.balance >= viewModel.chekunecCost ? Text("!") : nil)
                .tag(TabItem.shop)
            
            // Tab 3: Настройки
            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
                .tag(TabItem.settings)
        }
        .tint(.orange)
    }
}

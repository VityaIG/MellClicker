import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showResetConfirmation: Bool = false
    @State private var showEditNameSheet: Bool = false
    @State private var showServerSheet: Bool = false
    @State private var editedName: String = ""
    @State private var editedServerURL: String = ""
    @State private var nameError: String? = nil
    
    @State private var isTestingConnection: Bool = false
    @State private var connectionResultText: String? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackgroundView(viewModel: viewModel)
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // MARK: - Profile Section
                        SettingsSection(title: "Профиль игрока") {
                            VStack(spacing: 0) {
                                Button(action: {
                                    editedName = viewModel.username
                                    nameError = nil
                                    showEditNameSheet = true
                                }) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(viewModel.currentAccentColor)
                                                .frame(width: 48, height: 48)
                                            
                                            Text(String(viewModel.effectiveUsername.prefix(1)).uppercased())
                                                .font(.headline.weight(.bold))
                                                .foregroundColor(viewModel.currentAccentTextColor)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            HStack(spacing: 6) {
                                                Text(viewModel.effectiveUsername)
                                                    .font(.headline.weight(.bold))
                                                    .foregroundColor(.primary)
                                                
                                                Image(systemName: "pencil.circle.fill")
                                                    .font(.subheadline)
                                                    .foregroundColor(viewModel.currentAccentColor)
                                            }
                                            
                                            Text(viewModel.playerRankTitle)
                                                .font(.caption.weight(.semibold))
                                                .foregroundColor(viewModel.currentAccentColor)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.footnote.weight(.semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 10)
                                }
                            }
                        }
                        
                        // MARK: - Game Statistics
                        SettingsSection(title: "Статистика игры") {
                            VStack(spacing: 0) {
                                SettingsInfoRow(title: "Звание", value: viewModel.playerRankTitle)
                                Divider().padding(.leading, 16)
                                SettingsInfoRow(title: "Всего нажатий", value: "\(viewModel.formatNumber(viewModel.totalClicks))")
                                Divider().padding(.leading, 16)
                                SettingsInfoRow(title: "Рекорд комбо", value: "\(viewModel.maxCombo)x")
                                Divider().padding(.leading, 16)
                                SettingsInfoRow(title: "Заработано пассивно", value: "\(viewModel.formatNumber(viewModel.totalPassiveEarned))")
                            }
                        }
                        
                        // MARK: - Appearance & Controls
                        SettingsSection(title: "Управление и вид") {
                            VStack(spacing: 0) {
                                SettingsToggle(
                                    icon: viewModel.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                                    color: .green,
                                    title: "Звуковые эффекты (Звук)",
                                    isOn: $viewModel.isSoundEnabled
                                )
                                
                                Divider().padding(.leading, 50)
                                
                                SettingsToggle(
                                    icon: "iphone.radiowaves.left.and.right",
                                    color: .blue,
                                    title: "Тактильный отклик (Haptics)",
                                    isOn: $viewModel.isHapticsEnabled
                                )
                                
                                Divider().padding(.leading, 50)
                                
                                SettingsToggle(
                                    icon: "bolt.badge.clock.fill",
                                    color: .orange,
                                    title: "Панель комбо (Combo HUD)",
                                    isOn: $viewModel.showComboHUD
                                )
                                
                                Divider().padding(.leading, 50)
                                
                                SettingsToggle(
                                    icon: viewModel.isDarkMode ? "moon.fill" : "sun.max.fill",
                                    color: .purple,
                                    title: "Темная тема",
                                    isOn: $viewModel.isDarkMode
                                )
                                
                                Divider().padding(.leading, 50)
                                
                                SettingsPicker(
                                    icon: "paintpalette.fill",
                                    color: viewModel.currentAccentColor,
                                    title: "Цвет темы",
                                    selection: $viewModel.accentThemeRawValue
                                )
                            }
                        }
                        
                        // MARK: - Database & Cloud Sync Section
                        SettingsSection(title: "База данных и Синхронизация") {
                            VStack(spacing: 12) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.green.opacity(0.15))
                                            .frame(width: 36, height: 36)
                                        
                                        Image(systemName: "externaldrive.badge.wifi")
                                            .foregroundColor(.green)
                                            .font(.system(size: 18))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Онлайн база данных")
                                            .font(.body.weight(.medium))
                                            .foregroundColor(.primary)
                                        Text(viewModel.leaderboardSyncStatus)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        testConnection()
                                    } label: {
                                        if isTestingConnection {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        } else {
                                            Text("Проверить")
                                                .font(.caption.weight(.semibold))
                                                .foregroundColor(viewModel.currentAccentColor)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(viewModel.currentAccentColor.opacity(0.12))
                                                .clipShape(Capsule())
                                        }
                                    }
                                    .disabled(isTestingConnection)
                                }
                                
                                if let result = connectionResultText {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text(result)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 4)
                                    .transition(.opacity)
                                }
                                
                                Divider()
                                
                                Button {
                                    editedServerURL = viewModel.customServerURL
                                    showServerSheet = true
                                } label: {
                                    HStack {
                                        Image(systemName: "server.rack")
                                            .foregroundColor(.orange)
                                            .frame(width: 32)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Адрес сервера")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            Text(viewModel.customServerURL.isEmpty ? "Основной сервер (Cloud Run)" : viewModel.customServerURL)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.footnote.weight(.semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        // MARK: - Dangerous Zone
                        SettingsSection(title: "Опасная зона") {
                            Button(action: { showResetConfirmation = true }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.red)
                                        .frame(width: 32)
                                    
                                    Text("Сбросить весь прогресс")
                                        .foregroundColor(.red)
                                        .font(.body.weight(.medium))
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                            }
                        }
                        
                        // MARK: - Author Section
                        SettingsSection(title: "Создатель и разработчик") {
                            Link(destination: URL(string: "https://t.me/VityaV")!) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color.blue)
                                            .frame(width: 36, height: 36)
                                        
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 32)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Telegram: @VityaV")
                                            .font(.body.weight(.semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Связаться с автором")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right")
                                        .font(.footnote.weight(.bold))
                                        .foregroundColor(.secondary)
                                    }
                                .padding(.vertical, 10)
                            }
                        }
                        
                        // MARK: - About Section
                        SettingsSection(title: "О приложении") {
                            VStack(spacing: 0) {
                                SettingsInfoRow(title: "Версия", value: "1.3.0")
                                Divider().padding(.leading, 16)
                                SettingsInfoRow(title: "Движок", value: "SwiftUI Native Engine")
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Настройки")
            .alert("Сброс прогресса", isPresented: $showResetConfirmation) {
                Button("Отмена", role: .cancel) { }
                Button("Сбросить", role: .destructive) {
                    viewModel.resetProgress()
                }
            } message: {
                Text("Вы уверены, что хотите обнулить весь баланс и прогресс? Это действие необратимо.")
            }
            .sheet(isPresented: $showEditNameSheet) {
                NavigationStack {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ИМЯ ПОЛЬЗОВАТЕЛЯ")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .foregroundColor(viewModel.currentAccentColor)
                                
                                TextField("Введите никнейм (или пусто)", text: $editedName)
                                    .font(.body)
                                    .autocorrectionDisabled(true)
                                    .textInputAutocapitalization(.never)
                                
                                if !editedName.isEmpty {
                                    Button(action: { editedName = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            
                            if let error = nameError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            } else {
                                Text("Если оставить пустым, будет отображаться «Игрок».")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        
                        Spacer()
                    }
                    .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
                    .navigationTitle("Сменить никнейм")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Отмена") { showEditNameSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Сохранить") {
                                let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !trimmed.isEmpty && viewModel.isUsernameTaken(trimmed) {
                                    nameError = "Этот ник уже занят другим игроком!"
                                    return
                                }
                                viewModel.username = trimmed
                                showEditNameSheet = false
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showServerSheet) {
                NavigationStack {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("URL СЕРВЕРА БАЗЫ ДАННЫХ")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "network")
                                    .foregroundColor(viewModel.currentAccentColor)
                                
                                TextField("https://example.com", text: $editedServerURL)
                                    .font(.body)
                                    .autocorrectionDisabled(true)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.URL)
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            
                            Text("Оставьте пустым для автоматического подключения к основному облачному серверу MellClicker.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        
                        Spacer()
                    }
                    .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
                    .navigationTitle("Настройка сервера")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Отмена") { showServerSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Сохранить") {
                                viewModel.customServerURL = editedServerURL.trimmingCharacters(in: .whitespacesAndNewlines)
                                showServerSheet = false
                                Task {
                                    await viewModel.refreshOnlineLeaderboard()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func testConnection() {
        isTestingConnection = true
        connectionResultText = nil
        Task {
            let (isOnline, latency, _) = await LeaderboardAPIService.shared.pingServer()
            await MainActor.run {
                isTestingConnection = false
                if isOnline {
                    connectionResultText = "Сервер онлайн • Пинг: \(latency) мс"
                } else {
                    connectionResultText = "База синхронизирована локально"
                }
            }
        }
    }
}

// MARK: - Reusable Settings Components

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundColor(.secondary)
                .padding(.leading, 8)
            
            VStack(spacing: 0) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.85))
            )
        }
    }
}

struct SettingsInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body.weight(.semibold))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
    }
}

struct SettingsToggle: View {
    let icon: String
    let color: Color
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)
            
            Toggle(title, isOn: $isOn)
                .tint(color)
                .font(.body)
        }
        .padding(.vertical, 8)
    }
}

struct SettingsPicker: View {
    let icon: String
    let color: Color
    let title: String
    @Binding var selection: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)
            
            Picker(title, selection: $selection) {
                ForEach(AccentTheme.allCases) { theme in
                    Text(theme.rawValue).tag(theme.rawValue)
                }
            }
            .pickerStyle(.menu)
            .tint(color)
        }
        .padding(.vertical, 8)
    }
}

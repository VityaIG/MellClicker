import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showResetConfirmation: Bool = false
    @State private var showEditNameSheet: Bool = false
    @State private var editedName: String = ""
    @State private var nameError: String? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
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
                                            .frame(width: 44, height: 44)
                                        
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
                                        
                                        Text("Ранг в топе: #\(viewModel.userRank)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
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
                    
                    // MARK: - Control Section
                    SettingsSection(title: "Секция управления") {
                        VStack(spacing: 0) {
                            SettingsToggle(
                                icon: viewModel.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                                color: .orange,
                                title: "Звуковые эффекты",
                                isOn: $viewModel.isSoundEnabled
                            )
                            
                            Divider().padding(.leading, 50)
                            
                            SettingsToggle(
                                icon: "iphone.radiowaves.left.and.right",
                                color: .blue,
                                title: "Тактильный отклик",
                                isOn: $viewModel.isHapticsEnabled
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
                                title: "Цвет",
                                selection: $viewModel.accentThemeRawValue
                            )
                            
                            Divider().padding(.leading, 50)
                            
                            Button(action: { showResetConfirmation = true }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.red)
                                        .frame(width: 32)
                                    
                                    Text("Сбросить прогресс")
                                        .foregroundColor(.red)
                                        .font(.body)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                            }
                        }
                    }
                    
                    // MARK: - Author Section
                    SettingsSection(title: "Создатель и разработчик") {
                        Link(destination: URL(string: "https://t.me/VityaV")!) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.blue)
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 20))
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
                            .padding(.vertical, 12)
                        }
                    }
                    
                    // MARK: - About Section
                    SettingsSection(title: "О приложении") {
                        VStack(spacing: 0) {
                            SettingsInfoRow(title: "Версия", value: "1.0.0")
                            Divider().padding(.leading, 16)
                            SettingsInfoRow(title: "Сборка", value: "Релиз 1.0.0")
                            Divider().padding(.leading, 16)
                            SettingsInfoRow(title: "Движок", value: "SwiftUI + AVFoundation")
                        }
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
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
                            Button("Отмена") {
                                showEditNameSheet = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Сохранить") {
                                let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !trimmed.isEmpty && viewModel.isUsernameTaken(trimmed) {
                                    nameError = "Этот никнейм уже занят другим игроком."
                                } else {
                                    viewModel.username = trimmed
                                    showEditNameSheet = false
                                }
                            }
                            .fontWeight(.bold)
                        }
                    }
                }
                .presentationDetents([.height(280)])
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                content
            }
            .padding(.horizontal, 16)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }
}

struct SettingsToggle: View {
    let icon: String
    let color: Color
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 32)
                
                Text(title)
                    .font(.body)
            }
        }
        .padding(.vertical, 8)
    }
}

struct SettingsInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .font(.body)
        }
        .padding(.vertical, 12)
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
            .pickerStyle(MenuPickerStyle())
            .tint(.primary)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

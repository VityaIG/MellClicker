import SwiftUI

/// Settings View providing audio/haptic toggles, game progress reset, and developer attribution using native Form.
struct SettingsView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showResetConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Секция управления
                Section(header: Text("Секция управления")) {
                    Toggle(isOn: $viewModel.isSoundEnabled) {
                        Label {
                            Text("Звуковые эффекты")
                        } icon: {
                            Image(systemName: viewModel.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Toggle(isOn: $viewModel.isHapticsEnabled) {
                        Label {
                            Text("Тактильный отклик")
                        } icon: {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Button(role: .destructive, action: {
                        showResetConfirmation = true
                    }) {
                        Label {
                            Text("Сбросить прогресс")
                                .foregroundColor(.red)
                        } icon: {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // MARK: - Секция "Создатель и разработчик"
                Section(header: Text("Создатель и разработчик")) {
                    Link(destination: URL(string: "https://t.me/VityaV")!) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color.blue)
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Telegram: @VityaV")
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.primary)
                                
                                Text("Связаться с автором")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                // MARK: - Информация о приложении
                Section(header: Text("О приложении")) {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0 (Native iOS)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Движок")
                        Spacer()
                        Text("SwiftUI + AVFoundation")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Настройки")
            .alert("Сброс прогресса", isPresented: $showResetConfirmation) {
                Button("Отмена", role: .cancel) { }
                Button("Сбросить", role: .destructive) {
                    viewModel.resetProgress()
                }
            } message: {
                Text("Вы уверены, что хотите обнулить весь накопленный баланс, множители кликов и купленных Чекунцов? Это действие необратимо.")
            }
        }
    }
}

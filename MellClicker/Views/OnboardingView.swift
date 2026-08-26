import SwiftUI

/// Two-step initial onboarding sheet:
/// Step 1: Feature introduction and game rules
/// Step 2: Username setup with unique name validation against leaderboard
struct OnboardingView: View {
    @ObservedObject var viewModel: GameViewModel
    
    @State private var currentStep: Int = 1
    @State private var inputUsername: String = ""
    
    var isDuplicate: Bool {
        viewModel.isUsernameTaken(inputUsername)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                if currentStep == 1 {
                    StepOneIntroView(viewModel: viewModel, onNext: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentStep = 2
                        }
                    })
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else {
                    StepTwoUsernameView(
                        viewModel: viewModel,
                        username: $inputUsername,
                        isDuplicate: isDuplicate,
                        onFinish: {
                            viewModel.finishOnboarding(withName: inputUsername)
                        },
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentStep = 1
                            }
                        }
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .interactiveDismissDisabled(true)
        }
    }
}

// MARK: - Step 1: Welcome & Overview

private struct StepOneIntroView: View {
    @ObservedObject var viewModel: GameViewModel
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Icon & Title
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(viewModel.currentAccentColor.opacity(0.15))
                                .frame(width: 84, height: 84)
                            
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(viewModel.currentAccentColor)
                        }
                        .padding(.top, 20)
                        
                        Text("Добро пожаловать в\nMellClicker!")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        Text("Кликайте, прокачивайте множители и станьте топ-1 в таблице лидеров!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    
                    // Highlights List
                    VStack(spacing: 14) {
                        FeatureRow(
                            icon: "hand.tap.fill",
                            iconColor: viewModel.currentAccentColor,
                            title: "Сила клика",
                            description: "Каждый клик по кнопке приносит вам монеты."
                        )
                        
                        FeatureRow(
                            icon: "multiply.circle.fill",
                            iconColor: .orange,
                            title: "«Чекушка» (x2)",
                            description: "Удваивает количество очков за одно нажатие."
                        )
                        
                        FeatureRow(
                            icon: "bolt.fill",
                            iconColor: .blue,
                            title: "«Чекунец» (Авто)",
                            description: "Приносит пассивный доход каждую секунду без нажатий."
                        )
                        
                        FeatureRow(
                            icon: "trophy.fill",
                            iconColor: .yellow,
                            title: "Таблица лидеров",
                            description: "Сравнивайте свои успехи с другими игроками в реальном времени."
                        )
                    }
                    .padding(.horizontal, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Bottom Action Button
            VStack(spacing: 12) {
                Button(action: onNext) {
                    HStack(spacing: 8) {
                        Text("Продолжить")
                            .font(.headline.weight(.bold))
                        Image(systemName: "arrow.right")
                            .font(.headline.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.currentAccentColor)
                    .foregroundColor(viewModel.currentAccentTextColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color(uiColor: .secondarySystemGroupedBackground).ignoresSafeArea())
        }
    }
}

// MARK: - Step 2: Username Picker

private struct StepTwoUsernameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var username: String
    let isDuplicate: Bool
    let onFinish: () -> Void
    let onBack: () -> Void
    
    var trimmedName: String {
        username.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(viewModel.currentAccentColor.opacity(0.15))
                                .frame(width: 84, height: 84)
                            
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(viewModel.currentAccentColor)
                        }
                        .padding(.top, 24)
                        
                        Text("Укажите имя пользователя")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        Text("Под этим ником вы будете отображаться в Таблице лидеров. Вы также можете оставить поле пустым.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    
                    // Input Card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ВАШ НИКНЕЙМ")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "at")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(isDuplicate ? .red : viewModel.currentAccentColor)
                            
                            TextField("Например: ProGamer (или пусто)", text: $username)
                                .font(.body.weight(.medium))
                                .autocorrectionDisabled(true)
                                .textInputAutocapitalization(.never)
                            
                            if !username.isEmpty {
                                Button(action: { username = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isDuplicate ? Color.red : Color.clear, lineWidth: 1.5)
                        )
                        .cornerRadius(14)
                        
                        // Validation Message
                        if isDuplicate {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                Text("Этот ник уже занят другим игроком. Выберите другой.")
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal, 4)
                            .transition(.opacity)
                        } else if trimmedName.isEmpty {
                            Text("Будет использовано стандартное имя: «Игрок»")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text("Никнейм свободен!")
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    // Rules card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ПРАВИЛА И СОВЕТЫ")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            RuleBullet(text: "Никнеймы в таблице лидеров уникальны.")
                            RuleBullet(text: "Поле можно оставить пустым — вы будете записаны как «Игрок».")
                            RuleBullet(text: "Вы сможете сменить ник в любое время в разделе «Настройки».")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Bottom Action Buttons
            VStack(spacing: 10) {
                Button(action: onFinish) {
                    HStack(spacing: 8) {
                        Text(trimmedName.isEmpty ? "Начать игру (как Игрок)" : "Сохранить и начать")
                            .font(.headline.weight(.bold))
                        Image(systemName: "checkmark")
                            .font(.headline.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isDuplicate ? Color.gray : viewModel.currentAccentColor)
                    .foregroundColor(isDuplicate ? .white : viewModel.currentAccentTextColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isDuplicate)
                
                Button(action: onBack) {
                    Text("Назад к описанию")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 6)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color(uiColor: .secondarySystemGroupedBackground).ignoresSafeArea())
        }
    }
}

// MARK: - Subcomponents

private struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}

private struct RuleBullet: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.secondary)
                .font(.body.weight(.bold))
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

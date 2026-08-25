# MellClicker — Native iOS Clicker Game (SwiftUI + MVVM)

A complete, production-ready native iOS clicker game built with **SwiftUI**, **AVFoundation**, and clean **MVVM Architecture** according to Apple Human Interface Guidelines (HIG).

---

## 📂 Project Architecture

The repository is organized as a standard Xcode project ready to open and run immediately:

```text
.
├── MellClicker.xcodeproj
│   └── project.pbxproj             # Complete Xcode project specification
│
└── MellClicker
    ├── App
    │   ├── MellClickerApp.swift    # @main app entry point & HIG appearance setup
    │   └── ContentView.swift       # Native TabView coordinator (Кликер, Магазин, Настройки)
    │
    ├── ViewModels
    │   └── GameViewModel.swift     # Core reactive state, formulas, timer, and UserDefaults persistence
    │
    ├── Services
    │   ├── AudioManager.swift      # Low-latency concurrent AVFoundation audio engine with player pooling
    │   └── HapticManager.swift     # Native iOS Taptic Engine feedback coordinator
    │
    ├── Views
    │   ├── ClickerView.swift       # Tap interaction, spring bounce animation, and floating particles
    │   ├── ShopView.swift          # Upgrades list («Чекушка» and «Чекунец») with native List & Sections
    │   └── SettingsView.swift      # Audio/haptic toggles, reset confirmation alert, and Telegram link
    │
    └── Resources
        ├── Assets.xcassets
        │   ├── AppIcon.appiconset  # 1024x1024 universal iOS App Icon (mellclickericon.png)
        │   └── MellButton.imageset # Main circular click button asset (MellButton.png)
        ├── Audio
        │   ├── tap.mp3             # Low-latency tap sound effect
        │   └── chekunec.mp3        # Auto-clicker passive audio effect
        └── Info.plist              # Application configuration & permissions
```

---

## 🚀 How to Run in Xcode

1. Double-click **`MellClicker.xcodeproj`** to open the project in Xcode (Xcode 14+ / 15+ / 16+).
2. Select any iPhone Simulator (e.g. **iPhone 15 Pro / iPhone 16**) or a connected physical iPhone.
3. Press **⌘R** (Product > Run) to build and launch the game.

---

## 🎮 Features & Mechanics

- **Кликер (Clicker Tab)**:
  - Dynamic balance counter with smooth `.numericText()` transitions.
  - Large circular button rendering `MellButton.png` with spring physics (`.scaleEffect`).
  - Animated floating `+Multiplier` particles spawning on every tap.
  - Concurrent low-latency `tap.mp3` playback and haptic impact feedback.

- **Магазин (Shop Tab)**:
  - **Чекушка**: Multiplies tap earnings ($x1 \to x2 \to x4 \to x8\dots$). Formula: `cost * 2` (Base: 100).
  - **Чекунец**: Automated assistant generating passive clicks every second with synchronous `chekunec.mp3` playback. Formula: `base * 1.20^count` (Base: 250).

- **Настройки (Settings Tab)**:
  - Sound FX (Mute / Unmute) and Haptic feedback switches.
  - Destructive progress reset with standard system confirmation alert.
  - **Создатель и разработчик**: Interactive HIG `Link` to [Telegram: @VityaV](https://t.me/VityaV).

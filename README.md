# Exam Pulse Pro

Exam Pulse Pro is a precision exam schedule visualizer for students and academics.

## Repository layout

- `web/` — Offline-first web app (HTML/CSS/JS)
- `ios/` — Native iOS SwiftUI implementation

## Product direction

- One-time purchase positioning (no recurring subscription logic)
- Fully local/offline operation
- No networking or cloud dependencies
- Built to convert exam dates into a live countdown dashboard

## Web app (`web/`)

### Run locally

```bash
cd web
python3 -m http.server 4173
```

Then visit `http://localhost:4173`.

### Web features

- Add exam name, date, optional time, and optional notes
- Bulk import exam lines with `Title | YYYY-MM-DD | HH:MM`
- Auto-sorted countdown cards that refresh every second
- Local timezone awareness
- Data persistence using browser `localStorage`
- Clear all and per-exam delete controls

## iOS app (`ios/ExamPulsePro/`)

### iOS architecture

- `ExamPulseProApp.swift`: App entry point and dependency injection
- `Models/Exam.swift`: Codable exam model + countdown formatting logic
- `ViewModels/ExamStore.swift`: Local persistence (`UserDefaults`), sorting, add/delete/clear, and bulk import parser
- `Views/ContentView.swift`: SwiftUI dashboard UI (add form, bulk import, countdown list, destructive clear)

### iOS behavior

- 100% local storage on device via `UserDefaults`
- No API calls, no third-party SDKs, no networking requirement
- Countdown list updates every second
- Supports single add and `Title | YYYY-MM-DD | HH:MM` bulk import
- Swipe-to-delete rows and clear-all confirmation

### Open in Xcode

1. Create a new **iOS App** project in Xcode named `ExamPulsePro` (SwiftUI lifecycle).
2. Copy files from `ios/ExamPulsePro/` into the project, preserving folder names.
3. Build and run on simulator/device (`iOS 17+` recommended).

> Note: this Linux container cannot compile SwiftUI/UIKit targets because Apple iOS SDKs are unavailable here. Build validation for iOS must be done in Xcode on macOS.

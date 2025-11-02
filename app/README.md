# Escalator Mobile App

Flutter mobile application for the Escalator work tracking and escalation system.

## Features

- **Onboarding** - Simple name input with unique username generation
- **Kanban Board** - Visual board showing work items across escalation stages
- **Work Item Management** - Create and track work items
- **Escalation Flow** - Manual escalation through defined stages
- **Standup Updates** - Add daily notes for each work item
- **Push Notifications** - FCM-based reminders (requires Firebase setup)
- **Offline Support** - Local caching with SharedPreferences

## Setup

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Configure API endpoint:
Edit `lib/services/api_service.dart` and update `baseUrl`:
- For Android emulator: `http://10.0.2.2:5230/api`
- For iOS simulator: `http://localhost:5230/api`
- For physical device/production: `http://194.195.117.157:5230/api`

3. Firebase Setup (for push notifications):
   - Create a Firebase project
   - Add iOS and Android apps to your project
   - Download and add configuration files:
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`
     - Android: `google-services.json` → `android/app/`
   - The app will work without Firebase, but notifications will be disabled

4. Run the app:
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

## Project Structure

```
lib/
├── main.dart                   # App entry point
├── models/                     # Data models
│   ├── user.dart
│   └── work_item.dart
├── providers/                  # State management
│   ├── user_provider.dart
│   └── work_items_provider.dart
├── screens/                    # UI screens
│   ├── onboarding_screen.dart
│   ├── dashboard_screen.dart
│   ├── create_work_item_screen.dart
│   └── work_item_detail_screen.dart
├── widgets/                    # Reusable widgets
│   └── kanban_board.dart
└── services/                   # Business logic
    ├── api_service.dart
    └── notification_service.dart
```

## Escalation Stages

1. **Active** - Waiting for response
2. **Day 2 Nudge** - Nudge POC offline + standup update
3. **Day 4 Second Nudge** - Second nudge + standup callout
4. **Week 1 Call** - Setup call with POC
5. **Manager Escalation** - Escalate with full context
6. **Resolved** - Work completed

## State Management

Using Provider for state management:
- `UserProvider` - Manages current user state and authentication
- `WorkItemsProvider` - Manages work items list and CRUD operations

## Local Storage

- User ID persisted with SharedPreferences
- Automatic login on app restart

## Technologies

- **Flutter** - Cross-platform framework
- **Provider** - State management
- **http** - API communication
- **Firebase** - Push notifications (optional)
- **SharedPreferences** - Local storage

## Build for Release

### iOS
```bash
flutter build ios --release
```

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

## License

MIT

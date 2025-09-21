# Technology Stack - Tuqayyem

## Framework & Platform
- **Flutter** - Cross-platform mobile development (Android & iOS)
- **Dart** - Programming language (latest version)
- **Adaptive UI**: Material Design for Android, Cupertino for iOS
- **Firebase** - Backend services (Auth, Firestore)

## Architecture Approach
- **Platform-adaptive components** - Respect native platform conventions
- **Modern design patterns** - Light colors, contemporary UI
- **Performance-focused** - Fast MVP with <200ms rating submission
- **Test-driven development** - Tests before implementation

## Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_auth: ^latest
  cloud_firestore: ^latest
  cupertino_icons: ^latest
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^latest
```

## Development Workflow
- **Trunk-Based Development** - Single main branch, short-lived feature branches
- **Test-First Approach** - Write tests before implementation
- **Human UI Review** - All colors, buttons, and dashboard cards require approval
- **GitHub Actions** - Automated CI/CD pipeline

## Project Structure
```
lib/
├── main.dart              # App entry point
├── pages/                 # Screen/page widgets
│   ├── landing.dart       # Landing page
│   ├── dashboard.dart     # Location dashboard
│   └── auth.dart          # Sign-up/Sign-in
├── services/              # Business logic
│   ├── auth_service.dart  # Firebase Auth
│   └── location_service.dart # Firestore data
├── models/                # Data models
└── widgets/               # Reusable components

tests/
├── widget/                # Widget tests
├── integration/           # Integration tests
└── unit/                  # Unit tests
```

## Common Commands
```bash
# Development
flutter run                    # Run app in debug mode
flutter test                   # Run all tests
flutter analyze               # Static analysis

# Building
flutter build apk             # Android APK
flutter build ios             # iOS build

# Firebase
flutterfire configure         # Setup Firebase
flutter packages get          # Install dependencies

# Testing
flutter test tests/widget/    # Widget tests only
flutter test tests/integration/ # Integration tests
```

## Design System
- **Light modern colors** - Clean, contemporary palette
- **Adaptive components** - Platform-specific UI patterns
- **Card-based layouts** - Location cards on dashboard
- **Consistent spacing** - 8dp grid system
- **Performance optimized** - Efficient rendering and data loading

## Quality Gates
- All features must have automated tests
- UI components require human review before release
- Code must pass flutter analyze
- Performance targets: <200ms for rating submission
- Platform-adaptive behavior verified on both iOS and Android
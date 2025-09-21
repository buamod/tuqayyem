# Project Structure - Tuqayyem

## Flutter Project Organization

Standard Flutter project at root level following the spec requirements and task structure.

## Root Level Structure
```
tuqayyem/                     # Root project directory
├── lib/                      # Main Dart source code
├── android/                  # Android-specific configuration
├── ios/                      # iOS-specific configuration  
├── tests/                    # All test files
├── specs/                    # Feature specifications
├── .kiro/                    # Kiro steering files
├── pubspec.yaml              # Flutter dependencies
└── README.md                 # Project documentation
```

## Source Code Organization (`lib/`)
```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app widget and navigation
├── pages/                    # Screen/page widgets
│   ├── landing.dart          # Landing page (MVP v1)
│   ├── dashboard.dart        # Location dashboard (MVP v1)
│   └── auth.dart             # Sign-up/Sign-in (MVP v2)
├── services/                 # Business logic and external APIs
│   ├── auth_service.dart     # Firebase Authentication
│   └── location_service.dart # Firestore data operations
├── models/                   # Data models and entities
│   ├── location.dart         # Location entity
│   ├── user.dart             # User entity
│   └── rating.dart           # Rating entity
└── widgets/                  # Reusable UI components
    └── location_card.dart    # Dashboard location cards
```

## Test Organization (`tests/`)
```
tests/
├── widget/                   # Widget tests (UI components)
│   ├── landing_test.dart     # Landing page tests
│   └── dashboard_test.dart   # Dashboard tests
├── integration/              # Integration tests (user flows)
│   ├── navigation_test.dart  # App navigation
│   └── auth_data_test.dart   # Auth + data loading
└── unit/                     # Unit tests (business logic)
    └── services/             # Service layer tests
```

## Naming Conventions
- **Files**: snake_case (e.g., `landing_page.dart`, `auth_service.dart`)
- **Classes**: PascalCase (e.g., `LandingPage`, `AuthService`)
- **Variables/Functions**: camelCase (e.g., `userName`, `submitRating()`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `MAX_RATING_VALUE`)

## Development Workflow Structure
- **Trunk-Based Development**: Single main branch
- **Feature branches**: Short-lived, merged quickly
- **Test-first**: Tests written before implementation
- **Human review**: Required for all UI components

## Task-Based File Creation
Following the spec tasks, files are created in this order:
1. **Setup**: Project structure and configuration
2. **Tests First**: All test files before implementation
3. **Core Implementation**: Pages and navigation
4. **Services**: Firebase integration and data layer
5. **Polish**: Documentation and final review

## Platform-Specific Directories
- `android/` - Android build configuration, permissions, icons
- `ios/` - iOS build configuration, Info.plist, icons
- `web/` - Web build assets (if needed)
- `macos/`, `linux/`, `windows/` - Desktop platforms (optional)

## Configuration Files
- `pubspec.yaml` - Dependencies, assets, Flutter configuration
- `analysis_options.yaml` - Dart analyzer and linting rules
- `.gitignore` - Version control exclusions
- `firebase_options.dart` - Firebase configuration (auto-generated)
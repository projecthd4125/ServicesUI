# Flutter Project Architecture

## 📁 Project Structure

```
lib/
├── core/                           # Core functionality
│   ├── constants/                  # App-wide constants
│   │   ├── app_constants.dart      # General constants
│   │   └── test_credentials.dart   # Dev credentials
│   ├── theme/                      # Theme configuration
│   │   └── app_theme.dart          # App theme
│   └── utils/                      # Utility functions
│       ├── date_utils.dart         # Date formatting
│       └── responsive_utils.dart   # Responsive helpers
│
├── features/                       # Feature modules
│   ├── auth/                       # Authentication feature
│   │   ├── data/                   # Data layer
│   │   │   ├── user_model.dart     # User model
│   │   │   └── auth_service.dart   # Auth service
│   │   └── presentation/           # UI layer
│   │       ├── login_screen.dart   # Login screen
│   │       └── widgets/            # Auth widgets
│   │           ├── auth_text_field.dart
│   │           └── test_credentials_card.dart
│   │
│   └── service_request/            # Service requests feature
│       ├── data/                   # Data layer
│       │   ├── service_request_model.dart
│       │   └── service_request_service.dart
│       └── presentation/           # UI layer
│           ├── client_requests_screen.dart
│           ├── admin_requests_screen.dart
│           ├── create_request_screen.dart
│           └── widgets/            # Service request widgets
│               ├── request_card.dart
│               ├── status_badge.dart
│               └── request_form_fields.dart
│
├── shared/                         # Shared components
│   └── widgets/                    # Reusable widgets
│       ├── loading_indicator.dart
│       └── custom_app_bar.dart
│
└── main.dart                       # App entry point
```

## 🏗️ Architecture Principles

### 1. **Feature-First Organization**
- Code organized by features, not by technical layers
- Each feature is self-contained and independent
- Easy to add, remove, or modify features

### 2. **Separation of Concerns**
- **Data Layer**: Models, services, repositories
- **Presentation Layer**: Screens, widgets, state management
- **Core Layer**: Shared utilities, constants, theme

### 3. **Modularity**
- Small, focused files (< 300 lines)
- Single Responsibility Principle
- Reusable widgets extracted

### 4. **Clean Code Practices**
- Descriptive names
- Proper documentation
- Const constructors where possible
- Type safety

## 📦 Feature Structure

Each feature follows this structure:

```
feature_name/
├── data/                  # Data management
│   ├── models/            # Data models
│   ├── services/          # Business logic
│   └── repositories/      # Data sources (when needed)
└── presentation/          # UI components
    ├── screens/           # Full-page screens
    ├── widgets/           # Feature-specific widgets
    └── state/             # State management (when using BLoC/Provider)
```

## 🎯 Best Practices Implemented

### Code Organization
- ✅ Feature-based folder structure
- ✅ Separation of data and presentation
- ✅ Modular, reusable widgets
- ✅ Constants extracted to dedicated files

### Code Quality
- ✅ Descriptive naming conventions
- ✅ Type-safe code
- ✅ Proper use of const constructors
- ✅ Documentation comments
- ✅ Error handling

### Performance
- ✅ Const widgets where possible
- ✅ Efficient state management
- ✅ Lazy loading
- ✅ Proper disposal of resources

### Maintainability
- ✅ DRY (Don't Repeat Yourself)
- ✅ SOLID principles
- ✅ Easy to test
- ✅ Easy to extend

## 🔄 Data Flow

```
User Action
    ↓
Presentation Layer (Screen/Widget)
    ↓
Service Layer (Business Logic)
    ↓
Data Layer (Models/Storage)
    ↓
Service Layer (Process Result)
    ↓
Presentation Layer (Update UI)
```

## 🚀 Future Enhancements

### State Management
When the app grows, consider adding:
- **Bloc Pattern**: For complex state management
- **Provider**: For simpler state sharing
- **Riverpod**: For modern dependency injection

### Backend Integration
Current structure is backend-ready:
- Replace `AuthService` with API calls
- Replace `ServiceRequestService` with repository pattern
- Add DTOs (Data Transfer Objects) for API models

### Testing
Structure supports easy testing:
- Unit tests for services and models
- Widget tests for UI components
- Integration tests for user flows

## 📝 Naming Conventions

### Files
- `snake_case` for file names
- `feature_name_screen.dart` for screens
- `feature_name_widget.dart` for widgets
- `feature_name_model.dart` for models
- `feature_name_service.dart` for services

### Classes
- `PascalCase` for class names
- `_PrivateClass` for private classes
- Descriptive names (e.g., `ServiceRequestService`, not `SRS`)

### Variables
- `camelCase` for variables
- `_privateVariable` for private variables
- `kConstantName` for constant values (optional)

### Functions
- `camelCase` for function names
- Verb-based names (e.g., `handleLogin`, `navigateToHome`)
- `_privateFunction` for private functions

## 🎨 Widget Guidelines

### When to Extract a Widget
Extract when:
- Widget is reused multiple times
- Widget > 50 lines
- Widget has distinct responsibility
- Improves readability

### Widget Types
- **Stateless**: For static UI
- **Stateful**: For interactive UI with local state
- **Const**: When possible for performance

## 📚 Additional Resources

- [Flutter Style Guide](https://flutter.dev/docs/development/style)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Architecture](https://flutter.dev/docs/development/data-and-backend/state-mgmt)

# MyService UI Project

A Flutter UI project for developing a cross-platform app compatible with iOS and Android, supporting both mobile and iPad views.

## Getting Started

1. Ensure you have Flutter installed: https://docs.flutter.dev/get-started/install
2. Run `flutter pub get` to fetch dependencies.
3. Use `flutter run -d chrome` to launch the app in Chrome browser.

## Features
- **Multi-role Authentication System**
  - Admin, Client, and Service Provider roles
  - Local authentication (backend-ready)
  - Secure logout functionality with confirmation dialog
  
- **Client Features**
  - Create service requests with:
    - Expected start and end dates
    - Location/address
    - Service description
  - View all submitted requests
  - **Edit existing requests** - Update dates, location, or description
  - **Delete requests** - With confirmation dialog to prevent accidental deletion
  - Track request status (pending, approved, rejected, completed)
  - Logout option in app bar

- **Admin Features**
  - View all service requests from all clients
  - Dashboard with summary statistics
  - Approve or reject pending requests
  - Refresh and logout options in app bar

- **Service Provider Features**
  - Placeholder for future implementation
  - Logout functionality available

- **Responsive Design**
  - Optimized UI for mobile phones
  - Enhanced layouts for tablets and iPads
  - Material Design components

## Test Credentials

- **Admin**: admin@gmail.com / test123
- **Client**: client@gmail.com / test123
- **Service Provider**: serviceprovider@gmail.com / test123

## Project Structure
- `lib/main.dart`: Main entry point
- `lib/models/`: Data models (User, ServiceRequest)
- `lib/services/`: Business logic (AuthService, ServiceRequestService)
- `lib/screens/`: UI screens (Login, Client Requests, Admin Requests, etc.)
- `pubspec.yaml`: Project configuration and dependencies

## Compatibility
- iOS (iPhone, iPad)
- Android (phones, tablets)
- Web (Chrome browser)

## Local Data Storage
All service requests are now **persistently stored locally** using SharedPreferences. This means:
- Service requests will persist even after logging out
- Data remains available after closing and reopening the app
- Client requests are saved and will display when you login back as a client
- Admin can see all requests from all clients across sessions
- Data is stored in the browser's local storage (for web) or device storage (for mobile)

When you're ready to integrate with your backend API, simply replace the storage logic in `ServiceRequestService` with API calls. The structure is already backend-ready!

---
Ready for backend integration when your API services are available.

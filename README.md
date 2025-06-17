# Parking Lot Frontend

A Flutter mobile application for parking lot management and navigation, helping users find parking spaces, discover nearby stores, and access exclusive discounts.

## Features

- **User Authentication**: Secure registration, login, and password recovery
- **Interactive Map Navigation**: Find and navigate to available parking spots
- **Store Discovery**: Search for nearby stores and businesses
- **Discount Search**: Browse and find exclusive parking and store discounts
- **Account Management**: Manage your profile and preferences

## Getting Started

### Prerequisites

- Flutter SDK (version 3.5.3 or higher)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- An Android/iOS device or emulator for testing

### Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd parkinglot_frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Project Structure

- [`lib/main.dart`](lib/main.dart) - Application entry point
- [`lib/RegisterAndLogin/`](lib/RegisterAndLogin/) - Authentication screens
- [`lib/mainPages/`](lib/mainPages/) - Core application screens
- [`lib/api/`](lib/api/) - API integration layer
- [`lib/utils/`](lib/utils/) - Utility functions and helpers

## Dependencies

Key packages used in this project:
- `dio` - HTTP client for API requests
- `shared_preferences` - Local data storage
- `cupertino_icons` - iOS-style icons

## Flutter Resources

New to Flutter? Here are some helpful resources:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Online documentation](https://docs.flutter.dev/) - Tutorials, samples, and API reference

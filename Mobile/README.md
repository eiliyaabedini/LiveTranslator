# LiveTranslator Mobile App

A Flutter implementation of the LiveTranslator web application for Android and iOS devices. This app provides real-time voice translation between different languages using OpenAI's GPT-4o-mini-realtime-preview API.

## Features

- Real-time voice translation between multiple languages
- Secure API key storage using Flutter Secure Storage
- WebRTC integration for direct communication with OpenAI's Realtime API
- Similar UI and UX to the web version
- Support for both Android and iOS platforms

## Project Structure

```
live_translator_app/
├── lib/
│   ├── main.dart              # Main entry point
│   ├── screens/               # App screens
│   │   ├── home_screen.dart   # Main app screen
│   │   ├── settings_screen.dart # Settings screen
│   │   └── info_screen.dart   # About/Info screen
│   ├── services/              # Business logic
│   │   ├── app_state.dart     # App state management
│   │   ├── api_service.dart   # API communication
│   │   ├── webrtc_service.dart # WebRTC handling
│   │   ├── translation_service.dart # Translation coordination
│   │   └── secure_storage_service.dart # Secure API key storage
│   ├── widgets/               # Reusable UI components
│   │   ├── language_selector.dart # Language dropdown
│   │   └── mic_button.dart    # Microphone button with animations
│   └── utils/                 # Utilities
│       ├── app_theme.dart     # Theme and styling
│       └── constants.dart     # App constants
├── pubspec.yaml               # Dependencies and config
└── assets/                    # App assets
    └── images/                # Images for the app
```

## Required Dependencies

The app uses the following key packages:
- `flutter_webrtc` for WebRTC functionality
- `permission_handler` for microphone permissions
- `flutter_secure_storage` for secure API key storage
- `shared_preferences` for app settings
- `provider` for state management
- `font_awesome_flutter` for icons
- `http` for API communication
- `flutter_sound` for audio processing

## Getting Started

1. Clone the repository
2. Navigate to the `Mobile/live_translator_app` directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app on a connected device or emulator

## Configuration

1. Enter your OpenAI API key in the Settings screen
2. Select your source and target languages
3. Tap the microphone button to start translating

## Requirements

- OpenAI API key with access to the GPT-4o-mini-realtime-preview model
- Flutter 3.0 or higher
- Android 6.0+ or iOS 12.0+

## Server Communication

The app can communicate with the OpenAI API in two ways:
1. Through the proxy server (configured in `constants.dart`) 
2. Directly with the OpenAI API (requires API key)

The proxy server URL is set to `http://10.0.2.2:3000` for Android emulator testing, which maps to `localhost:3000` on the host machine. For iOS simulator, you'll need to use `http://localhost:3000` instead.
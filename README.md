# Watch History Tracker

A cross-platform watch history tracking app built with Flutter and Firebase. Track your offline videos, movies, and series across Android, iOS, Web, Linux, Windows, and macOS.

## Features

- **Multi-Platform Support**: Works on Android, iOS, Web, Linux, Windows, and macOS
- **Video Entry Management**: 
  - Manual entry with full details
  - File scanning to detect video files
  - VLC integration to import watch history
  - Bulk import/export support
- **Comprehensive Tracking**:
  - Watch status (Not Started, In Progress, Completed, Dropped)
  - Progress tracking with percentage
  - Multiple watch sessions per video
  - Ratings (1-10 scale)
  - Notes and reviews
  - Tags and genres
  - File metadata (path, duration, size, format)
- **Modern UI/UX**:
  - Material Design 3
  - Smooth animations and transitions
  - Dark/Light theme support
  - Responsive design
- **Cloud Sync**: Firebase integration for syncing across devices
- **Statistics**: Charts and analytics for your watch history

## Setup Instructions

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Firebase account (for cloud sync)

### Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)

2. Enable Authentication:
   - Go to Authentication > Sign-in method
   - Enable Email/Password provider

3. Create Firestore Database:
   - Go to Firestore Database
   - Create database in production mode
   - Set up security rules (see below)

4. Configure platforms:

   **Android:**
   - Add `google-services.json` to `android/app/`
   - Update `android/build.gradle` with Google Services plugin

   **iOS:**
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Update `ios/Podfile` if needed

   **Web:**
   - Add Firebase config to `web/index.html`
   - See Firebase documentation for web setup

5. Firestore Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /videos/{videoId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd watch_history_reminder
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Add Firebase configuration files for your platforms
   - Update Firebase initialization in `lib/main.dart` if needed

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/
│   ├── theme/               # Theme configuration
│   ├── constants/           # App constants
│   └── utils/               # Utility functions
├── models/
│   └── video_entry.dart     # Video entry model
├── services/
│   ├── firebase_service.dart      # Firebase operations
│   ├── local_storage_service.dart # Local storage
│   ├── file_scanner_service.dart  # File scanning
│   └── vlc_integration_service.dart # VLC integration
├── providers/
│   └── video_provider.dart  # State management
├── screens/
│   ├── home/                # Home screen
│   ├── library/             # Library screen
│   ├── detail/               # Detail screen
│   ├── add/                  # Add/Edit screen
│   ├── statistics/          # Statistics screen
│   └── settings/            # Settings screen
├── widgets/
│   ├── common/              # Common widgets
│   └── video/               # Video-specific widgets
└── routes/
    └── app_router.dart       # Navigation routes
```

## Usage

1. **Sign In**: Create an account or sign in to enable cloud sync
2. **Add Videos**: 
   - Tap the + button to manually add a video
   - Use file picker to select video files
   - Import from VLC in Settings
3. **Track Progress**: Update watch progress from the detail screen
4. **View Statistics**: Check your watch statistics and charts
5. **Sync**: Your data automatically syncs across devices when signed in

## Development

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Desktop
flutter build linux --release
flutter build windows --release
flutter build macos --release
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.
# Watch_History_Reminder

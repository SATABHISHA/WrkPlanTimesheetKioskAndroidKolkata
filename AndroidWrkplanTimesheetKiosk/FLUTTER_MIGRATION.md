# WrkPlan Timesheet Kiosk - Flutter Migration

## Overview
This is a complete Flutter migration of the WrkPlan Timesheet Kiosk Android application. The app has been successfully converted from a native Android application (using Java/Kotlin) to a cross-platform Flutter application that runs on both Android and iOS.

## Migration Details

### Original Android Stack
- **Language**: Java/Kotlin
- **Build System**: Gradle
- **Networking**: Volley
- **State Management**: Custom Singleton pattern
- **Local Storage**: SharedPreferences
- **Features**: Facial Recognition, Admin Portal, Attendance Tracking

### New Flutter Stack
- **Language**: Dart
- **Build System**: Flutter/Gradle (Android), Flutter/Xcode (iOS)
- **Networking**: HTTP package (replaces Volley)
- **State Management**: Provider pattern
- **Local Storage**: shared_preferences package
- **Features**: All features preserved + cross-platform compatibility

## Project Structure

```
lib/
├── main.dart                          # App entry point and routing
├── constants/
│   └── app_constants.dart             # Configuration constants
├── models/
│   ├── user_model.dart                # User/Authentication model
│   ├── employee_model.dart            # Employee data model
│   └── attendance_model.dart          # Attendance records model
├── services/
│   ├── api_service.dart               # HTTP API client
│   └── auth_provider.dart             # Authentication state management
├── utils/
│   └── shared_preference_helper.dart   # Local storage management
├── screens/
│   ├── login_screen.dart              # Employee login
│   ├── admin_login_screen.dart        # Admin login
│   ├── home_screen.dart               # Main dashboard
│   ├── recognition_screen.dart        # Facial recognition/attendance
│   ├── attendance_log_screen.dart     # Attendance history
│   ├── admin_settings_screen.dart     # Admin panel
│   ├── kiosk_settings_screen.dart     # Kiosk configuration
│   ├── employee_settings_screen.dart  # Employee management
│   ├── employee_image_settings_screen.dart # Employee image upload
│   ├── attendance_reports_screen.dart # Attendance reports
│   └── system_config_screen.dart      # System configuration
└── widgets/
    └── (Custom reusable widgets)
```

## Key Changes from Android

### 1. Networking (Volley → HTTP Package)
**Before (Android)**:
```java
StringRequest stringRequest = new StringRequest(Request.Method.POST, url,
    new Response.Listener<String>() {...},
    new Response.ErrorListener() {...});
```

**After (Flutter)**:
```dart
final response = await http.post(
  Uri.parse(url),
  headers: headers,
  body: jsonEncode(body),
);
```

### 2. State Management (Singleton → Provider)
**Before (Android)**:
```java
UserSingletonModel userModel = UserSingletonModel.getInstance();
userModel.setUserID(userId);
```

**After (Flutter)**:
```dart
context.read<AuthProvider>().user
// or with Consumer widget for reactive updates
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    return Text(authProvider.user?.empName ?? '');
  },
)
```

### 3. Local Storage (SharedPreferences → shared_preferences Package)
**Before (Android)**:
```java
SharedPreferences prefs = context.getSharedPreferences("myPrefs", Context.MODE_PRIVATE);
prefs.putString("key", "value");
String value = prefs.getString("key", "default");
```

**After (Flutter)**:
```dart
await SharedPreferenceHelper.setUserData(userData);
Map<String, dynamic>? userData = SharedPreferenceHelper.getUserData();
```

### 4. Camera Integration
Both Android and iOS camera permissions are configured in:
- **Android**: `android/app/src/main/AndroidManifest.xml`
- **iOS**: `ios/Runner/Info.plist`

## Dependencies

Main packages used:
- `http: ^1.1.0` - HTTP client for API calls
- `provider: ^6.0.0` - State management
- `shared_preferences: ^2.2.0` - Local storage
- `camera: ^0.10.5` - Camera access
- `image_picker: ^1.0.0` - Image selection
- `google_ml_kit: ^0.14.0` - ML Kit for facial recognition
- `flutter_secure_storage: ^9.0.0` - Secure storage for sensitive data
- `intl: ^0.19.0` - Internationalization support
- `json_annotation: ^4.8.0` - JSON serialization

## Setup & Installation

### Prerequisites
- Flutter SDK (latest version recommended)
- Dart SDK (included with Flutter)
- For Android: Android SDK, emulator or physical device
- For iOS: Xcode, iOS deployment target ≥ 12.0

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd WrkPlanTimesheetKiosk
   ```

2. **Get the branch**
   ```bash
   git checkout satabhisha-flutter
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Generate model files**
   ```bash
   flutter pub run build_runner build
   ```

5. **Run the app**
   ```bash
   # Android
   flutter run -d <device-id>
   
   # iOS
   flutter run -d <device-id>
   ```

## Configuration

### API Configuration
Update the API base URL in [lib/constants/app_constants.dart](lib/constants/app_constants.dart):

```dart
static const String baseUrl = 'http://14.99.211.60:9012/';
```

### Android Configuration
- Minimum SDK: 26 (configurable in [android/app/build.gradle.kts](android/app/build.gradle.kts))
- Target SDK: 34
- Permissions configured in [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)

###  iOS Configuration
- Minimum deployment target: 12.0
- Camera permissions in [ios/Runner/Info.plist](ios/Runner/Info.plist)
- Location permissions added

## Features

### Core Features (Migrated)
- ✅ Employee Login with Corp ID
- ✅ Facial Recognition for Check-in/Check-out
- ✅ Attendance Record Management
- ✅ Task Selection
- ✅ Admin Portal with multiple configuration options
- ✅ Kiosk Unit Settings
- ✅ Employee Management
- ✅ Employee Image Uploads
- ✅ Attendance Reports

### Additional Features (Flutter)
- 🔄 Cross-platform support (Android & iOS)
- 🎨 Modern Material Design UI
- 📦 Better state management with Provider
- 🔒 Improved security with secure storage
- 🌐 Better error handling and user feedback

## Building for Release

### Android
```bash
flutter build apk --release
# or for App Bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
# Then open in Xcode for signing and distribution
```

## API Endpoints

The app communicates with the backend API at `http://14.99.211.60:9012/`

### Key Endpoints
- `POST /login` - User authentication
- `POST /recognition` - Facial recognition and attendance
- `GET /employee` - Fetch employee list
- `GET /attendance` - Fetch attendance records
- `POST /admin` - Admin operations

## Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
Tests are located in the `test/` directory.

### Build Tests
```bash
flutter analyze  # Check for analysis issues
flutter build apk      # Test Android build
flutter build ios      # Test iOS build
```

## Troubleshooting

### Common Issues

1. **Camera not working on Android**
   - Ensure permissions are granted: Settings → App Permissions → Camera
   - Check if device has camera hardware

2. **Build fails with dependency errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Delete `pubspec.lock` and regenerate

3. **JSON serialization errors**
   - Ensure `build_runner` is up to date: `flutter pub upgrade build_runner`
   - Regenerate models: `flutter pub run build_runner build --delete-conflicting-outputs`

## Performance Optimization

- Images are optimized before upload
- API responses are cached locally
- Lazy loading implemented for attendance lists
- Memory management for camera streams

## Security Considerations

- Sensitive data stored using `flutter_secure_storage`
- API calls use HTTPS (configure in production)
- Session management with automatic logout
- Input validation on all user inputs

## Migration Checklist

- [x] Created Flutter project structure
- [x] Migrated models (User, Employee, Attendance)
- [x] Implemented API service layer
- [x] Created authentication system
- [x] Implemented all screen UIs
- [x] Setup routing and navigation
- [x] Configured Android permissions
- [x] Configured iOS permissions
- [x] Setup state management with Provider
- [x] Setup dependency injection
- [ ] Complete API integration testing
- [ ] Implement facial recognition ML model
- [ ] User acceptance testing (UAT)
- [ ] Performance testing
- [ ] Release candidate build

## Future Enhancements

1. **Payment Integration**: Add payment processing for kiosk
2. **Offline Support**: Implement offline attendance recording with sync
3. **Advanced Analytics**: Add detailed attendance analytics dashboard
4. **Biometric Auth**: Implement fingerprint authentication alongside facial recognition
5. **Multi-language Support**: Add localization for multiple languages
6. **Dark Mode**: Implement dark theme support
7. **Accessibility**: Improve accessibility features for users with disabilities

## Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Camera Plugin](https://pub.dev/packages/camera)
- [HTTP Package](https://pub.dev/packages/http)

## License
[Specify your license here]

## Support
For support and bug reports, please contact the development team.

---

**Last Updated**: March 25, 2026
**Version**: 1.0.0 (Flutter)
**Migration Status**: In Progress

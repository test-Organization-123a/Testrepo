# ClimbEasy Flutter Frontend

A full-featured cross-platform frontend for the ClimbEasy climbing gear rental and route discovery platform, built with:

- Flutter SDK ^3.9.2
- Dart
- Provider (State Management)
- Clean Architecturedwddwdw
- Hive (Local Storage)
- Material Design

This application provides both user and admin interfaces for browsing products, managing inventory, discovering climbing locations, and processing orders.  
It's designed for scalability, maintainability, and seamless integration with the Node.js backend API.

---

## Features

- Cross-platform UI for:
    - Product browsing & shopping cart
    - Location & route discovery
    - Order management
    - Admin inventory management
    - User authentication & authorization
- Responsive design supporting mobile, tablet, desktop, and 4K displays
- Real-time data synchronization with REST API
- Offline cart persistence using Hive database
- Native device integration (camera, sharing, file system)
- Role-based access control with JWT authentication
- Clean architecture with Provider state management

---

## Tech Stack

| Component | Technology |
|------------|-------------|
| Framework | Flutter SDK ^3.9.2 |
| Language | Dart |
| State Management | Provider ^6.1.2 |
| Architecture | Clean Architecture |
| Local Database | Hive ^2.2.3 |
| HTTP Client | HTTP ^1.2.2 |
| Authentication | JWT |
| UI Design | Material Design |
| Responsive Design | ResponsiveFramework ^1.1.1 |
| Testing | Mockito ^5.4.4 |

---

## Local Development

### Requirements

- Flutter SDK ^3.9.2
- Android Studio / VS Code with Flutter extensions
- (Optional) Physical device or emulator for mobile testing
- Backend API running (see Backend/Main directory)

---

### Start Development Environment

From the project root, run:

```bash
flutter pub get
flutter packages pub run build_runner build
flutter run
```

### Credentials

- **Admin**
  - Email: `admin@example.com`
  - Password: `adminpass`

- **User**
  - Email: `bob@example.com`
  - Password: `password123`

## Environment Configuration

The app automatically configures API endpoints based on build mode:

```dart
// Development (debug mode)
API_URL = http://localhost:3000

// Production (release mode)  
API_URL = /api

// Custom endpoint
flutter run --dart-define=API_URL=your_custom_endpoint
```

## The frontend will be available on:

- **Mobile/Tablet**: Native app on device/emulator
- **Web**: http://localhost:port (assigned by Flutter)
- **Desktop**: Native desktop application

## Platform-Specific Builds

```bash
# Mobile platforms
flutter run                    # Default platform
flutter run -d android        # Android
flutter run -d ios           # iOS (macOS only)

# Desktop platforms  
flutter run -d windows       # Windows
flutter run -d macos         # macOS
flutter run -d linux         # Linux

# Web platform
flutter run -d chrome        # Chrome browser
flutter run -d web-server    # Web server
```

## License

### MIT License

Copyright (c) 2025 ClimbEasy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


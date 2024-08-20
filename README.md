
# Flutter School Management Application

## Overview

The Flutter School Management Application is a comprehensive solution designed to streamline and manage various aspects of school operations. From event scheduling and teacher management to dynamic Firebase integration and theme support, this application is built with modern educational institutions in mind. The app leverages Flutter's powerful UI capabilities along with Firebase's real-time database to deliver a seamless and efficient user experience.

## Features

- **Event Calendar**: A dynamic calendar that displays school events retrieved from Firebase Firestore. Users can interact with the calendar to view detailed information about each event.
- **Teacher Schedule Management**: Manage and display teacher schedules dynamically. The app retrieves schedule data from Firebase, allowing for real-time updates.
- **Theming Support**: Users can switch between light and dark modes, with the app automatically adapting its UI to the selected theme.
- **Firebase Integration**: The application is fully integrated with Firebase, using Firestore for data storage and real-time data synchronization.
- **Customizable UI**: The app's UI is built with flexibility in mind, allowing for easy customization and scaling.

## Prerequisites

Before you begin, ensure you have the following installed and set up:

1. **Flutter SDK**: Install Flutter by following the [official installation guide](https://flutter.dev/docs/get-started/install).
2. **Dart**: Dart is included with Flutter; no separate installation is required.
3. **Firebase Account**: Create a Firebase account at [firebase.google.com](https://firebase.google.com/) and set up a Firestore database.
4. **IDE**: Use Visual Studio Code, Android Studio, or any preferred IDE that supports Flutter development.
5. **Device/Emulator**: Set up a physical device or an Android/iOS emulator for testing the application.

## Installation and Setup

### 1. Cloning the Repository

To get started, clone the repository from GitHub:

```bash
git clone https://github.com/your-repo/school-management-app.git
cd school-management-app
```

### 2. Opening the Project

- **Visual Studio Code**: Open the project by selecting `File > Open Folder` and navigating to the project directory.
- **Android Studio**: Open the project by selecting `Open an existing Android Studio project` and choosing the project directory.

### 3. Installing Dependencies

Install all the necessary dependencies by running:

```bash
flutter pub get
```

### 4. Firebase Setup

#### 4.1 Creating a Firebase Project

1. Navigate to the [Firebase Console](https://console.firebase.google.com/).
2. Click on "Add Project" and follow the setup wizard to create a new Firebase project.
3. After the project is created, click on the Android icon to add an Android app to your Firebase project.

#### 4.2 Registering Your App

1. Enter your Android package name. You can find this in your `android/app/src/main/AndroidManifest.xml` file.
2. Download the `google-services.json` file provided by Firebase.
3. Place the `google-services.json` file in the `android/app` directory.

#### 4.3 Configuring the Android Project

Modify your Android project files as follows:

- **android/build.gradle**:
  ```gradle
  dependencies {
    classpath 'com.google.gms:google-services:4.3.10' // Add this line
  }
  ```
- **android/app/build.gradle**:
  ```gradle
  apply plugin: 'com.google.gms.google-services' // Add this line at the bottom

  defaultConfig {
    minSdkVersion 19 // Ensure this is set to at least 19
  }
  ```

#### 4.4 Adding Firebase Dependencies

Open the `pubspec.yaml` file and add the following dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: latest_version
  cloud_firestore: latest_version
  provider: latest_version
  table_calendar: latest_version
  intl: latest_version
```

After adding the dependencies, run:

```bash
flutter pub get
```

#### 4.5 Initializing Firebase

In `main.dart`, ensure Firebase is initialized before the app runs:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

### 5. Running the Application

To run the application on a connected device or emulator:

```bash
flutter run
```

Ensure that your Firebase configuration is correct and that your device is connected to the internet.

## Project Structure

### Key Files and Their Roles

- **main.dart**: The entry point of the application. This file initializes Firebase, sets up routes, and manages the global theme.
- **home_screen.dart**: Serves as the main navigation screen, allowing users to access different features like the event calendar and settings.
- **firebase_options.dart**: Contains Firebase configuration details. This file is auto-generated and critical for connecting your app to Firebase.
- **theme_notifier.dart**: Manages the application's theme settings (light or dark mode) using the `ChangeNotifier` pattern.
- **ders_ogretmen_model.dart**: Defines the data models for teachers and lessons, facilitating dynamic loading and display of schedules.
- **etkinlik_takvimi_screen.dart**: Displays the event calendar, integrating with Firebase Firestore to fetch and display events dynamically.
- **settings_screen.dart**: Allows users to customize app settings, including switching between light and dark modes.
- **ders_doldurma_screen.dart**: Manages the input and management of lesson data.
- **ders_programi_screen.dart**: Handles the display of class schedules, supporting dynamic updates from Firebase.

### Firebase Firestore Structure

Ensure your Firebase Firestore is configured with the following structure:

- **Events**: 
  - Path: `/okul/okul/etkinlikler/etkinlikler/etkinlikID<number>/`
  - Each document within these collections represents a school event.
  - Fields: `etkinlik_adi`, `etkinlik_duzenleyen`, `etkinlik_saati`, `etkinlik_yeri`, `tarih`.
  
- **Teacher Schedules**:
  - Path: `/okul/okul/dersler/dersler/dersID<number>/`
  - Each document represents a lesson scheduled for a teacher.
  - Fields: `dersAdi`, `ogretmen`, `gun`, `saat`, `sinif`.

- **Teachers**:
  - Path: `/okul/okul/ogretmenler/ogretmenler/ogretmenID<number>/`
  - Each document contains information about a teacher.
  - Fields: `adSoyad`, `brans`.

## Advanced Topics

### Firebase Security Rules

To ensure that your data is secure, configure Firebase Security Rules for your Firestore database. Here's a basic example:

```firestore
service cloud.firestore {
  match /databases/{database}/documents {
    match /okul/okul/etkinlikler/etkinlikler/{document=**} {
      allow read, write: if request.auth != null;
    }
    match /okul/okul/dersler/dersler/{document=**} {
      allow read, write: if request.auth != null;
    }
    match /okul/okul/ogretmenler/ogretmenler/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Error Handling

Implement robust error handling throughout your app to ensure it handles failures gracefully. Consider using `try-catch` blocks around Firebase operations and provide user-friendly error messages.

### Performance Optimization

Optimize the performance of your Flutter app by:

- **Using Efficient Data Queries**: Limit the amount of data fetched from Firestore with appropriate queries.
- **Lazy Loading**: Load data on demand, especially for screens that contain large amounts of data, to improve performance.
- **Efficient State Management**: Use providers like `ChangeNotifier` for efficient state management across your app, minimizing unnecessary rebuilds and enhancing user experience.

## Contributing

If you're new to Flutter or open-source contributions, here’s a simple way to contribute:

1. Fork the repository on GitHub.
2. Clone your forked repository locally.
3. Make your changes, such as fixing bugs or adding new features.
4. Commit your changes with a clear message describing what you've done.
5. Push your changes to your forked repository.
6. Submit a pull request to the original repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any questions or feedback, feel free to reach out to [your-email@example.com].


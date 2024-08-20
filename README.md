
# Flutter School Management Application

## Overview

This project is a comprehensive Flutter-based application designed for managing various aspects of a school's operations, including event scheduling, teacher schedules, and dynamic data handling through Firebase integration. The app features a user-friendly interface that adapts to different themes (light and dark modes) and ensures a smooth experience for all users.

## Features

- **Event Calendar**: View and manage school events. Events are dynamically loaded from Firebase and displayed on a calendar, with markers indicating days that have events.
- **Teacher Schedule Management**: View and manage teacher schedules. Data is fetched from Firebase and displayed in a structured manner.
- **Theme Support**: Switch between light and dark modes, with the app’s appearance adjusting accordingly.
- **Firebase Integration**: The app integrates with Firebase Firestore for data storage and retrieval, ensuring real-time updates.

## Beginner-Friendly Guide

### Prerequisites

Before you start, ensure you have the following:

1. **Flutter SDK**: Install Flutter by following the official [installation guide](https://flutter.dev/docs/get-started/install).
2. **Dart**: Dart is included with Flutter, so no separate installation is required.
3. **Firebase Account**: Create a Firebase account at [firebase.google.com](https://firebase.google.com/) and set up a Firestore database.
4. **Code Editor**: We recommend using [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio) for Flutter development.
5. **Device/Emulator**: You'll need a physical device or an emulator to run the app. Set up an emulator in Android Studio or use your phone.

### Setting Up the Project

1. **Clone the Repository**:
    Open your terminal or command prompt and run:
    ```bash
    git clone https://github.com/your-repo/school-management-app.git
    cd school-management-app
    ```

2. **Open the Project in Your Code Editor**:
    - If you're using Visual Studio Code, open the project by selecting `File > Open Folder` and choosing the project folder.
    - If you're using Android Studio, open the project by selecting `Open an existing Android Studio project` and navigating to the project folder.

3. **Install Dependencies**:
    Run the following command in the terminal to install all necessary dependencies:
    ```bash
    flutter pub get
    ```

4. **Configure Firebase**:
   - Open `firebase_options.dart` in the project.
   - Replace its contents with your Firebase configuration. This configuration can be generated using the Firebase CLI or by setting up Firebase in your Flutter app through the Firebase console.
   - For more details on setting up Firebase, refer to the official [FlutterFire documentation](https://firebase.flutter.dev/).

5. **Run the Application**:
    - Ensure your device or emulator is connected and running.
    - Run the app using:
    ```bash
    flutter run
    ```
    - The app should now compile and start on your selected device or emulator.

### Understanding the Project Structure

Here’s a breakdown of the key files and their roles:

- **main.dart**: The entry point of the application. Initializes Firebase and sets up the main routes and theme management.
- **home_screen.dart**: The main screen, acting as the navigation hub to other parts of the app like the calendar and settings.
- **firebase_options.dart**: Holds Firebase configuration details, including API keys and project IDs. This file is critical for connecting your app to Firebase.
- **theme_notifier.dart**: Manages the app’s theme using a `ChangeNotifier`, allowing for dynamic switching between light and dark modes.
- **ders_ogretmen_model.dart**: Contains data models related to teachers and lessons. This helps in dynamically loading and displaying schedules.
- **etkinlik_takvimi_screen.dart**: Displays the event calendar. Events are fetched from Firebase and shown on a `TableCalendar` widget, with interactive event markers.
- **settings_screen.dart**: Allows users to change app settings, such as theme preferences.
- **ders_doldurma_screen.dart**: Manages input and management of lesson data.
- **ders_programi_screen.dart**: Displays class schedules, supporting dynamic updates from Firebase.

### Detailed Usage Guide

#### Event Calendar
- **Purpose**: The calendar screen (`EtkinlikTakvimiScreen`) displays school events retrieved from Firebase.
- **Usage**:
  - Events are marked on the calendar. Selecting a day shows the events scheduled for that day.
  - Events are loaded dynamically, so ensure your Firebase structure matches the expected format.

#### Teacher Schedules
- **Purpose**: Manage and view teacher schedules.
- **Usage**:
  - Teacher schedules are loaded from Firebase, allowing for real-time updates.
  - The UI is designed to be user-friendly, making it easy to navigate between different teacher schedules.

#### Theme Management
- **Purpose**: Toggle between light and dark modes for a personalized user experience.
- **Usage**:
  - Navigate to the settings screen to switch themes.
  - The app will remember your theme preference and apply it automatically on the next launch.

### Firebase Configuration Details

Ensure your Firebase Firestore is set up with the following structure:

- **Events**: The events should be stored under `/okul/okul/etkinlikler/etkinlikler/etkinlikID<number>/`. Each document within these collections represents an event.
- **Teacher Schedules**: Teacher schedules should be stored under `/okul/okul/dersler/dersler/dersID<number>/`.
- **Teachers**: Teacher information should be stored under `/okul/okul/ogretmenler/ogretmenler/ogretmenID<number>/`.

### Troubleshooting

1. **App Won't Compile**:
   - Ensure all dependencies are installed by running `flutter pub get`.
   - Check that your Firebase configuration is correctly set up in `firebase_options.dart`.

2. **Events Not Displaying on Calendar**:
   - Verify that your Firebase Firestore has events stored under the correct path.
   - Ensure your device has internet connectivity, as the app fetches data from Firebase in real-time.

3. **Theme Not Changing**:
   - Check that the theme is being correctly toggled in the settings screen.
   - Ensure that the `theme_notifier.dart` is properly integrated with your `main.dart`.

### Contributing

If you're new to Flutter or open-source contributions, here’s a simple way to contribute:

1. Fork the repository on GitHub.
2. Clone your forked repository locally.
3. Make your changes, such as fixing bugs or adding new features.
4. Commit your changes with a clear message describing what you've done.
5. Push your changes to your forked repository.
6. Submit a pull request to the original repository.

### License

This project is licensed under the MIT License - see the LICENSE file for details.

### Contact

For any questions or feedback, feel free to reach out to [your-email@example.com].


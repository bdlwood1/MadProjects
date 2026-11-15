# Firebase Cloud Quest

## Project Overview

Firebase Cloud Quest is a mobile application developed using Flutter and Dart for my Mobile Application Development course at Georgia State University. The project focuses on using Firebase services to manage user authentication and retrieve information from a cloud database.

The application includes a light-blue interface with darker blue icons and organized sections for viewing challenges, rewards, and the Quest Coach.

## Features

- User registration with email and password
- User login and logout using Firebase Authentication
- Automatic navigation based on authentication status
- Cloud Firestore integration for retrieving challenge information
- Real-time display of challenge titles, descriptions, and points
- Challenge Reward section with a Complete Challenge button and feedback message
- Quest Coach information section
- Light-blue user interface with darker blue icons

## Technologies Used

- Flutter
- Dart
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Visual Studio Code
- Android Emulator (Pixel 8)

## Firebase Implementation

### Firebase Authentication

Firebase Authentication is used to register users, sign them in, and sign them out. The application checks the user's authentication status and displays either the login screen or the main application screen.

### Cloud Firestore

Cloud Firestore stores the challenge information displayed in the application.

The app retrieves data from the following document:

`challenges/today`

The document contains three fields:

- `title` — Challenge name
- `description` — Challenge instructions
- `points` — Point value

The application uses a Firestore stream to retrieve and display the challenge information.

### Firestore Security

Firestore security rules control access to challenge data. Authenticated users can read challenge information, while modifications to the challenge documents are restricted.

## Application Interface

The application uses a light-blue color scheme with darker blue icons and headings.

The main screen includes three sections:

1. **Today's Challenge:** Displays the challenge information retrieved from Firestore.
2. **Challenge Reward:** Provides a Complete Challenge button and displays feedback when selected.
3. **Quest Coach:** Displays information about the coaching feature.

## Running the Application

1. Install Flutter and configure an Android emulator.
2. Open the project folder in Visual Studio Code.
3. Run `flutter pub get` to install dependencies.
4. Make sure the Firebase configuration is set up for the Android application.
5. Run `flutter analyze` to check for code issues.
6. Run `flutter run` to launch the application.
7. Register or sign in with an email and password to access the main screen.

## Testing

The application was tested using a Pixel 8 Android emulator.

Testing included:

- Registering and signing in using Firebase Authentication
- Retrieving challenge information from Cloud Firestore
- Displaying the challenge title, description, and point value
- Checking the Challenge Reward button's feedback message
- Verifying the updated light-blue interface

The Flutter analyzer also reported no issues.

## Author

Bryce Leidgertwood  
Georgia State University  
Computer Science — Mobile Application Development
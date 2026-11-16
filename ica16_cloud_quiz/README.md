# ICA16 – Cloud Quiz (Class A)

## Project Description

Cloud Quiz is a Flutter Android application built for In-Class Activity 16. It uses Firebase Authentication for login, retrieves 10 general knowledge questions from the Open Trivia Database API, and saves quiz results to Cloud Firestore.

## Setup Instructions

1. Clone or download the repository and open the `ica16_cloud_quiz` folder in VS Code.
2. Run `flutter pub get` to install dependencies.
3. Start an Android emulator, preferably Pixel 8.
4. Run `flutter run` to launch the app.
5. Sign in using the test account below.

## Test Account

**Email:** testuser123@gmail.com  
**Password:** Devon2015

This account was created for testing the application.

## Firebase Configuration

Firebase project: `ica16-cloud-quiz-bryce`

The app uses Firebase Authentication and Cloud Firestore. FlutterFire configuration is stored in `lib/firebase_options.dart`. Quiz attempts are saved under `users/{uid}/attempts/{attemptId}`.

## Features and Testing

Users can sign in, complete a 10-question general knowledge quiz, view their score and answer review, save their score to Firestore, and verify the saved attempt. The application was tested on a Pixel 8 Android emulator. One completed quiz produced a score of 5/10, which was successfully saved and verified in Firebase Console.

## Firestore Security

Firestore rules restrict users to their own records and validate the structure of submitted quiz attempts. Submitted attempts cannot be updated or deleted. Scores are calculated on the client, so the current implementation does not provide server-authoritative scoring.

## Build Release APK

Run `flutter build apk --release`.

The generated APK is located at `build/app/outputs/flutter-apk/app-release.apk`.

Submission filename: `ICA16_A_BryceLeidgertwood.apk`

## Limitations

Additional testing is needed for offline recovery, lost acknowledgments, duplicate submissions, and cross-user security. Future improvements could include trusted backend scoring and stronger retry handling.
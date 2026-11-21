# Campus Connect - Homework 02

Author: Bryce Leidgertwood
Course: Mobile Application Development
Assignment: Message Board Vault Hunt

## Overview
Campus Connect is a Flutter message board application
that uses Firebase Authentication and Cloud Firestore.

## Features
- User registration and login
- Input validation
- Create, read, update, and delete messages
- Real-time message board updates
- Message ownership restrictions
- Persistent authentication sessions

## Technologies
- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore

## Setup Instructions
1. Install Flutter and Android Studio.
2. Clone the repository.
3. Navigate to the HW02 folder.
4. Configure Firebase using FlutterFire CLI.
5. Enable Email/Password authentication.
6. Create a Cloud Firestore database.
7. Apply the included firestore.rules.
8. Run flutter pub get.
9. Run flutter run.

## Authentication Flow
Firebase Authentication manages registration,
login, logout, and persistent user sessions.

## Data Storage
Cloud Firestore stores messages and ownership
information. Firebase manages authentication
persistence on the device.

## Security
Firestore security rules restrict message editing
and deletion to the original message owner.

## Release APK
Build the APK using:
flutter build apk --release

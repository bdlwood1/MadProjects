# INC15 — API-to-Cloud Trivia Showdown

**Course:** CSC 4360 — Mobile Application Development  
**Framework:** Flutter / Dart  
**Testing Device:** Pixel 8 Android Emulator

## Project Description

This project is a Flutter trivia application that retrieves live questions from the Open Trivia Database API. The app displays five easy multiple-choice questions, allows users to select answers, tracks their score, and simulates submitting the final score to a cloud service.

## Features

- Fetches five questions from the Open Trivia Database API.
- Uses the HTTP package to retrieve and decode JSON data.
- Displays a loading indicator while fetching questions.
- Displays an error message when an API request fails.
- Shuffles the multiple-choice answers.
- Highlights correct answers in green and incorrect selected answers in red.
- Prevents users from scoring more than once per question.
- Displays the final score out of five.
- Allows users to restart the trivia game.
- Simulates score synchronization with a confirmation message.

## API Endpoint

https://opentdb.com/api.php?amount=5&category=9&difficulty=easy&type=multiple

The application checks the HTTP response status and API response code before displaying the returned questions.

## How to Run

1. Install Flutter and set up an Android emulator.
2. Open the `api_trivia_inc15` project in VS Code.
3. Open the terminal and run:

   ```bash
   flutter pub get
   flutter run
   ```

4. Select the Android emulator if prompted.
5. Answer the five questions and view your final score.

An internet connection is required to retrieve new trivia questions.

## Testing

The application was tested using a Pixel 8 Android emulator.

The following features were verified:

- Live trivia questions loaded successfully.
- Correct and incorrect answers displayed green/red feedback.
- Five-question rounds completed successfully.
- Correct answers increased the score.
- The Play Again button restarted the trivia round.
- The score-sync simulation displayed a confirmation.

## Score Synchronization

The application includes a **Simulate Score Sync** button. This feature uses a short asynchronous delay to represent sending the score to a cloud service.

**No actual backend request is sent, and scores are not stored remotely.**

## Limitations and Future Improvements

The application requires an internet connection to fetch new questions. It does not currently save questions or scores locally.

A future improvement would be to add a retry button for failed API requests and support a real cloud leaderboard.
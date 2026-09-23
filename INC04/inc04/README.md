# Activity 04 - Flutter Widget Wars

## Team Name
BN

## Team Members
- Bryce Leidgertwood - 002681668
- Nour Khoulani - 002811396

## Google Doc
[Shared Activity 04 Google Doc](https://docs.google.com/document/d/1GZexCSS8rJRD3hbruC3DIMczQdYtWFWSCqOD7chumYw/edit?usp=sharing)

## How to Run

1. Open the Flutter project in VS Code.
2. Open a terminal and navigate to the `inc04` project folder.
3. Run `flutter pub get`.
4. Run `flutter run`.
5. Select Chrome or another available device.
6. The DJ Soundboard will open and can be tested using the buttons, BPM slider, and theme switch.

## Build Challenge

Our team selected the DJ Soundboard theme for the Build Challenge. The application is designed as a live DJ control panel.

The soundboard includes four interactive controls: Synth Drop, Bass Kick, Loop, and Stop. The application also keeps track of the current BPM, number of drops, number of loops, and the currently active track.

The BPM can be changed in real time using a slider. The interface also includes a light/dark theme switch. Pressing the sound buttons updates the application state and gives visual feedback to the user.

After four Synth Drops are triggered, the application displays the "CROWD HYPE!" condition.

The application includes multiple StatelessWidgets and StatefulWidgets. State is used for values that need to change while the application is running, including BPM, drops, loops, playing status, active track, and button interactions.

## State Defense

We used StatefulWidget when information needed to change while the user interacted with the application. Values such as BPM, drop count, loop count, playing status, and active track need state because changes to these values must rebuild the interface.

StatelessWidget was used for parts of the interface that only display information passed to them and do not need to manage their own changing state.

For the tactile controls, GestureDetector is used to provide visual feedback when a button is pressed and released. The visual pressed state occurs when the user presses down, while the actual action is triggered when the press is released.

This structure keeps changing application state in the appropriate widgets while allowing display widgets to remain simple.

## Round 1 Findings

During the Widget Wars battle round, we reviewed Flutter widgets and determined whether they should be StatefulWidget or StatelessWidget.

A widget should generally be StatelessWidget when it only displays information provided to it and does not need to maintain changing data.

A StatefulWidget is needed when the widget contains information that can change during the application's lifetime and those changes need to update the interface.

Examples we reviewed included PriceTag, LikeToggle, MenuActionTile, and SearchField. PriceTag and MenuActionTile can remain stateless because they display provided information or callbacks. LikeToggle and SearchField require state because they manage values that can change during user interaction.

## Round 2 Bug Fixes

### Bug 1 - State Lifting Scope Collision

The `isPressed` state was stored in the parent screen and shared by all four buttons. Because every button used the same variable, pressing one button caused all four buttons to react.

The fix is to make sure each button has its own pressed state instead of sharing one pressed-state value between every button.

### Bug 2 - Missing setState() in Slider

The slider changed `powerLevel`, but the change did not use `setState()`. Without `setState()`, Flutter does not know that the screen needs to rebuild, so the visible text does not update.

The fix is to update `powerLevel` inside `setState()`.

### Bug 3 - Inverted Neomorphic Depth

The pressed and unpressed shadow values were reversed. The pressed state used larger shadow offsets, which made the button appear raised, while the unpressed state used smaller offsets, making it appear pressed inward.

The shadow values need to be reversed so pressing the button creates the correct tactile visual effect.

### Bug 4 - Callback Timing Glitch

The action was being triggered during `onTapDown`, meaning it happened as soon as the user touched the button.

`onTapDown` should handle the visual pressed feedback. The actual button action should occur during `onTapUp` when the user releases the button. This makes the tactile interaction behave correctly.

# memorytrainer

Brain Trainer : Flutter application

## Design and Idea
Develop an Android app using Flutter. This app is designed to help practice brain memory.

The first screen is to select levels. There are 3 levels required. Only the level one button is enabled at the start, the other buttons are disabled. The subsequent levels can only be enabled after the previous level is won.

The second screen is the level screen. Firstly, it randomly generates 40 two-digit numbers, each number is separated by a space. At the same time, there is a stopwatch at the top and an OK button at the bottom. Once the user presses OK, they enter the recall screen. On this screen, the user inputs the 40 numbers generated on the previous screen, and then presses OK, then enters the result screen. The program will compare whether the user has successfully memorized these numbers. The correctly remembered numbers are in blue, the wrong ones are in red, then it calculates the success rate. The success rate and the final time recorded in the stopwatch on the level screen are displayed at the bottom. If the success rate is 100%, the next level is successfully unlocked. The second level has 60 random numbers, and the third level has 80 random numbers.

The program allows users to choose to exit the program at any screen. Make the interface more beautiful. The user's score must be saved, and the next time the user can continue to challenge based on the level they won last time.


A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
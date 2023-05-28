import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

// This is the main class of the app.
// It is a stateless widget that returns a MaterialApp.
// The MaterialApp has a title, theme, and home.
// The home is a StartPage.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Training', // The title of the app
      theme: ThemeData(
        primarySwatch: Colors.blue, // The primary color of the app
      ),
      home: const StartPage(), // The home page of the app
    );
  }
}

// This is the start page of the app.
// It is a stateless widget that returns a Scaffold.
// The Scaffold has an AppBar and a body.
// The AppBar has a title and an exit button.
// The body is a Container with an image and a FutureBuilder.
// The FutureBuilder gets the last level played and builds a ListView of levels.
class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Training'), // The title of the app
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app), // The exit button
            onPressed: () => SystemNavigator.pop(),
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/brain.png"), // The background image
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getLevelDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show a loading indicator while waiting for the last level
            } else {
              Map<String, dynamic> levelDetails = snapshot.data!;
              return ListView.builder(
                itemCount: levelDetails.keys.length,
                itemBuilder: (context, index) {
                  int level = index + 1;
                  Duration bestTime = levelDetails[level.toString()] != null
                      ? Duration(milliseconds: levelDetails[level.toString()])
                      : const Duration();
                  return ListTile(
                    title: ElevatedButton(
                      child: Text(level == 1
                          ? 'Start New Game'
                          : 'Start Level $level - Best Time: ${bestTime.inMinutes} min ${bestTime.inSeconds % 60} sec'),
                      onPressed: () => _startLevel(context, level),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  // This method gets the last level played and best time from SharedPreferences.
  Future<Map<String, dynamic>> _getLevelDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String levelDetailsStr = prefs.getString('levelDetails') ?? '{}';
    Map<String, dynamic> levelDetails = jsonDecode(levelDetailsStr);
    return levelDetails;
  }

  // This method starts the selected level.
  void _startLevel(BuildContext context, int level) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => HomePage(level: level), // The selected level is passed to the HomePage
      ),
    );
  }
}

// This class represents the home page of the game and is a StatefulWidget.
class HomePage extends StatefulWidget {
  final int level; // The level of the game.

  const HomePage({Key? key, this.level = 1}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState(); // Returns the state of the home page.
}

/*
 this class represents the state of the home page of the game and is a State.
*/
class _HomePageState extends State<HomePage> {
  // These variables are used to manage the game state and user input.
  // controllers: a list of TextEditingController objects used to manage user input.
  // originalNumbers: a list of strings representing the original numbers displayed to the user.
  // stopwatch: a Stopwatch object used to measure the time taken by the user to input the numbers.
  // timer: a Timer object used to update the UI every second.
  // inputEnabled: a boolean value indicating whether user input is enabled or not.
  // showUserInput: a boolean value indicating whether the user input should be displayed or not.
  // rng: a Random object used to generate random numbers.
  // accuracyIsPerfect: a boolean value indicating whether the user input is perfect or not.
  // showOriginalNumbers: a boolean value indicating whether the original numbers should be displayed or not.
  // level: an integer value representing the current level of the game.
  List<TextEditingController> controllers = [];
  List<String> originalNumbers = [];
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;
  bool inputEnabled = false;
  bool showUserInput = false;
  Random rng = Random();
  bool accuracyIsPerfect = false;
  bool showOriginalNumbers = true;
  int level = 1;

  @override
  void initState() {
    super.initState();
    level = widget.level;
    startGame(widget.level);
  }

  @override
  void dispose() {
    timer.cancel();
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // This method starts the game with the given level.
  void startGame(int level) {
    // Calculate the number of numbers to be displayed based on the level.
    int numCount = 2 + 2 * (level - 1);
    // Generate a list of random numbers as strings and store them in originalNumbers.
    originalNumbers = List<String>.generate(numCount, (index) {
      int randomNum = rng.nextInt(100);
      return randomNum < 10 ? '0$randomNum' : randomNum.toString();
    });
    // Generate a list of TextEditingController objects to manage user input.
    controllers = List<TextEditingController>.generate(numCount, (index) => TextEditingController());
    // Reset and start the stopwatch to measure the time taken by the user to input the numbers.
    stopwatch.reset();
    stopwatch.start();
    // Start a timer to update the UI every second.
    timer = Timer.periodic(const Duration(seconds: 1), (timer) => setState(() {}));
  }

  // This method calculates the text size based on the screen width.
  double getTextSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * 0.04;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Memory Training'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              SystemNavigator.pop();
            },
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/brain2.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      'Level: $level',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Time: ${stopwatch.elapsed.inMinutes} min ${stopwatch.elapsed.inSeconds % 60} sec',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (showOriginalNumbers)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 8,
                    childAspectRatio: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    children: originalNumbers
                        .map((number) => Container(
                            color: Colors.black.withOpacity(1),
                            child: Text(number, style: TextStyle(color: Colors.white, fontSize: getTextSize(context)))))
                        .toList(),
                  ),
                ),
              ElevatedButton(
                onPressed: () => showResults(context),
                child: const Text('OK'),
              ),
              if (showUserInput)
                GridView.count(
                  crossAxisCount: 8,
                  shrinkWrap: true,
                  children: List.generate(controllers.length, (index) {
                    return TextField(
                      controller: controllers[index],
                      textInputAction: TextInputAction.next,
                      onChanged: (text) {
                        if (text.length >= 2) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: TextStyle(
                        backgroundColor: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.grey.withOpacity(0.5),
                            offset: const Offset(0, 3),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // This function is called when the user presses the "OK" button to submit their input.
  // It stops the stopwatch and cancels the timer.
  // If input is not enabled, it enables input and hides the original numbers.
  // If input is enabled, it retrieves the user's input and calculates their accuracy.
  // It then navigates to the ResultsPage and passes the necessary data.
  // After returning from the ResultsPage, it clears the input fields and increments the level.
  void showResults(BuildContext context) {
    stopwatch.stop();
    timer.cancel();

    if (!inputEnabled) {
      setState(() {
        inputEnabled = true;
        showOriginalNumbers = false;
        showUserInput = true;
      });
    } else {
      List<String> userNumbers = controllers.map((controller) => controller.text).toList();

      double accuracy =
          userNumbers.length >= originalNumbers.length ? calculateAccuracy(originalNumbers, userNumbers) : 0.0;

      accuracyIsPerfect = accuracy == 1.0;

      Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) =>
              ResultsPage(originalNumbers, userNumbers, stopwatch.elapsed, accuracy, accuracyIsPerfect, level),
        ),
      ).then((_) {
        for (var controller in controllers) {
          controller.clear();
        }
        inputEnabled = false;
        showUserInput = false;
        setState(() => level++);
      });
    }
  }

  // This function calculates the accuracy of the user's input by comparing it to the original numbers.
  // It takes in two lists of strings: the original numbers and the user's input.
  // It iterates through each element of the lists and counts the number of matches.
  // It then returns the ratio of matches to the length of the original list as a double.
  double calculateAccuracy(List<String> original, List<String> user) {
    int numMatches = 0;
    for (int i = 0; i < original.length; i++) {
      if (original[i] == user[i]) {
        numMatches++;
      }
    }
    return numMatches / original.length;
  }
}

// This class represents the results page that is displayed after the user completes a level.
class ResultsPage extends StatelessWidget {
  final List<String> originalNumbers; // The original numbers that were displayed to the user.
  final List<String> userNumbers; // The numbers that the user entered.
  final Duration timeElapsed; // The time taken by the user to enter the numbers.
  final double accuracy; // The accuracy of the user's input.
  final bool accuracyIsPerfect; // A flag indicating whether the user's input was perfect.
  final int level; // The current level of the game.

  const ResultsPage(
      this.originalNumbers, this.userNumbers, this.timeElapsed, this.accuracy, this.accuracyIsPerfect, this.level,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // If the user's input was perfect, vibrate the device.
    if (accuracyIsPerfect) {
      saveBestTime(level, timeElapsed).then((_) {
        Vibration.vibrate();
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              SystemNavigator.pop();
            },
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/brain3.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.8),
                ),
                child: Column(
                  children: [
                    // Display the time taken by the user to enter the numbers.
                    Text('Time taken: ${timeElapsed.inMinutes} min ${timeElapsed.inSeconds % 60} sec',
                        style: TextStyle(fontSize: screenWidth * 0.05)),
                    // Display the accuracy of the user's input.
                    Text('Accuracy: ${(accuracy * 100).toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: screenWidth * 0.05)),
                    SizedBox(
                      height: 200, // adjust this value according to your needs
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Display the numbers entered by the user.
                            Text('Your numbers:', style: TextStyle(fontSize: screenWidth * 0.05)),
                            Text(userNumbers.join(' '), style: TextStyle(fontSize: screenWidth * 0.04)),
                            // Display the original numbers.
                            Text('Original numbers:', style: TextStyle(fontSize: screenWidth * 0.05)),
                            Text(originalNumbers.join(' '), style: TextStyle(fontSize: screenWidth * 0.04)),
                          ],
                        ),
                      ),
                    ),
                    // Display a button to either move to the next level or try again.
                    ElevatedButton(
                      onPressed: () {
                        if (accuracyIsPerfect) {
                          // If the user's input was perfect, move to the next level.
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => HomePage(level: level + 1),
                            ),
                          );
                        } else {
                          // If the user's input was not perfect, try again at the same level.
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              fullscreenDialog: true, // 设置为 true，隐藏返回按钮
                              builder: (context) => HomePage(level: level),
                            ),
                          );
                        }
                      },
                      child: Text(accuracyIsPerfect ? 'Next level' : 'Try again'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> saveBestTime(int level, Duration bestTime) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve all the best times from shared preferences.
  String? bestTimesJson = prefs.getString('bestTimes');
  Map<String, dynamic> bestTimes = {};

  // If there are best times saved, load them into the map.
  if (bestTimesJson != null && bestTimesJson.isNotEmpty) {
    bestTimes = json.decode(bestTimesJson);
  }

  // Update the best time for the current level.
  final bestTimeInSeconds = bestTime.inSeconds;
  if (!bestTimes.containsKey(level.toString()) || bestTimeInSeconds < bestTimes[level.toString()]) {
    bestTimes[level.toString()] = bestTimeInSeconds;
  }

  // Save the best times back to shared preferences.
  bestTimesJson = json.encode(bestTimes);
  await prefs.setString('bestTimes', bestTimesJson);
}

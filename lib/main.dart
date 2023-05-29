// # Copyright 2023 RAY SHENG. All Rights Reserved.
// # Licensed under the Apache License, Version 2.0 (the "License");
// # you may not use this file except in compliance with the License.
// # You may obtain a copy of the License at
// #     http://www.apache.org/licenses/LICENSE-2.0
// # Unless required by applicable law or agreed to in writing, software
// # distributed under the License is distributed on an "AS IS" BASIS,
// # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// # See the License for the specific language governing permissions and
// # limitations under the License.
// # ==============================================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
// import 'package:auto_size_text_field/auto_size_text_field.dart';

// 定义全局变量
late LevelData levelData;

class LevelData {
  late SharedPreferences _prefs;
  late Future initDone;

  LevelData() {
    initDone = _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();

    if (!_prefs.containsKey('level')) {
      await _prefs.setInt('level', 1);
    }
    // if (!_prefs.containsKey('bestTime_1')) {
    //   await _prefs.setInt('bestTime_1', 9999999);
    // }
  }

  Future<int> getLastLevel() async {
    return _prefs.getInt('level') ?? 1;
  }

  Future<void> setLastLevel(int level) async {
    await _prefs.setInt('level', level);
  }

  Future<Duration?> getBestTime(int level) async {
    final timeInMilliseconds = _prefs.getInt('bestTime_$level');
    if (timeInMilliseconds != null) {
      return Duration(milliseconds: timeInMilliseconds);
    }
    return null;
  }

  Future<void> setBestTime(int level, Duration time) async {
    final bestTimeKey = 'bestTime_$level';
    final bestTime = _prefs.getInt(bestTimeKey);

    // If there is no saved best time, or if the new time is better, save it.
    if (bestTime == null || time.inMilliseconds < bestTime) {
      await _prefs.setInt(bestTimeKey, time.inMilliseconds);
    }
  }
}

void main() {
  runApp(const MaterialApp(
    home: GameSelectPage(),
  ));
}

class GameSelectPage extends StatelessWidget {
  const GameSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Game'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/brain4.png"), // The background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50), // Adjust minimum size of button
                  padding: const EdgeInsets.symmetric(horizontal: 16), // Ajdust padding of button
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SchulteGridApp()),
                  );
                },
                child: const Text('Schulte Grid'),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05, // Or any value you want to give
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50), // Adjust minimum size of button
                  padding: const EdgeInsets.symmetric(horizontal: 16), // Ajdust padding of button
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                  );
                },
                child: const Text('Endless Number'),
              ),
              // Add more game here...
            ],
          ),
        ),
      ),
    );
  }
}

// This is the main class of the app.
// It is a stateless widget that returns a MaterialApp.
// The MaterialApp has a title, theme, and home.
// The home is a StartPage.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initLevelData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show a loading indicator while waiting for level data
        } else {
          return MaterialApp(
            title: 'Memory Training', // The title of the app
            theme: ThemeData(
              primarySwatch: Colors.blue, // The primary color of the app
            ),
            home: const StartPage(), // The home page of the app
          );
        }
      },
    );
  }

  Future<void> _initLevelData() async {
    levelData = LevelData();
    await levelData._init();
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
        child: FutureBuilder<int>(
          future: levelData.getLastLevel(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              final lastLevel = snapshot.data ?? 1;
              return ListView.builder(
                itemCount: lastLevel,
                itemBuilder: (context, index) {
                  int level = index + 1;
                  return FutureBuilder<Duration?>(
                    future: levelData.getBestTime(level),
                    builder: (context, snapshot) {
                      String buttonText;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        buttonText = 'Loading...';
                      } else {
                        final bestTime = snapshot.data;
                        if (bestTime == null) {
                          buttonText = 'Start Level $level';
                        } else {
                          buttonText =
                              'Start Level $level - Best time: ${bestTime.inMinutes} min ${bestTime.inSeconds % 60} sec';
                        }
                      }
                      return ListTile(
                        title: ElevatedButton(
                          child: Text(buttonText),
                          onPressed: () => _startLevel(context, level),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
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
    int numCount = 10 + 10 * (level - 1);
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
    return WillPopScope(
      onWillPop: () async => false, // Disable the back button.
      child: Scaffold(
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
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage("images/brain2.png"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.dstATop,
              ),
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05, // Or any value you want to give
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
                              child:
                                  Text(number, style: TextStyle(color: Colors.white, fontSize: getTextSize(context)))))
                          .toList(),
                    ),
                  ),
                ElevatedButton(
                  onPressed: () => showResults(context),
                  child: const Text('OK'),
                ),
                if (showUserInput)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: GridView.count(
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
                            fontSize: MediaQuery.of(context).size.width * 0.04,
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
                  ),
              ],
            ),
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

    // If the user's input was perfect, save the new best time and vibrate the device.
    if (accuracyIsPerfect) {
      levelData.getBestTime(level).then((bestTime) {
        if (bestTime == null || timeElapsed < bestTime) {
          levelData.setBestTime(level, timeElapsed).then((_) {
            Vibration.vibrate();
          });
        }
      });
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const StartPage()),
                          );
                        },
                        child: const Text('Back to Level Select Page'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GameSelectPage()),
                          );
                        },
                        child: const Text('Back to Game Select Page'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SchulteGridApp extends StatelessWidget {
  const SchulteGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SchulteGrid(),
    );
  }
}

class SchulteGrid extends StatefulWidget {
  const SchulteGrid({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SchulteGridState createState() => _SchulteGridState();
}

class _SchulteGridState extends State<SchulteGrid> {
  List<int> numbers = [];
  int currentNumber = 1;
  int counter = 0;
  int highScore = 0;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // initialize numbers list with numbers from 1 to 25 in random order
    numbers = List<int>.generate(25, (i) => i + 1)..shuffle();
    getHighScore();
    startTimer();
  }

  void startTimer() {
    stopwatch.start();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  void stopTimer() {
    stopwatch.stop();
    timer?.cancel();
  }

  void resetTimer() {
    stopwatch.reset();
    startTimer();
  }

  void getHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('sh_highScore') ?? 0;
    setState(() {});
  }

  void setHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sh_highScore', stopwatch.elapsed.inSeconds);
  }

  void onTap(int index) {
    if (numbers[index] == currentNumber) {
      Vibration.vibrate();
      setState(() {
        numbers[index] = 0; // hidden number
        currentNumber++;
        if (currentNumber > 25) {
          // reset game
          stopTimer();
          if (highScore == 0 || stopwatch.elapsed.inSeconds < highScore) {
            setHighScore();
            highScore = stopwatch.elapsed.inSeconds;
          }
          numbers = List<int>.generate(25, (i) => i + 1)..shuffle();
          currentNumber = 1;
          resetTimer();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width * 0.05;
    double buttonWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schulte Grid'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/brain5.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
              'Current Number: $currentNumber',
              style: TextStyle(fontSize: fontSize),
            ),
            Text(
              'Timer: ${stopwatch.elapsed.inSeconds} sec',
              style: TextStyle(fontSize: fontSize),
            ),
            Text(
              'HighScore: $highScore sec',
              style: TextStyle(fontSize: fontSize),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: numbers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, mainAxisSpacing: 10.0, crossAxisSpacing: 10.0),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => onTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        child: numbers[index] != 0
                            ? Text(
                                '${numbers[index]}',
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(1.5, 1.5),
                                      blurRadius: 2.0,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              )
                            : null, // hide number
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                child: Text(
                  'Back',
                  style: TextStyle(fontSize: fontSize),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameSelectPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

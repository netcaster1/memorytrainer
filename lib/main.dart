// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(const MaterialApp(
//     title: 'Memory Trainer',
//     home: HomePage(),
//   ));
// }
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Training',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Training'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => SystemNavigator.pop(),
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/brain.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<int?>(
          future: _getLastLevel(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              final lastLevel = snapshot.data;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    child: const Text('Start New Game'),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => const HomePage(level: 1),
                      ),
                    ),
                  ),
                  if (lastLevel != null && lastLevel > 1)
                    ElevatedButton(
                      child: Text('Continue from Level $lastLevel'),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => HomePage(level: lastLevel),
                        ),
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<int?> _getLastLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('level');
  }
}

class HomePage extends StatefulWidget {
  final int level;

  const HomePage({Key? key, this.level = 1}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void startGame(int level) {
    int numCount = 20 + 20 * (level - 1);
    originalNumbers = List<String>.generate(numCount, (index) {
      int randomNum = rng.nextInt(100);
      return randomNum < 10 ? '0$randomNum' : randomNum.toString();
    });
    controllers = List<TextEditingController>.generate(numCount, (index) => TextEditingController());
    stopwatch.reset();
    stopwatch.start();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) => setState(() {}));
  }

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
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setInt('level', level);
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
        controllers.forEach((controller) => controller.clear());
        inputEnabled = false;
        showUserInput = false;
        setState(() => level++);
      });
    }
  }

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

class ResultsPage extends StatelessWidget {
  final List<String> originalNumbers;
  final List<String> userNumbers;
  final Duration timeElapsed;
  final double accuracy;
  final bool accuracyIsPerfect;
  final int level;

  const ResultsPage(
      this.originalNumbers, this.userNumbers, this.timeElapsed, this.accuracy, this.accuracyIsPerfect, this.level,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setInt('level', accuracyIsPerfect ? level + 1 : level);
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
            children:  <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.8),
                ),
                child: Column(
                  children: [
                    Text('Time taken: ${timeElapsed.inMinutes} min ${timeElapsed.inSeconds % 60} sec',
                        style: TextStyle(fontSize: screenWidth * 0.05)),
                    Text('Accuracy: ${(accuracy * 100).toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: screenWidth * 0.05)),
                    SizedBox(
                      height: 200, // adjust this value according to your needs
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text('Your numbers:', style: TextStyle(fontSize: screenWidth * 0.05)),
                            Text(userNumbers.join(' '), style: TextStyle(fontSize: screenWidth * 0.04)),
                            Text('Original numbers:', style: TextStyle(fontSize: screenWidth * 0.05)),
                            Text(originalNumbers.join(' '), style: TextStyle(fontSize: screenWidth * 0.04)),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (accuracyIsPerfect) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => HomePage(level: level + 1),
                            ),
                          );
                        } else {
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

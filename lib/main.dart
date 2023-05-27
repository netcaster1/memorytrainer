import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _unlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _unlockedLevel = prefs.getInt('unlockedLevel') ?? 1;
    });
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unlockedLevel', _unlockedLevel);
  }

  void _startGame(int level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(level),
      ),
    ).then((value) {
      if (value == true && level == _unlockedLevel) {
        setState(() {
          _unlockedLevel++;
        });
        _saveData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Unlocked Level: $_unlockedLevel',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _startGame(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: _unlockedLevel >= 1 ? Colors.blue : Colors.grey,
              ),
              child: const Text('Level 1'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _startGame(2),
              style: ElevatedButton.styleFrom(
                backgroundColor: _unlockedLevel >= 2 ? Colors.blue : Colors.grey,
              ),
              child: const Text('Level 2'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _startGame(3),
              style: ElevatedButton.styleFrom(
                backgroundColor: _unlockedLevel >= 3 ? Colors.blue : Colors.grey,
              ),
              child: const Text('Level 3'),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  final int level;

  const GamePage(this.level, {super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<int> _numbers = [];
  final Stopwatch _stopwatch = Stopwatch();
  bool _isStarted = false;

  @override
  void initState() {
    super.initState();
    _generateNumbers();
  }

  void _generateNumbers() {
    int count = widget.level * 20;
    _numbers = List.generate(count, (index) => Random().nextInt(90) + 10);
  }

  void _startTimer() {
    _stopwatch.start();
    setState(() {
      _isStarted = true;
    });
  }

  void _stopTimer() {
    _stopwatch.stop();
    setState(() {
      _isStarted = false;
    });
  }

  void _submitAnswer(String answer) {
    List<String> input = answer.split(' ');
    List<int> numbers = input.map((e) => int.tryParse(e) ?? 0).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(_numbers, numbers, _stopwatch.elapsed),
      ),
    ).then((value) {
      if (value == true) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_numbers',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            if (!_isStarted)
              ElevatedButton(
                onPressed: _startTimer,
                child: const Text('Start'),
              ),
            if (_isStarted)
              Text(
                '${_stopwatch.elapsed.inSeconds} seconds',
                style: const TextStyle(fontSize: 24),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isStarted ? _stopTimer : null,
              child: const Text('OK'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Quit Game?'),
              content: const Text('Are you sure you want to quit the game?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Quit'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.close),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final List<int> _numbers;
  final List<int> _input;
  final Duration _elapsed;

  const ResultPage(this._numbers, this._input, this._elapsed, {super.key});

  @override
  Widget build(BuildContext context) {
    int correctCount = 0;
    List<Widget> children = [];
    for (int i = 0; i < _numbers.length; i++) {
      children.add(
        Text(
          '${_numbers[i]}',
          style: TextStyle(
            fontSize: 24,
            color: _numbers[i] == _input[i] ? Colors.blue : Colors.red,
          ),
        ),
      );
      if (_numbers[i] == _input[i]) {
        correctCount++;
      }
    }
    double successRate = correctCount / _numbers.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: children,
            ),
            const SizedBox(height: 32),
            Text(
              'Success Rate: ${(successRate * 100).toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(
              'Elapsed Time: ${_elapsed.inSeconds} seconds',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            if (successRate == 1)
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Next Level'),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Quit Game?'),
              content: const Text('Are you sure you want to quit the game?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Quit'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.close),
      ),
    );
  }
}

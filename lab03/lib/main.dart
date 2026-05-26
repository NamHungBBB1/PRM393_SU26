import 'package:flutter/material.dart';
import 'exercise1.dart' as ex1;
import 'exercise2.dart' as ex2;
import 'exercise3.dart' as ex3;
import 'exercise4.dart' as ex4;
import 'exercise5.dart' as ex5;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 03 - Advanced Dart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LabScreen(),
    );
  }
}

class LabScreen extends StatefulWidget {
  const LabScreen({super.key});

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> {
  final List<String> _titles = [
    'Exercise 1 – Product Model & Repository',
    'Exercise 2 – User Repository with JSON',
    'Exercise 3 – Async + Microtask Debugging',
    'Exercise 4 – Stream Transformation',
    'Exercise 5 – Factory Constructors & Cache',
  ];

  final List<String> _outputs = ['', '', '', '', ''];
  final List<bool> _loading = [false, false, false, false, false];

  Future<void> _run(int index) async {
    setState(() => _loading[index] = true);

    String result;
    switch (index) {
      case 0:
        result = await ex1.runExercise();
      case 1:
        result = await ex2.runExercise();
      case 2:
        result = await ex3.runExercise();
      case 3:
        result = await ex4.runExercise();
      case 4:
        result = ex5.runExercise();
      default:
        result = '';
    }

    setState(() {
      _outputs[index] = result;
      _loading[index] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Lab 03 – Advanced Dart Exercises'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _titles.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _titles[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _loading[index] ? null : () => _run(index),
                        icon: _loading[index]
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.play_arrow),
                        label: const Text('Run'),
                      ),
                    ],
                  ),
                  if (_outputs[index].isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _outputs[index],
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

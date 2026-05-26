import 'dart:async';

// Demonstrates Dart's two-queue event loop model:
//   Microtask queue  → drained completely before picking the next event
//   Event queue      → Future(() {}), I/O, timers
Future<String> runExercise() async {
  final results = <String>[];
  final eventsDone = Completer<void>();

  results.add('1. Synchronous start');

  // Scheduled on the MICROTASK queue — runs before any event-queue callback
  scheduleMicrotask(() => results.add('3. Microtask callback (runs before event queue)'));

  // Scheduled on the EVENT queue
  Future(() => results.add('4. Future event-queue callback'))
      .then((_) => eventsDone.complete());

  // Also event queue; Duration.zero still waits for the current sync + microtasks
  Future.delayed(Duration.zero, () => results.add('5. Future.delayed(zero) callback'));

  results.add('2. Synchronous end');

  await eventsDone.future;
  await Future.delayed(const Duration(milliseconds: 50));

  final output = StringBuffer();
  for (final line in results) {
    output.writeln(line);
  }
  output.writeln('\nNote: microtasks (3) always run before event-queue callbacks (4, 5).');
  return output.toString();
}

void main() {
  runExercise().then(print);
}

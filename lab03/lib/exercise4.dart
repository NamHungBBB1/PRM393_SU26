Future<String> runExercise() async {
  final output = StringBuffer();

  // Source stream: integers 1 through 5
  final numberStream = Stream.fromIterable([1, 2, 3, 4, 5]);

  final transformedStream = numberStream
      .map((n) => n * n)        // square each value: 1, 4, 9, 16, 25
      .where((n) => n % 2 == 0); // keep only even squares: 4, 16

  output.writeln('Even squares of numbers 1-5:');
  await for (final value in transformedStream) {
    output.writeln('  $value');
  }
  return output.toString();
}

Future<void> main() async {
  final result = await runExercise();
  print(result);
}

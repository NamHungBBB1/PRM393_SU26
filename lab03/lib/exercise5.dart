class Settings {
  static Settings? _instance; // cached singleton

  final String theme;
  final String language;

  // Private constructor — only callable from inside this class
  Settings._internal({this.theme = 'light', this.language = 'en'});

  // Factory constructor: returns existing instance or creates one on first call
  factory Settings() {
    _instance ??= Settings._internal();
    return _instance!;
  }
}

String runExercise() {
  final output = StringBuffer();
  final a = Settings();
  final b = Settings();

  output.writeln('a.theme:    ${a.theme}');
  output.writeln('b.language: ${b.language}');
  // identical() checks reference equality — both variables point to the same object
  output.writeln('identical(a, b): ${identical(a, b)}');
  return output.toString();
}

void main() {
  print(runExercise());
}

import 'dart:ui';

class Racer {
  final int id;
  final String name;
  final String emoji;
  final Color color;

  // runtime state (reset each race)
  double position = 0.0;
  double speed = 0.0;
  double bet = 0.0;

  Racer({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
  });

  void reset() {
    position = 0.0;
    speed = 0.0;
  }
}

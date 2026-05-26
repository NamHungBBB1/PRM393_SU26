import 'dart:convert';

class User {
  final String name;
  final String email;

  User({required this.name, required this.email});

  // Named constructor for deserializing a JSON map into a User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(name: json['name'] as String, email: json['email'] as String);
  }

  @override
  String toString() => 'User(name: $name, email: $email)';
}

// Simulates an async API call that returns JSON, then parses it
Future<List<User>> fetchUsers() async {
  await Future.delayed(const Duration(milliseconds: 300)); // fake network delay

  const rawJson = '''
  [
    {"name": "Alice", "email": "alice@example.com"},
    {"name": "Bob",   "email": "bob@example.com"},
    {"name": "Charlie","email": "charlie@example.com"}
  ]
  ''';

  final List<dynamic> decoded = jsonDecode(rawJson);
  return decoded
      .map((item) => User.fromJson(item as Map<String, dynamic>))
      .toList();
}

Future<String> runExercise() async {
  final output = StringBuffer();
  output.writeln('Fetching users from API...');
  final users = await fetchUsers();
  output.writeln('Loaded ${users.length} users:');
  for (final user in users) {
    output.writeln('  $user');
  }
  return output.toString();
}

Future<void> main() async {
  final result = await runExercise();
  print(result);
}

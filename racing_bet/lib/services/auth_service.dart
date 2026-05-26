import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final List<User> _users = [];
  User? currentUser;

  // Returns null on success, error message on failure
  String? register(String name, String password, double initialBalance) {
    if (name.trim().isEmpty) return 'Tên không được để trống';
    if (password.length < 4) return 'Mật khẩu tối thiểu 4 ký tự';
    if (initialBalance < 100) return 'Số dư ban đầu tối thiểu 100';
    if (_users.any((u) => u.name.toLowerCase() == name.toLowerCase())) {
      return 'Tên đã tồn tại';
    }
    _users.add(User(name: name.trim(), password: password, balance: initialBalance));
    return null;
  }

  // Returns user on success, null on failure
  User? login(String name, String password) {
    try {
      currentUser = _users.firstWhere(
        (u) => u.name.toLowerCase() == name.toLowerCase() && u.password == password,
      );
      return currentUser;
    } catch (_) {
      return null;
    }
  }

  void logout() => currentUser = null;
}

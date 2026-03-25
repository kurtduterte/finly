import 'package:flutter/foundation.dart';
import 'package:finly/data/repositories/auth_repository.dart';
import 'package:finly/domain/models/user.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isLogin => _isLogin;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  void toggleMode() {
    _isLogin = !_isLogin;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    await _runAuthAction(
      email: email,
      password: password,
      action: () => _repository.login(email: email, password: password),
    );
  }

  Future<void> signup({required String email, required String password}) async {
    await _runAuthAction(
      email: email,
      password: password,
      action: () => _repository.signup(email: email, password: password),
    );
  }

  Future<void> _runAuthAction({
    required String email,
    required String password,
    required Future<User> Function() action,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Email and password are required.';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await action();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

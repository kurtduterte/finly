import 'package:finly/domain/models/user.dart';

class AuthRepository {
  Future<User> login({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));
              return User(id: '1', email: email);
  }

  Future<User> signup({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));
    return User(id: '2', email: email);
  }
}

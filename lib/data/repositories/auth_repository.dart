import 'package:mobilev2/core/services/auth_service.dart';

class AuthRepository {
  final AuthService authService;
  AuthRepository(this.authService);
  Future<bool?> isLoggedIn() => authService.isLoggedIn();
  Future<bool> login(String email, String password) => authService.login(email, password);
  Future<void> logout() => authService.logout();
}

import 'package:flutter/material.dart';

import '../../services/auth/auth_service.dart';
import '../../utils/shared_prefs.dart';

class AuthViewModel extends ChangeNotifier{
  final AuthService _authService = AuthService();

  Future<bool> login(String email, String password) async {
    final success = await _authService.login(email, password);
    if (success) {
      await SharedPrefs.setLoggedIn(true);
    }
    return success;
  }

  void logout() async {
    await SharedPrefs.setLoggedIn(false);
    notifyListeners();
  }
}
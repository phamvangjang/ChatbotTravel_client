
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier{
  String _email = '';
  String _password = '';

  String get email => _email;
  String get password => _password;

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  Future<bool> login() async {
    // Simulate login delay
    await Future.delayed(const Duration(seconds: 2));

    // Replace with real logic or API call
    if (_email == 'admin@gmail.com' && _password == '123456') {
      return true;
    } else {
      return false;
    }
  }
}
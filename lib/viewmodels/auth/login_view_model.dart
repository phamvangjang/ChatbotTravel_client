import 'package:flutter/material.dart';
import 'package:mobilev2/utils/shared_prefs.dart';

class LoginViewModel extends ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  // Getter (Tương tự CanExecute trong RelayCommand)
  bool get canLogin => _email.isNotEmpty && _password.isNotEmpty && !_isLoading;

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

  Future<void> login() async {
    if (!canLogin) return; // Validate RelayCommand

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // Giả lập API call
    print('Login with $_email and $_password');

    _isLoading = false;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:mobilev2/services/auth/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  bool get obscurePassword => _obscurePassword;

  bool get isLoading => _isLoading;

  bool get canLogin => _validateInputs();

  String? get errorMessage => _errorMessage;

  LoginViewModel() {
    emailController.addListener(_onTextChanged);
    passwordController.addListener(_onTextChanged);
  }

  bool _validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    _errorMessage = null;

    final emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    final passwordValid = password.length >= 6;

    return emailValid && passwordValid;
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void _onTextChanged() {
    notifyListeners();
  }

  Future<bool> login() async {
    if (!canLogin) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (!success) {
        _errorMessage = 'Email or Password was invalid';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Somethings went wrong, please try later again';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void goToRegister(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/register');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

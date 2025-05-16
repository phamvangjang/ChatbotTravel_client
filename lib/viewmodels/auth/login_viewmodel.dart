import 'package:flutter/material.dart';
import 'package:mobilev2/core/navigation/navigation_service.dart';
import 'package:mobilev2/data/repositories/auth_repository.dart';
import 'package:mobilev2/routes/app_routes.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthRepository _authRepository ;
  final NavigationService _navigationService;

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;
  bool get canLogin => _validateInputs();
  String? get errorMessage => _errorMessage;

  LoginViewModel(this._authRepository, this._navigationService){
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

  void togglePasswordVisibility(){
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
    bool result = false;

    try {
      print('[LoginViewModel] Attempting login...');
      final success = await _authRepository.login(emailController.text.trim(), passwordController.text.trim());
      print('[LoginViewModel] Login success: $success');

      if (!success) {
        _errorMessage = 'Email or Password was invalid';
      } else {
        _navigationService.replaceWith(AppRoutes.home);
        result = true;
      }
    } catch (e, stack) {
      print('[LoginViewModel] Exception: $e');
      print(stack); // Print full stacktrace
      _errorMessage = 'Something went wrong, please try again later';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return result;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

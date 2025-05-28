import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';

class RegisterViewModel extends ChangeNotifier{
  final AuthService _authService = AuthService();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;
  bool get canRegister => _validateInputs();
  String? get errorMessage => _errorMessage;

  RegisterViewModel(){
    usernameController.addListener(_onTextChanged);
    emailController.addListener(_onTextChanged);
    passwordController.addListener(_onTextChanged);
  }

  bool _validateInputs() {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    _errorMessage = null;

    final usernameValid = username.isNotEmpty;
    final emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    final passwordValid = password.length >= 6;

    return emailValid && passwordValid && usernameValid;
  }

  void togglePasswordVisibility(){
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void _onTextChanged() {
    notifyListeners();
  }

  Future<bool> register() async {
    if(!canRegister) return false;
    _isLoading = true;
    notifyListeners();
    try{
      final success = await _authService.login(emailController.text.trim(), passwordController.text.trim());
      if(!success){
        _errorMessage = 'Email or Password was invalid';
      }
      return success;
    }catch(e){
      _errorMessage = 'Somethings went wrong, please try later again';
      return false;
    }
    finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  void goToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
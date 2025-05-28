import 'package:flutter/material.dart';
// import 'package:mobilev2/services/auth/auth_service.dart';

class SettingViewModel extends ChangeNotifier{
  // final AuthService _authService = AuthService();
  void logout(BuildContext context){
    Navigator.pushReplacementNamed(context, '/login');
  }
}
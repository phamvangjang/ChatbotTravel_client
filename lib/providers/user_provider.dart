import 'package:flutter/material.dart';
import 'package:mobilev2/models/user_model.dart';

class UserProvider extends ChangeNotifier{
  UserModel? _userModel;
  UserModel? get user => _userModel;

  void setUser(UserModel user) {
    _userModel = user;
    notifyListeners();
  }

  void clearUser() {
    _userModel = null;
    notifyListeners();
  }
}
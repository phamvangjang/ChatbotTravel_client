import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobilev2/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class AuthService {
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiService.loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      print('response ' + response.body);
      final data = jsonDecode(response.body);
      final token = data['token'];
      final userJson = data['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('user', jsonEncode(userJson));

      // final user = UserModel.fromJson(userJson);
      // Provider.of<UserProvider>(context, listen: false).setUser(user);
      return true;
    }
    print('response ' + response.body);
    return false;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> register(String username, String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    return username == 'van giang' &&
        email == 'giang@gmail.com' &&
        password == '123456';
  }
}

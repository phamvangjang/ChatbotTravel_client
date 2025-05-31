import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobilev2/providers/user_provider.dart';
import 'package:mobilev2/viewmodels/auth/login_viewmodel.dart';
import 'package:mobilev2/viewmodels/auth/register_viewmodel.dart';
import 'package:mobilev2/viewmodels/auth/verify_otp_viewmodel.dart';
import 'package:mobilev2/viewmodels/home/drawer_viewmodel.dart';
import 'package:mobilev2/viewmodels/home/main_viewmodel.dart';
import 'package:mobilev2/viewmodels/home/setting_viewmodel.dart';
import 'package:mobilev2/views/auth/login_view.dart';
import 'package:mobilev2/views/auth/register_view.dart';
import 'package:mobilev2/views/auth/verify_otp_view.dart';
import 'package:mobilev2/views/home/drawer_view.dart';
import 'package:mobilev2/views/home/main_view.dart';
import 'package:mobilev2/views/home/setting_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Khởi tạo UserProvider với dữ liệu SharedPreferences nếu có
  UserModel? user;
  final userJson = prefs.getString('user');
  if (userJson != null) {
    user = UserModel.fromJson(jsonDecode(userJson));
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => VerifyOtpViewModel()),
        ChangeNotifierProvider(create: (_) => MainViewModel()),
        ChangeNotifierProvider(create: (_) => SettingViewModel()),
        ChangeNotifierProvider(create: (_) => DrawerViewModel()),
        ChangeNotifierProvider(create: (_) => UserProvider()..setUserIfAvailable(user)),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot travel Viet Nam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),

      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/verify_otp': (context) => const VerifyOtpView(),
        '/home': (context) => const MainPage(),
        '/setting': (context) => const SettingView(),
        '/draw': (context) => const DrawerView(),
      },
    );
  }
}

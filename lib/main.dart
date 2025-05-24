import 'package:flutter/material.dart';
import 'package:mobilev2/viewmodels/auth/login_viewmodel.dart';
import 'package:mobilev2/viewmodels/home/drawer_viewmodel.dart';
import 'package:mobilev2/viewmodels/home/main_viewmodel.dart';
import 'package:mobilev2/views/auth/login_view.dart';
import 'package:mobilev2/views/home/drawer_view.dart';
import 'package:mobilev2/views/home/main_page.dart';
import 'package:mobilev2/views/splash/splash_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false); // or prefs.remove('isLoggedIn');

  runApp(
    ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot travel Viet Nam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: SplashView(),

      //routes configuration
      routes: {
        '/login': (context) => ChangeNotifierProvider(
            create: (_) => LoginViewModel(),
            child: const LoginView(),
        ),
        '/home': (context) => ChangeNotifierProvider(
            create: (_) => MainViewModel(),
            child: const MainPage(),
        ),
        '/draw': (context) => ChangeNotifierProvider(
          create: (_) => DrawerViewModel(),
          child: const DrawerView(),
        ),
      },

      //Check status login
      onGenerateRoute: (settings){
        final isLoggedIn = Provider.of<LoginViewModel>(context, listen: false).isLoggedIn;
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (_) => isLoggedIn ? const MainPage() : const LoginView(),
          );
        }
        return null;
      },
    );
  }
}

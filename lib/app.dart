import 'package:flutter/material.dart';
import 'package:mobilev2/core/di/injection.dart';
import 'package:mobilev2/core/services/auth_service.dart';
import 'package:mobilev2/routes/app_routes.dart';
import 'package:mobilev2/views/auth/login_view.dart';
import 'package:mobilev2/views/home/home_view.dart';
import 'core/navigation/navigation_service.dart';

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    final authService = getIt<AuthService>();
    final navigationService = getIt<NavigationService>();

    return MaterialApp(
      navigatorKey: navigationService.navigatorKey,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => LoginView());
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => HomeView());
          default:
            return MaterialPageRoute(builder: (_) => LoginView());
        }
      },
      home: FutureBuilder<bool?>(
        future: authService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.data == true) {
            return HomeView();
          } else {
            return LoginView();
          }
        },
      ),
    );
  }
}
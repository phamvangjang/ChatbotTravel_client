import 'package:flutter/material.dart';
import 'package:mobilev2/core/di/injection.dart';
import 'package:mobilev2/viewmodels/auth/login_viewmodel.dart';
import 'package:mobilev2/views/auth/login_view.dart';
import 'package:provider/provider.dart';
import 'core/navigation/navigation_service.dart';
import 'core/services/auth_service.dart';
import 'data/repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection();

  final navigationService = NavigationService();
  final authService = AuthService();
  final authRepository = AuthRepository(authService);

  runApp(
    MultiProvider(providers: [
      Provider<NavigationService>(create: (_) => navigationService),
      Provider<AuthRepository>(create: (_) => authRepository),
    ],
    child: MyApp(),
    )
  );
}
class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (context) => LoginViewModel(
          context.read<AuthRepository>(),
          context.read<NavigationService>(),
        ),
        child: LoginView(),
      ),
    );
  }
}

// lib/
// │
// ├── core/
// │   ├── navigation/            # Centralized NavigationService
// │   ├── services/              # API services, AuthService, etc.
// │   ├── models/                # Data models (User, etc.)
// │   ├── utils/                 # Helpers, constants, validators
// │   └── di/                    # Dependency Injection setup (GetIt)
// │
// ├── data/                      # Data sources, repositories
// │   └── repositories/
// │       └── auth_repository.dart
// │
// ├── viewmodels/                # ViewModels for each feature
// │   ├── login_viewmodel.dart
// │   └── home_viewmodel.dart
// │
// ├── views/                     # UI Screens
// │   ├── login/
// │   │   └── login_view.dart
// │   └── home/
// │       └── home_view.dart
// │
// ├── widgets/                   # Common reusable widgets
// │
// ├── app.dart                   # App widget, initial routing
// └── main.dart                  # Entry point


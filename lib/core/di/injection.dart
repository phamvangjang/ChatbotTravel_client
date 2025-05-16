import 'package:get_it/get_it.dart';
import 'package:mobilev2/viewmodels/home/main_viewmodel.dart';
import '../../data/repositories/auth_repository.dart';
import '../../viewmodels/auth/login_viewmodel.dart';
import '../navigation/navigation_service.dart';
import '../services/auth_service.dart';

final getIt = GetIt.instance;
Future<void> setupDependencyInjection() async{
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<AuthService>()));

  getIt.registerFactory(() => LoginViewModel(getIt<AuthRepository>(), getIt<NavigationService>()));
  getIt.registerFactory(() => MainViewModel());
}
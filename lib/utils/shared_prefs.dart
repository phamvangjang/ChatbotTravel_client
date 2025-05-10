
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> clearLogin() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
  }
}
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = "http://10.0.2.2:5000/api";

  // static const String _baseUrl = "http://192.168.1.100:5000/api";

  static String get loginUrl => "$_baseUrl/auth/login";

  static String get registerUrl => "$_baseUrl/auth/register";

  // final prefs = await SharedPreferences.getInstance();
  //
  // final token = prefs.getString('token');
  //
  // final response = await http.get(
  //   Uri.parse('YOUR_PROTECTED_API'),
  //   headers: {'Authorization': 'Bearer $token'},
  // );
}

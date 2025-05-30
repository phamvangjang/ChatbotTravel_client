class ApiService {
  static const String _baseUrl = "http://10.0.2.2:5000/api";
  // static const String _baseUrl = "http://192.168.1.100:5000/api";

  //auth
  static String get loginUrl => "$_baseUrl/auth/login";
  static String get registerUrl => "$_baseUrl/auth/register";
  static String get verifyOtpUrl => "$_baseUrl/auth/verify-otp";
  static String get forgotPasswordUrl => "$_baseUrl/auth/forgot-password";
  static String get verifyResetOtpUrl => "$_baseUrl/auth/verify-reset-otp";
  static String get resetPasswordUrl => "$_baseUrl/auth/reset-password";

  //chat
}

class ApiService {
  static const String _baseUrl = "http://10.0.2.2:5000/api";
  // static const String _baseUrl = "http://192.168.215.197:5000/api";

  //auth
  static String get loginUrl => "$_baseUrl/auth/login";
  static String get registerUrl => "$_baseUrl/auth/register";
  static String get verifyOtpUrl => "$_baseUrl/auth/verify-otp";
  static String get forgotPasswordUrl => "$_baseUrl/auth/forgot-password";
  static String get verifyResetOtpUrl => "$_baseUrl/auth/verify-reset-otp";
  static String get resetPasswordUrl => "$_baseUrl/auth/reset-password";

  //chat
  static String get chatbotUrl => "$_baseUrl/travel/chat";
  static String get createNewConversationUrl => "$_baseUrl/travel/conversations";
  static String getUserConversationsUrl(int userId) =>
      "$_baseUrl/travel/conversations/$userId/messages";
  static String messagesByConversationUrl(int conversationId) =>
      "$_baseUrl/travel/conversations/$conversationId/messages";
  static String get saveMessageUrl => "$_baseUrl/travel/messages";
  static String endConversationUrl(int conversationId) =>
      "$_baseUrl/travel/conversations/$conversationId/end";
  static String get chatbotVoiceUrl => "$_baseUrl/travel/ask/voice";
}

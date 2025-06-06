class ApiService {
  static const String _baseUrl = "http://10.0.2.2:5000/api";

  // static const String _baseUrl = "http://192.168.215.197:5000/api";

  //auth all done
  static String get loginUrl => "$_baseUrl/auth/login";

  static String get registerUrl => "$_baseUrl/auth/register";

  static String get verifyOtpUrl => "$_baseUrl/auth/verify-otp";

  static String get forgotPasswordUrl => "$_baseUrl/auth/forgot-password";

  static String get verifyResetOtpUrl => "$_baseUrl/auth/verify-reset-otp";

  static String get resetPasswordUrl => "$_baseUrl/auth/reset-password";

  //chat
  static String get chatbotUrl => "$_baseUrl/travel/chat";

  //done endpoint
  static String get createNewConversationUrl =>
      "$_baseUrl/chatting/conversations";

  static String getUserConversationsUrl(int userId) =>
      "$_baseUrl/chatting/conversations/list?user_id=$userId";

  static String messagesByConversationUrl(int conversationId) =>
      "$_baseUrl/chatting/conversations/messages?conversation_id=$conversationId";

  static String get saveMessageUrl => "$_baseUrl/chatting/messages";

  static String endConversationUrl(int conversationId) =>
      "$_baseUrl/chatting/conversations/end?conversation_id=$conversationId";

  static String get chatbotVoiceUrl => "$_baseUrl/chatting/messages/voice";
}

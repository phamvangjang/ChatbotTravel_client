import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobilev2/services/api_service.dart';

class ChatService {
  Future<Map<String, dynamic>> sendMessageToBot(String message) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.chatbotUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Lỗi server: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi gửi tin nhắn: $e');
    }
  }
}
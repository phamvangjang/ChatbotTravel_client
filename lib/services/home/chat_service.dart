import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mobilev2/models/conversation_model.dart';
import 'package:mobilev2/models/message_model.dart';
import 'package:mobilev2/services/api_service.dart';

class ChatService {
  // Tạo cuộc trò chuyện mới
  Future<Conversation> createNewConversation(int userId, String sourceLanguage,) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.createNewConversationUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'source_language': sourceLanguage,
          'started_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final conversationJson = responseData['data'];
        return Conversation.fromJson(conversationJson);
      } else {
        throw Exception('Không thể tạo cuộc trò chuyện mới');
      }
    } catch (e) {
      throw Exception('Lỗi tạo cuộc trò chuyện: $e');
    }
  }

  // Lấy danh sách cuộc trò chuyện của user
  Future<List<Conversation>> getUserConversations(int userId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.getUserConversationsUrl(userId)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'];
        return data.map((json) => Conversation.fromJson(json)).toList();
      } else {
        throw Exception('Không thể tải danh sách cuộc trò chuyện');
      }
    } catch (e) {
      throw Exception('Lỗi tải cuộc trò chuyện: $e');
    }
  }

  // Lấy tin nhắn của một cuộc trò chuyện
  Future<List<Message>> getConversationMessages(int conversationId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.messagesByConversationUrl(conversationId)),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        final List<dynamic> jsonData = jsonMap['data'];
        return jsonData.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Không thể tải tin nhắn');
      }
    } catch (e) {
      print('Lỗi tải tin nhắn: $e');
      throw Exception('Lỗi tải tin nhắn: $e');
    }
  }

  // Lưu tin nhắn vào database
  Future<Map<String, dynamic>> sendMessageAndGetResponse({
    required int conversationId,
    required String sender,
    required String messageText,
    String translatedText = '',
    String messageType = 'text',
    String? voiceUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.saveMessageUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'conversation_id': conversationId,
          'sender': sender,
          'message_text': messageText,
          'translated_text': translatedText,
          'message_type': messageType,
          'voice_url': voiceUrl,
          'sent_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Kiểm tra status
        if (responseData['status'] != 'success') {
          throw Exception(responseData['message'] ?? 'Lỗi không xác định');
        }

        return responseData;
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi gửi tin nhắn: $e');
    }
  }

  // Gửi tin nhắn giọng nói và nhận phản hồi
  Future<Map<String, dynamic>> sendVoiceMessageAndGetResponse({
    required int conversationId,
    required String sender,
    required String audioFilePath,
  }) async {
    try {
      // Tạo request multipart/form-data
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiService.sendVoiceMessagesUrl(conversationId, sender)),
      );

      // Thêm headers giống như trong curl command
      request.headers['accept'] = 'application/json';

      // Xác định loại file audio
      final audioFile = File(audioFilePath);
      final fileExtension = audioFilePath.split('.').last.toLowerCase();
      final mimeType = fileExtension == 'wav' ? 'audio/wav' :
      fileExtension == 'mp3' ? 'audio/mpeg' : 'audio/wav';

      // Thêm file audio vào request với mime type chính xác
      request.files.add(
        http.MultipartFile(
          'audio',  // Tên field phải là 'audio' như trong curl command
          audioFile.readAsBytes().asStream(),
          audioFile.lengthSync(),
          filename: audioFile.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        ),
      );

      print('Sending voice message to: ${request.url}');
      print('File path: $audioFilePath');
      print('File size: ${audioFile.lengthSync()} bytes');
      print('MIME type: $mimeType');

      // Gửi request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Kiểm tra status
        if (responseData['status'] != 'success') {
          throw Exception(responseData['message'] ?? 'Lỗi không xác định');
        }

        return responseData;
      } else {
        throw Exception('❌ Lỗi server: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Lỗi gửi tin nhắn giọng nói: $e');
      throw Exception('Lỗi gửi tin nhắn giọng nói: $e');
    }
  }

  // Kết thúc cuộc trò chuyện
  Future<void> endConversation(int conversationId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.endConversationUrl(conversationId)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ended_at': DateTime.now().toIso8601String()}),
      );

      if (response.statusCode != 200) {
        throw Exception('Không thể kết thúc cuộc trò chuyện');
      }
    } catch (e) {
      throw Exception('Lỗi kết thúc cuộc trò chuyện: $e');
    }
  }
}

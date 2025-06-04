import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobilev2/models/conversation.dart';
import '../../models/message_model.dart';
import '../../services/home/chat_service.dart';
import '../../services/home/geocoding_service.dart';

class MainViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  // State variables
  List<Message> _messages = [];
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  int _currentUserId = 1; // Thay thế bằng user ID thực tế
  String _sourceLanguage = 'vi';

  // Getters
  List<Message> get messages => _messages;
  List<Conversation> get conversations => _conversations;
  Conversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  int get currentUserId => _currentUserId;

  // Khởi tạo ViewModel
  Future<void> initialize() async {
    await loadUserConversations();

    // Nếu có cuộc trò chuyện gần nhất, tải nó
    if (_conversations.isNotEmpty) {
      final latestConversation = _conversations.first;
      await loadConversation(latestConversation.conversationId);
    } else {
      // Nếu không có cuộc trò chuyện nào, tạo mới
      await createNewConversation();
    }
  }

  // Tải danh sách cuộc trò chuyện của user
  Future<void> loadUserConversations() async {
    _setLoading(true);
    _clearError();

    try {
      _conversations = await _chatService.getUserConversations(_currentUserId);
      // Sắp xếp theo thời gian mới nhất
      _conversations.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Tải một cuộc trò chuyện cụ thể
  Future<void> loadConversation(int conversationId) async {
    _setLoading(true);
    _clearError();

    try {
      // Tìm cuộc trò chuyện trong danh sách
      _currentConversation = _conversations.firstWhere(
            (conv) => conv.conversationId == conversationId,
      );

      // Tải tin nhắn của cuộc trò chuyện
      _messages = await _chatService.getConversationMessages(conversationId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Tạo cuộc trò chuyện mới
  Future<void> createNewConversation() async {
    _setLoading(true);
    _clearError();

    try {
      final newConversation = await _chatService.createNewConversation(
        _currentUserId,
        _sourceLanguage,
      );

      _currentConversation = newConversation;
      _conversations.insert(0, newConversation);
      _messages = [];

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Gửi tin nhắn
  Future<void> sendMessage(String messageText) async {
    if (_currentConversation == null || messageText.trim().isEmpty) return;

    _setSending(true);
    _clearError();

    try {
      // Lưu tin nhắn của user
      final userMessage = await _chatService.saveMessage(
        conversationId: _currentConversation!.conversationId,
        sender: 'user',
        messageText: messageText,
      );

      _messages.add(userMessage);
      notifyListeners();

      // Gửi tin nhắn đến chatbot
      final botResponse = await _chatService.sendMessageToBot(messageText);

      // Lưu phản hồi của bot
      final botMessage = await _chatService.saveMessage(
        conversationId: _currentConversation!.conversationId,
        sender: 'bot',
        messageText: botResponse['message'] ?? '',
        translatedText: botResponse['translated_message'] ?? '',
      );

      _messages.add(botMessage);
      notifyListeners();

    } catch (e) {
      _setError(e.toString());
    } finally {
      _setSending(false);
    }
  }

  // Kết thúc cuộc trò chuyện hiện tại và tạo mới
  Future<void> startNewConversation() async {
    if (_currentConversation != null) {
      try {
        await _chatService.endConversation(_currentConversation!.conversationId);
      } catch (e) {
        // Log error nhưng vẫn tiếp tục tạo cuộc trò chuyện mới
        debugPrint('Lỗi kết thúc cuộc trò chuyện: $e');
      }
    }

    await createNewConversation();
  }

  // Mở bản đồ với text tin nhắn
  void openMapWithMessageText(BuildContext context, String messageText) {
    // Implement logic mở bản đồ
    // Ví dụ: Navigator.push(context, MaterialPageRoute(...))
    debugPrint('Mở bản đồ với: $messageText');
  }

  // Refresh toàn bộ dữ liệu
  Future<void> refresh() async {
    await loadUserConversations();
    if (_currentConversation != null) {
      await loadConversation(_currentConversation!.conversationId);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSending(bool sending) {
    _isSending = sending;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Setter cho user ID (khi user đăng nhập)
  void setCurrentUser(int userId, String language) {
    _currentUserId = userId;
    _sourceLanguage = language;
    initialize(); // Tải lại dữ liệu cho user mới
  }

  GeocodingService geocodingService = GeocodingService();

  Future<List<Message>> loadMessages() async {
    final jsonString = await rootBundle.loadString('assets/messages.json');
    final jsonMap = json.decode(jsonString);
    final messages =
        (jsonMap['messages'] as List).map((e) => Message.fromJson(e)).toList();
    return messages;
  }

  // Future<void> openMapWithMessageText(
  //   BuildContext context,
  //   String messageText,
  // ) async {
  //   print(context);
  //   print(messageText);
  //   if (!messageText.contains("Địa điểm:")) return;
  //
  //   final extracted = messageText.split("Địa điểm:")[1];
  //   final suggestions = extracted.split(",");
  //   final places = suggestions.map((e) => e.trim()).toList();
  //
  //   final List<Map<String, dynamic>> locations = [];
  //
  //   for (final place in places) {
  //     final coords = await geocodingService.getCoordinatesFromMapbox(place);
  //     if (coords != null) {
  //       locations.add({"name": place, "lat": coords[0], "lng": coords[1]});
  //     }
  //   }
  //
  //   if (locations.isEmpty) return;
  //
  //   Navigator.push(context, MaterialPageRoute(builder: (_) => MapViewScreenv2()));
  // }
}

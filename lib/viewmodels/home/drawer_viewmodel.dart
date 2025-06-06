import 'package:flutter/material.dart';

import '../../models/conversation.dart';
import '../../services/home/chat_service.dart';

class DrawerViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final int userId;
  List<Conversation> _conversations = [];
  bool _isLoading = false;

  List<Conversation> get conversations => _conversations;

  bool get isLoading => _isLoading;

  DrawerViewModel(this.userId) {
    print("Khởi tạo DrawerViewModel với userId: $userId");
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    _isLoading = true;
    notifyListeners();

    try {
      _conversations = await _chatService.getUserConversations(userId);
      print(_conversations);
    } catch (e) {
      debugPrint("Lỗi khi tải cuộc trò chuyện: $e");
      _conversations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

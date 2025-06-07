import 'package:flutter/material.dart';

import '../../models/conversation_model.dart';
import '../../services/home/chat_service.dart';

class DrawerViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final int userId;

  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _error;

  DrawerViewModel(this.userId) {
    loadConversations();
  }

  // Getters
  List<Conversation> get conversations => _conversations;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // Tải danh sách cuộc trò chuyện
  Future<void> loadConversations() async {
    _setLoading(true);
    _clearError();

    try {
      _conversations = await _chatService.getUserConversations(userId);
      // Sắp xếp theo thời gian mới nhất
      _conversations.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Refresh danh sách
  Future<void> refresh() async {
    await loadConversations();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // List<Conversation> get conversations => _conversations;
  //
  // bool get isLoading => _isLoading;
  //
  // DrawerViewModel(this.userId) {
  //   print("Khởi tạo DrawerViewModel với userId: $userId");
  //   fetchConversations();
  // }
  //
  // Future<void> fetchConversations() async {
  //   _isLoading = true;
  //   notifyListeners();
  //
  //   try {
  //     _conversations = await _chatService.getUserConversations(userId);
  //     print(_conversations);
  //   } catch (e) {
  //     debugPrint("Lỗi khi tải cuộc trò chuyện: $e");
  //     _conversations = [];
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }
}

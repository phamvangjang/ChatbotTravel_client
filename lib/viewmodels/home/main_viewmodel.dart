import 'package:flutter/material.dart';
import 'package:mobilev2/models/conversation_model.dart';
import 'package:mobilev2/services/home/voice_service.dart';
import 'package:record/record.dart';
import '../../models/message_model.dart';
import '../../services/home/chat_service.dart';

class MainViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final VoiceService _voiceService = VoiceService();
  int? _currentUserId;

  // State variables
  List<Message> _messages = [];
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  bool _isSending = false;
  bool _isRecording = false;
  String? _error;
  String _sourceLanguage = 'vi';
  int? _lastInitializedUserId;

  // Getters
  List<Message> get messages => _messages;
  List<Conversation> get conversations => _conversations;
  Conversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  //bool get isRecording => _isRecording;
  bool get isRecording {
    // print("Getter isRecording: $_isRecording");
    return _isRecording;
  }
  String? get error => _error;
  int? get currentUserId => _currentUserId;

  // ✅ Getter để kiểm tra user hợp lệ
  bool get hasValidUser => _currentUserId != null && _currentUserId! > 0;

  // Lấy amplitude stream để tạo waveform
  Stream<Amplitude>? getAmplitudeStream() {
    return _voiceService.getAmplitudeStream();
  }

  // ✅ Method để update userId từ UserProvider
  void updateUserId(int? newUserId) {
    print("🔄 updateUserId called: old=$_currentUserId, new=$newUserId");

    if (_currentUserId != newUserId) {
      print("✅ User ID changed from $_currentUserId to $newUserId");

      final oldUserId = _currentUserId;
      _currentUserId = newUserId;

      // Reset data khi user thay đổi
      if (oldUserId != null && newUserId != oldUserId) {
        print("🔄 Resetting user data due to user change");
        _resetUserData();
        _lastInitializedUserId = null;
      }

      // ✅ Thông báo listeners về thay đổi
      notifyListeners();

      // Khởi tạo lại nếu có user hợp lệ
      if (hasValidUser) {
        print("🚀 Initializing MainViewModel for user $newUserId");
        initialize();
      } else {
        print("⚠️ No valid user, skipping initialization");
      }
    } else {
      print("ℹ️ User ID unchanged: $_currentUserId");
    }
  }

  // Khởi tạo ViewModel
  Future<void> initialize() async {
    if (!hasValidUser) {
      print("No valid user, skipping initialization");
      return;
    }

    // Kiểm tra xem có phải user mới hay không
    bool isNewUser = _lastInitializedUserId != _currentUserId;

    if (isNewUser) {
      // Reset tất cả dữ liệu khi user mới đăng nhập
      _resetUserData();
      _lastInitializedUserId = _currentUserId;
    }

    await loadUserConversations();

    // Tải cuộc trò chuyện mới nhất của user hiện tại
    if (_conversations.isNotEmpty) {
      // Lọc các cuộc trò chuyện thuộc về user hiện tại
      final userConversations = _conversations.where(
              (conv) => conv.userId == _currentUserId
      ).toList();

      if (userConversations.isNotEmpty) {
        // Sắp xếp theo thời gian mới nhất và lấy conversation đầu tiên
        userConversations.sort((a, b) => b.startedAt.compareTo(a.startedAt));
        final latestConversation = userConversations.first;

        print("Loading latest conversation for user $_currentUserId: ${latestConversation.conversationId}");
        await loadConversation(latestConversation.conversationId);
      } else {
        print("No conversations found for user $_currentUserId, creating new one");
        await createNewConversation();
      }
    } else {
      print("No conversations exist, creating new one for user $_currentUserId");
      await createNewConversation();
    }
  }

  void _resetUserData() {
    _messages.clear();
    _conversations.clear();
    _currentConversation = null;
    _error = null;
    _isLoading = false;
    _isSending = false;
    _isRecording = false;

    // Dừng mọi hoạt động ghi âm nếu đang thực hiện
    if (_isRecording) {
      _voiceService.cancelRecording();
      _isRecording = false;
    }

    notifyListeners();
  }

  // Tải danh sách cuộc trò chuyện của user
  Future<void> loadUserConversations() async {
    if (!hasValidUser) return;
    _setLoading(true);
    clearError();

    try {
      print("Loading conversations for user: $_currentUserId");

      // Đảm bảo chỉ load conversations của user hiện tại
      _conversations = await _chatService.getUserConversations(_currentUserId!);

      // Double check: Lọc lại để đảm bảo chỉ có conversations của user hiện tại
      _conversations = _conversations.where(
              (conv) => conv.userId == _currentUserId
      ).toList();

      // Sắp xếp theo thời gian mới nhất
      _conversations.sort((a, b) => b.startedAt.compareTo(a.startedAt));

      print("Loaded ${_conversations.length} conversations for user $_currentUserId");
      notifyListeners();
    } catch (e) {
      print("Error loading conversations for user $_currentUserId: $e");
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Tải một cuộc trò chuyện cụ thể
  Future<void> loadConversation(int conversationId) async {
    if (!hasValidUser) return;
    _setLoading(true);
    clearError();

    try {
      print("Loading conversation $conversationId for user $_currentUserId");

      // Tìm cuộc trò chuyện trong danh sách và validate
      final conversation = _conversations.firstWhere(
            (conv) => conv.conversationId == conversationId && conv.userId == _currentUserId,
        orElse: () => throw Exception("Conversation $conversationId not found or doesn't belong to user $_currentUserId"),
      );

      _currentConversation = conversation;

      // Tải tin nhắn của cuộc trò chuyện
      _messages = await _chatService.getConversationMessages(conversationId);

      print("Loaded ${_messages.length} messages for conversation $conversationId");
      notifyListeners();
    } catch (e) {
      print("Error loading conversation $conversationId: $e");
      _setError(e.toString());

      // Nếu không tải được conversation, tạo mới
      await createNewConversation();
    } finally {
      _setLoading(false);
    }
  }

  // Tạo cuộc trò chuyện mới
  Future<void> createNewConversation() async {
    if (!hasValidUser) return;
    _setLoading(true);
    clearError();

    try {
      print("Creating new conversation for user $_currentUserId");

      final newConversation = await _chatService.createNewConversation(
        _currentUserId!,
        _sourceLanguage,
      );

      // Validate conversation được tạo đúng user
      if (newConversation.userId != _currentUserId) {
        throw Exception("Created conversation doesn't belong to current user");
      }

      _currentConversation = newConversation;
      _conversations.insert(0, newConversation);
      _messages = [];

      print("Created new conversation ${newConversation.conversationId} for user $_currentUserId");
      notifyListeners();
    } catch (e) {
      print("Error creating new conversation for user $_currentUserId: $e");
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Gửi tin nhắn dạng text
  Future<void> sendMessage(String messageText) async {
    if (!hasValidUser || _currentConversation == null || messageText.trim().isEmpty) return;

    _setSending(true);
    clearError();

    try {
      // Lưu tin nhắn của user
      final response = await _chatService.sendMessageAndGetResponse(
        conversationId: _currentConversation!.conversationId,
        sender: 'user',
        messageText: messageText,
      );

      // Parse response data
      final responseData = response['data'] as Map<String, dynamic>;

      // Lấy user message từ response
      final userMessageData = responseData['user_message'] as Map<String, dynamic>;
      final userMessage = Message.fromJson(userMessageData);

      // Lấy bot message từ response
      final botMessageData = responseData['bot_message'] as Map<String, dynamic>;
      final botMessage = Message.fromJson(botMessageData);

      // Thêm cả 2 tin nhắn vào danh sách
      _messages.add(userMessage);
      _messages.add(botMessage);
      notifyListeners();

    } catch (e) {
      _setError(e.toString());
    } finally {
      _setSending(false);
    }
  }

  // Bắt đầu ghi âm
  Future<void> startVoiceRecording() async {
    clearError();

    try {
      final success = await _voiceService.startRecording();
      if (success) {
        _isRecording = true;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Dừng ghi âm và gửi tin nhắn giọng nói
  Future<void> stopVoiceRecording() async {
    if (!_isRecording) return;

    _setSending(true);
    _isRecording = false;
    notifyListeners();

    try {
      final filePath = await _voiceService.stopRecording();
      if (filePath == null || filePath.isEmpty) {
        throw Exception('Không thể lưu file ghi âm');
      }

      // Upload và chuyển đổi giọng nói thành text
      final voiceResult = await _voiceService.uploadVoiceAndConvertToText(filePath);
      final transcribedText = voiceResult['text'] as String;
      final voiceUrl = voiceResult['voice_url'] as String;

      if (transcribedText.isEmpty) {
        throw Exception('Không thể nhận diện giọng nói. Vui lòng thử lại.');
      }

      // Lưu tin nhắn giọng nói của user
      final response = await _chatService.sendMessageAndGetResponse(
        conversationId: _currentConversation!.conversationId,
        sender: 'user',
        messageText: transcribedText,
        messageType: 'voice',
        voiceUrl: voiceUrl,
      );

      // Parse response data
      final responseData = response['data'] as Map<String, dynamic>;

      // Lấy user message từ response
      final userMessageData = responseData['user_message'] as Map<String, dynamic>;
      final userMessage = Message.fromJson(userMessageData);

      // Lấy bot message từ response
      final botMessageData = responseData['bot_message'] as Map<String, dynamic>;
      final botMessage = Message.fromJson(botMessageData);

      // Thêm cả 2 tin nhắn vào danh sách
      _messages.add(userMessage);
      _messages.add(botMessage);
      notifyListeners();

      // Xóa file tạm
      await _voiceService.deleteTemporaryFile(filePath);

    } catch (e) {
      _setError(e.toString());
      _isRecording = false;
      notifyListeners();
    } finally {
      _setSending(false);
    }
  }

  // Hủy ghi âm
  Future<void> cancelVoiceRecording() async {
    if (!_isRecording) return;

    try {
      await _voiceService.cancelRecording();
      _isRecording = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Kết thúc cuộc trò chuyện hiện tại và tạo mới
  Future<void> startNewConversation() async {
    if (_currentConversation != null) {
      try {
        await _chatService.endConversation(
          _currentConversation!.conversationId,
        );
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
    if (!hasValidUser) return;
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

  void clearError() {
    _error = null;
  }

  // Setter cho user ID (khi user đăng nhập)
  void setCurrentUser(int userId, String language) {
    bool isUserChanged = _currentUserId != userId;

    _currentUserId = userId;
    _sourceLanguage = language;

    if (isUserChanged) {
      print("User changed from $_currentUserId to $userId");
      // Reset dữ liệu khi user thay đổi
      _resetUserData();
      _lastInitializedUserId = null; // Reset để force initialize lại
    }

    initialize(); // Tải lại dữ liệu cho user mới// Tải lại dữ liệu cho user mới
  }

  // Phương thức logout để reset toàn bộ dữ liệu
  void logout() {
    _resetUserData();
    _lastInitializedUserId = null;
    _currentUserId = 0; // hoặc giá trị mặc định
  }

  void sendAudioMessage() async {
    // Ghi âm hoặc chọn file âm thanh rồi gửi lên server
    print("sendAudioMessage");
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}

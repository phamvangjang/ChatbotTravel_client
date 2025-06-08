import 'package:flutter/material.dart';
import 'package:mobilev2/models/conversation_model.dart';
import 'package:mobilev2/services/home/voice_service.dart';
import 'package:record/record.dart';
import '../../models/message_model.dart';
import '../../services/home/chat_service.dart';

class MainViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final VoiceService _voiceService = VoiceService();
  final int _currentUserId;

  MainViewModel(this._currentUserId);

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
  int get currentUserId => _currentUserId;

  // Lấy amplitude stream để tạo waveform
  Stream<Amplitude>? getAmplitudeStream() {
    return _voiceService.getAmplitudeStream();
  }

  // Khởi tạo ViewModel
  Future<void> initialize() async {
    // Kiểm tra xem có phải user mới hay không
    bool isNewUser = _lastInitializedUserId != _currentUserId;

    if (isNewUser) {
      // Reset tất cả dữ liệu khi user mới đăng nhập
      _resetUserData();
      _lastInitializedUserId = _currentUserId;
    }
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
    _setLoading(true);
    clearError();

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
    clearError();
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
    clearError();

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

  // Gửi tin nhắn dạng text
  Future<void> sendMessage(String messageText) async {
    if (_currentConversation == null || messageText.trim().isEmpty) return;

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

    //_currentUserId = userId;
    _sourceLanguage = language;

    if (isUserChanged) {
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
    //_currentUserId = 0; // hoặc giá trị mặc định
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

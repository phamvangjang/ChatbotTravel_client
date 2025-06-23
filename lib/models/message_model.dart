class Message {
  final int messageId;
  final int conversationId;
  final String sender;
  final String messageText;
  final String? translatedText;
  final String? messageType;
  final String? voiceUrl;
  final DateTime sentAt;
  final List<String>? places;

  Message({
    required this.messageId,
    required this.conversationId,
    required this.sender,
    required this.messageText,
    required this.translatedText,
    required this.messageType,
    required this.voiceUrl,
    required this.sentAt,
    this.places, // Thay đổi thành optional
  });

  // Helper method để decode Unicode escape sequences
  static String _decodeUnicode(String text) {
    try {
      // Decode Unicode escape sequences như \u00ed, \u00e0, etc.
      return text.replaceAllMapped(
        RegExp(r'\\u([0-9a-fA-F]{4})'),
        (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)),
      );
    } catch (e) {
      print('Lỗi khi decode Unicode: $e');
      return text;
    }
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    // Xử lý places - chỉ bot messages mới có places
    List<String>? places;
    
    // Kiểm tra sender - chỉ bot mới có places
    final sender = json['sender'] as String?;
    final isBotMessage = sender == 'bot';
    
    if (isBotMessage) {
      try {
        // Ưu tiên lấy places đã được xử lý từ ChatService
        if (json['places'] != null) {
          if (json['places'] is List) {
            places = (json['places'] as List).map((place) {
              final placeStr = place as String;
              // Decode Unicode escape sequences khi đọc từ database
              return _decodeUnicode(placeStr);
            }).toList();
          }
        }
        
        // Nếu không có places, thử xử lý travel_data
        if (places == null && json['travel_data'] != null) {
          final travelData = json['travel_data'] as Map<String, dynamic>;
          if (travelData['success'] == true && travelData['search_results'] != null) {
            final searchResults = travelData['search_results'] as List;
            places = searchResults
                .map((result) {
                  final placeName = result['ten_dia_diem'] as String;
                  // Decode Unicode escape sequences
                  return _decodeUnicode(placeName);
                })
                .toList();
          }
        }
      } catch (e) {
        print('Lỗi khi xử lý places trong Message.fromJson: $e');
        places = null;
      }
    } else {
      // User messages luôn có places = null
      places = null;
    }

    return Message(
      messageId: json['message_id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      sender: json['sender'],
      messageText: json['message_text'],
      translatedText: json['translated_text'],
      messageType: json['message_type'],
      voiceUrl: json['voice_url'],
      sentAt: DateTime.parse(json['sent_at']),
      places: places, // null cho user, có thể có giá trị cho bot
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'message_id': messageId,
      'conversation_id': conversationId,
      'sender': sender,
      'message_text': messageText,
      'translated_text': translatedText,
      'message_type': messageType,
      'voice_url': voiceUrl,
      'sent_at': sentAt.toIso8601String(),
      'places': places, // Có thể null
    };
  }

  Message copyWith({
    int? messageId,
    int? conversationId,
    String? sender,
    String? messageText,
    String? translatedText,
    String? messageType,
    String? voiceUrl,
    DateTime? sentAt,
    List<String>? places, // Thay đổi thành nullable
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      sender: sender ?? this.sender,
      messageText: messageText ?? this.messageText,
      translatedText: translatedText ?? this.translatedText,
      messageType: messageType ?? this.messageType,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      sentAt: sentAt ?? this.sentAt,
      places: places ?? this.places, // Có thể null
    );
  }
}

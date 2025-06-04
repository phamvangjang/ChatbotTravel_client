class Message {
  final int messageId;
  final int conversationId;
  final String sender;
  final String messageText;
  final String translatedText;
  final String messageType;
  final String voiceUrl;
  final DateTime sentAt;

  Message({
    required this.messageId,
    required this.conversationId,
    required this.sender,
    required this.messageText,
    required this.translatedText,
    required this.messageType,
    required this.voiceUrl,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'],
      conversationId: json['conversation_id'],
      sender: json['sender'],
      messageText: json['message_text'],
      translatedText: json['translated_text'],
      messageType: json['message_type'],
      voiceUrl: json['voice_url'],
      sentAt: DateTime.parse(json['sent_at']),
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
      'sent_at': sentAt.toIso8601String()
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
    );
  }
}

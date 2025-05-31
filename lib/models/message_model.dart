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
}

class Conversation {
  final int conversationId;
  final int userId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String sourceLanguage;

  Conversation({
    required this.conversationId,
    required this.userId,
    required this.endedAt,
    required this.startedAt,
    required this.sourceLanguage
  });

  factory Conversation.fromJson(Map<String, dynamic> json){
    return Conversation(
      conversationId: json['conversation_id'],
      userId: json['user_id'],
      startedAt: DateTime.parse(json['started_at']),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'])
          : null,
      sourceLanguage: json['source_language']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'conversation_id': conversationId,
      'user_id': userId,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'source_language': sourceLanguage
    };
  }

  Conversation copyWith({
    int? conversationId,
    int? userId,
    DateTime? startedAt,
    DateTime? endedAt,
    String? sourceLanguage,
  }) {
    return Conversation(
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
    );
  }
}
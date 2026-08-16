
enum AIMessageType { user, ai, system }

enum AIContentType { text, thinking, error, rateLimited }

/// A single AI chat message
class AIMessage {
  final String id;
  final AIMessageType type;
  final String text;
  final AIContentType contentType;
  final List<AICardData> cards;
  final List<String> suggestions;
  final DateTime timestamp;

  const AIMessage({
    required this.id,
    required this.type,
    required this.text,
    this.contentType = AIContentType.text,
    this.cards = const [],
    this.suggestions = const [],
    required this.timestamp,
  });

  AIMessage copyWith({
    String? text,
    AIContentType? contentType,
    List<AICardData>? cards,
    List<String>? suggestions,
  }) {
    return AIMessage(
      id: id,
      type: type,
      text: text ?? this.text,
      contentType: contentType ?? this.contentType,
      cards: cards ?? this.cards,
      suggestions: suggestions ?? this.suggestions,
      timestamp: timestamp,
    );
  }

  static int _idCounter = 0;

  factory AIMessage.user(String text) {
    return AIMessage(
      id: 'user_${++_idCounter}_${DateTime.now().millisecondsSinceEpoch}',
      type: AIMessageType.user,
      text: text,
      timestamp: DateTime.now(),
    );
  }

  factory AIMessage.ai(String text, {List<AICardData> cards = const [], List<String> suggestions = const [], AIContentType contentType = AIContentType.text}) {
    return AIMessage(
      id: 'ai_${++_idCounter}_${DateTime.now().millisecondsSinceEpoch}',
      type: AIMessageType.ai,
      text: text,
      contentType: contentType,
      cards: cards,
      suggestions: suggestions,
      timestamp: DateTime.now(),
    );
  }

  factory AIMessage.thinking(String text) {
    return AIMessage(
      id: 'thinking_${++_idCounter}_${DateTime.now().millisecondsSinceEpoch}',
      type: AIMessageType.ai,
      text: text,
      contentType: AIContentType.thinking,
      timestamp: DateTime.now(),
    );
  }
}

/// Represents a rich card returned by AI (athlete, trial, etc.)
enum AICardType { athlete, trial, profile, highlight, comparison }

class AICardData {
  final AICardType type;
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? detail;
  final Map<String, String> metadata;
  final String? actionLabel;
  final String? actionRoute;

  const AICardData({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.detail,
    this.metadata = const {},
    this.actionLabel,
    this.actionRoute,
  });
}

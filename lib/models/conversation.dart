import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final String lastMessage;
  final DateTime lastMessageAt;
  final Map<String, int> unreadCounts;

  const Conversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    this.lastMessage = '',
    required this.lastMessageAt,
    this.unreadCounts = const {},
  });

  String otherParticipantId(String myUid) {
    return participantIds.firstWhere(
      (id) => id != myUid,
      orElse: () => participantIds.first,
    );
  }

  String? otherParticipantName(String myUid) {
    final otherId = otherParticipantId(myUid);
    return participantNames[otherId];
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt,
      'unreadCounts': unreadCounts,
    };
  }

  factory Conversation.fromMap(String id, Map<String, dynamic> map) {
    return Conversation(
      id: id,
      participantIds: (map['participantIds'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      participantNames: (map['participantNames'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v.toString())),
      lastMessage: map['lastMessage'] as String? ?? '',
      lastMessageAt: _toDateTime(map['lastMessageAt']) ?? DateTime.now(),
      unreadCounts: (map['unreadCounts'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

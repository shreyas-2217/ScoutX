import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String type;
  final String fromUserId;
  final String fromUserName;
  final String? message;
  final String? conversationId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.fromUserId,
    required this.fromUserName,
    this.message,
    this.conversationId,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'message': message,
      'conversationId': conversationId,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      type: map['type'] as String? ?? '',
      fromUserId: map['fromUserId'] as String? ?? '',
      fromUserName: map['fromUserName'] as String? ?? '',
      message: map['message'] as String?,
      conversationId: map['conversationId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: _toDateTime(map['createdAt']) ?? DateTime.now(),
    );
  }

  AppNotification copyWith({
    String? id,
    String? type,
    String? fromUserId,
    String? fromUserName,
    String? message,
    String? conversationId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      message: message ?? this.message,
      conversationId: conversationId ?? this.conversationId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

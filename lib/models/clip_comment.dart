import 'package:cloud_firestore/cloud_firestore.dart';

class ClipComment {
  final String id;
  final String clipId;
  final String uid;
  final String name;
  final String text;
  final DateTime createdAt;

  const ClipComment({
    required this.id,
    required this.clipId,
    required this.uid,
    required this.name,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'clipId': clipId,
      'uid': uid,
      'name': name,
      'text': text,
      'createdAt': createdAt,
    };
  }

  factory ClipComment.fromMap(String id, Map<String, dynamic> map) {
    return ClipComment(
      id: id,
      clipId: map['clipId'] as String? ?? '',
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown',
      text: map['text'] as String? ?? '',
      createdAt: _toDateTime(map['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

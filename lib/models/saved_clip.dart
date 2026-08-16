import 'package:cloud_firestore/cloud_firestore.dart';

class SavedClip {
  final String id;
  final String clipId;
  final String title;
  final String videoUrl;
  final String sport;
  final String position;
  final String playerName;
  final DateTime savedAt;

  const SavedClip({
    required this.id,
    required this.clipId,
    required this.title,
    required this.videoUrl,
    required this.sport,
    required this.position,
    required this.playerName,
    required this.savedAt,
  });

  factory SavedClip.fromMap(String id, Map<String, dynamic> map) {
    return SavedClip(
      id: id,
      clipId: map['clipId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      videoUrl: map['videoUrl'] as String? ?? '',
      sport: map['sport'] as String? ?? 'Other',
      position: map['position'] as String? ?? 'Any',
      playerName: map['playerName'] as String? ?? 'Unknown',
      savedAt: _toDateTime(map['savedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

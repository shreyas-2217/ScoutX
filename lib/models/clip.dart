import 'package:cloud_firestore/cloud_firestore.dart';

class Clip {
  final String id;
  final String playerId;
  final String playerName;
  final String videoUrl;
  final String title;
  final String sport;
  final String position;
  final String description;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final DateTime createdAt;

  final String? highlightType;
  final List<String> skills;
  final List<String> tags;
  final String? ageGroup;
  final String? location;
  final String? searchableText;

  const Clip({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.videoUrl,
    required this.title,
    required this.sport,
    required this.position,
    this.description = '',
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    required this.createdAt,
    this.highlightType,
    this.skills = const [],
    this.tags = const [],
    this.ageGroup,
    this.location,
    this.searchableText,
  });

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'videoUrl': videoUrl,
      'title': title,
      'sport': sport,
      'position': position,
      'description': description,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'viewCount': viewCount,
      'createdAt': createdAt,
      'highlightType': highlightType,
      'skills': skills,
      'tags': tags,
      'ageGroup': ageGroup,
      'location': location,
      'searchableText': searchableText,
    };
  }

  factory Clip.fromMap(String id, Map<String, dynamic> map) {
    return Clip(
      id: id,
      playerId: map['playerId'] as String? ?? '',
      playerName: map['playerName'] as String? ?? 'Unknown',
      videoUrl: map['videoUrl'] as String? ?? '',
      title: map['title'] as String? ?? '',
      sport: map['sport'] as String? ?? 'Other',
      position: map['position'] as String? ?? 'Any',
      description: map['description'] as String? ?? '',
      likeCount: (map['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (map['commentCount'] as num?)?.toInt() ?? 0,
      viewCount: (map['viewCount'] as num?)?.toInt() ?? 0,
      createdAt: _toDateTime(map['createdAt']) ?? DateTime.now(),
      highlightType: map['highlightType'] as String?,
      skills: _toStringList(map['skills']),
      tags: _toStringList(map['tags']),
      ageGroup: map['ageGroup'] as String?,
      location: map['location'] as String?,
      searchableText: map['searchableText'] as String?,
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return const [];
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

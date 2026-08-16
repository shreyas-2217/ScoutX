import 'package:cloud_firestore/cloud_firestore.dart';

class Opening {
  final String id;
  final String coachId;
  final String coachName;
  final String teamName;
  final String sport;
  final String position;
  final String skillLevel;
  final String description;
  final String status; // open | closed
  final DateTime createdAt;

  const Opening({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.teamName,
    required this.sport,
    required this.position,
    required this.skillLevel,
    this.description = '',
    this.status = 'open',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'coachId': coachId,
      'coachName': coachName,
      'teamName': teamName,
      'sport': sport,
      'position': position,
      'skillLevel': skillLevel,
      'description': description,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory Opening.fromMap(String id, Map<String, dynamic> map) {
    return Opening(
      id: id,
      coachId: map['coachId'] as String? ?? '',
      coachName: map['coachName'] as String? ?? 'Coach',
      teamName: map['teamName'] as String? ?? '',
      sport: map['sport'] as String? ?? 'Other',
      position: map['position'] as String? ?? 'Any',
      skillLevel: map['skillLevel'] as String? ?? 'Beginner',
      description: map['description'] as String? ?? '',
      status: map['status'] as String? ?? 'open',
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

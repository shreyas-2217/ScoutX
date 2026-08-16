import 'package:cloud_firestore/cloud_firestore.dart';

class TrialApplication {
  final String id;
  final String trialId;
  final String playerId;
  final String playerName;
  final String sport;
  final String position;
  final String message;
  final String status; // pending | accepted | rejected
  final DateTime appliedAt;

  const TrialApplication({
    required this.id,
    required this.trialId,
    required this.playerId,
    required this.playerName,
    required this.sport,
    required this.position,
    this.message = '',
    this.status = 'pending',
    required this.appliedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'trialId': trialId,
      'playerId': playerId,
      'playerName': playerName,
      'sport': sport,
      'position': position,
      'message': message,
      'status': status,
      'appliedAt': appliedAt,
    };
  }

  factory TrialApplication.fromMap(String id, Map<String, dynamic> map) {
    return TrialApplication(
      id: id,
      trialId: map['trialId'] as String? ?? '',
      playerId: map['playerId'] as String? ?? '',
      playerName: map['playerName'] as String? ?? 'Player',
      sport: map['sport'] as String? ?? 'Other',
      position: map['position'] as String? ?? 'Any',
      message: map['message'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      appliedAt: _toDateTime(map['appliedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

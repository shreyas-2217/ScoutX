import 'package:cloud_firestore/cloud_firestore.dart';

class Trial {
  final String id;
  final String coachId;
  final String coachName;
  final String teamName;
  final String title;
  final String sport;
  final String position;
  final String skillLevel;
  final String? location;
  final String? date;
  final String description;
  final String status; // open | closed
  final List<String> selectedPlayerIds;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? venue;
  final String? address;

  const Trial({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.teamName,
    required this.title,
    required this.sport,
    required this.position,
    required this.skillLevel,
    this.location,
    this.date,
    this.description = '',
    this.status = 'open',
    this.selectedPlayerIds = const [],
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.venue,
    this.address,
  });

  Trial copyWith({String? status, List<String>? selectedPlayerIds}) {
    return Trial(
      id: id,
      coachId: coachId,
      coachName: coachName,
      teamName: teamName,
      title: title,
      sport: sport,
      position: position,
      skillLevel: skillLevel,
      location: location,
      date: date,
      description: description,
      status: status ?? this.status,
      selectedPlayerIds: selectedPlayerIds ?? this.selectedPlayerIds,
      createdAt: createdAt,
      latitude: latitude,
      longitude: longitude,
      venue: venue,
      address: address,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coachId': coachId,
      'coachName': coachName,
      'teamName': teamName,
      'title': title,
      'sport': sport,
      'position': position,
      'skillLevel': skillLevel,
      'location': location,
      'date': date,
      'description': description,
      'status': status,
      'selectedPlayerIds': selectedPlayerIds,
      'createdAt': createdAt,
      'latitude': latitude,
      'longitude': longitude,
      'venue': venue,
      'address': address,
    };
  }

  factory Trial.fromMap(String id, Map<String, dynamic> map) {
    return Trial(
      id: id,
      coachId: map['coachId'] as String? ?? '',
      coachName: map['coachName'] as String? ?? 'Coach',
      teamName: map['teamName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      sport: map['sport'] as String? ?? 'Other',
      position: map['position'] as String? ?? 'Any',
      skillLevel: map['skillLevel'] as String? ?? 'Beginner',
      location: map['location'] as String?,
      date: map['date'] as String?,
      description: map['description'] as String? ?? '',
      status: map['status'] as String? ?? 'open',
      selectedPlayerIds: (map['selectedPlayerIds'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      createdAt: _toDateTime(map['createdAt']) ?? DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      venue: map['venue'] as String?,
      address: map['address'] as String?,
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

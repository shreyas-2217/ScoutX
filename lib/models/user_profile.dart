import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String role; // player | coach | viewer
  final String displayName;
  final String? username;
  final String? profileImageUrl;
  final String? sport;
  final String? position;
  final String? bio;
  final String? city;
  final String? ageGroup;
  final int? heightCm;
  final int? weightKg;
  final String? contactEmail;
  final String? phone;
  final String? teamName;
  final String? clubName;
  final int clipCount;
  final int followerCount;
  final int followingCount;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.role,
    required this.displayName,
    this.username,
    this.profileImageUrl,
    this.sport,
    this.position,
    this.bio,
    this.city,
    this.ageGroup,
    this.heightCm,
    this.weightKg,
    this.contactEmail,
    this.phone,
    this.teamName,
    this.clubName,
    this.clipCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  bool get isPlayer => role == 'player';
  bool get isCoach => role == 'coach';
  bool get isViewer => role == 'viewer';

  bool get isProfileComplete {
    if (isViewer) return true;
    if (profileImageUrl == null || profileImageUrl!.isEmpty) return false;
    if (username == null || username!.isEmpty) return false;
    if (sport == null || sport!.isEmpty) return false;
    if (city == null || city!.isEmpty) return false;
    if (bio == null || bio!.isEmpty) return false;
    if (isPlayer && (position == null || position!.isEmpty)) return false;
    return true;
  }

  List<String> get missingFields {
    final missing = <String>[];
    if (isViewer) return missing;
    if (profileImageUrl == null || profileImageUrl!.isEmpty) missing.add('Profile Picture');
    if (username == null || username!.isEmpty) missing.add('Username');
    if (sport == null || sport!.isEmpty) missing.add('Sport');
    if (city == null || city!.isEmpty) missing.add('Location');
    if (bio == null || bio!.isEmpty) missing.add('Bio');
    if (isPlayer && (position == null || position!.isEmpty)) missing.add('Position');
    return missing;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'displayName': displayName,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'sport': sport,
      'position': position,
      'bio': bio,
      'city': city,
      'ageGroup': ageGroup,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'contactEmail': contactEmail,
      'phone': phone,
      'teamName': teamName,
      'clubName': clubName,
      'clipCount': clipCount,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'createdAt': createdAt,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'viewer',
      displayName: map['displayName'] as String? ?? 'Player',
      username: map['username'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      sport: map['sport'] as String?,
      position: map['position'] as String?,
      bio: map['bio'] as String?,
      city: map['city'] as String?,
      ageGroup: map['ageGroup'] as String?,
      heightCm: map['heightCm'] as int?,
      weightKg: map['weightKg'] as int?,
      contactEmail: map['contactEmail'] as String?,
      phone: map['phone'] as String?,
      teamName: map['teamName'] as String?,
      clubName: map['clubName'] as String?,
      clipCount: (map['clipCount'] as num?)?.toInt() ?? 0,
      followerCount: (map['followerCount'] as num?)?.toInt() ?? 0,
      followingCount: (map['followingCount'] as num?)?.toInt() ?? 0,
      createdAt: _toDateTime(map['createdAt']) ?? DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
}

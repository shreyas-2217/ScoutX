import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';

/// ScoutX AI Tool definitions and handlers
/// These map to the existing Firestore database methods
class AITools {
  /// Search athletes/players by criteria
  static Future<List<Map<String, dynamic>>> searchAthletes({
    String? sport,
    String? position,
    String? location,
    int? ageMax,
    int? ageMin,
    int limit = 10,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection(AppPaths.users)
          .where('role', isEqualTo: 'player');

      if (sport != null && sport.isNotEmpty) {
        query = query.where('sport', isEqualTo: sport);
      }
      if (position != null && position.isNotEmpty) {
        query = query.where('position', isEqualTo: position);
      }

      final snapshot = await query.limit(limit).get();
      List<Map<String, dynamic>> results = [];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (location != null && location.isNotEmpty) {
          final city = (data['city'] as String?)?.toLowerCase() ?? '';
          if (!city.contains(location.toLowerCase())) continue;
        }

        results.add({
          'uid': doc.id,
          'name': data['displayName'] ?? 'Unknown',
          'sport': data['sport'] ?? '',
          'position': data['position'] ?? '',
          'city': data['city'] ?? '',
          'bio': data['bio'] ?? '',
          'clipCount': data['clipCount'] ?? 0,
          'followerCount': data['followerCount'] ?? 0,
          'followingCount': data['followingCount'] ?? 0,
        });
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  /// Search coaches
  static Future<List<Map<String, dynamic>>> searchCoaches({
    String? sport,
    String? location,
    int limit = 10,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection(AppPaths.users)
          .where('role', isEqualTo: 'coach');

      if (sport != null && sport.isNotEmpty) {
        query = query.where('sport', isEqualTo: sport);
      }

      final snapshot = await query.limit(limit).get();
      List<Map<String, dynamic>> results = [];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (location != null && location.isNotEmpty) {
          final city = (data['city'] as String?)?.toLowerCase() ?? '';
          if (!city.contains(location.toLowerCase())) continue;
        }
        results.add({
          'uid': doc.id,
          'name': data['displayName'] ?? 'Unknown',
          'sport': data['sport'] ?? '',
          'teamName': data['teamName'] ?? '',
          'city': data['city'] ?? '',
          'bio': data['bio'] ?? '',
          'followerCount': data['followerCount'] ?? 0,
        });
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  /// Search trials
  static Future<List<Map<String, dynamic>>> searchTrials({
    String? sport,
    String? location,
    String? skillLevel,
    int limit = 10,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection(AppPaths.trials)
          .where('status', isEqualTo: 'open');

      if (sport != null && sport.isNotEmpty) {
        query = query.where('sport', isEqualTo: sport);
      }

      final snapshot = await query.limit(limit).get();
      List<Map<String, dynamic>> results = [];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (location != null && location.isNotEmpty) {
          final loc = (data['location'] as String?)?.toLowerCase() ?? '';
          if (!loc.contains(location.toLowerCase())) continue;
        }
        if (skillLevel != null && skillLevel.isNotEmpty) {
          final level = (data['skillLevel'] as String?)?.toLowerCase() ?? '';
          if (!level.contains(skillLevel.toLowerCase())) continue;
        }
        results.add({
          'id': doc.id,
          'title': data['title'] ?? '',
          'sport': data['sport'] ?? '',
          'position': data['position'] ?? '',
          'coachName': data['coachName'] ?? '',
          'teamName': data['teamName'] ?? '',
          'location': data['location'] ?? '',
          'date': data['date'] ?? '',
          'skillLevel': data['skillLevel'] ?? '',
          'description': data['description'] ?? '',
        });
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  /// Search highlights/clips
  static Future<List<Map<String, dynamic>>> searchHighlights({
    String? sport,
    String? position,
    int limit = 10,
  }) async {
    try {
      Query query = FirebaseFirestore.instance.collection(AppPaths.clips);

      if (sport != null && sport.isNotEmpty) {
        query = query.where('sport', isEqualTo: sport);
      }
      if (position != null && position.isNotEmpty) {
        query = query.where('position', isEqualTo: position);
      }

      final snapshot = await query
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'playerName': data['playerName'] ?? '',
          'playerId': data['playerId'] ?? '',
          'sport': data['sport'] ?? '',
          'position': data['position'] ?? '',
          'viewCount': data['viewCount'] ?? 0,
          'likeCount': data['likeCount'] ?? 0,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get user's own profile info
  static Future<Map<String, dynamic>?> getMyProfile(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(AppPaths.users)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return {
        'uid': doc.id,
        'name': data['displayName'] ?? '',
        'role': data['role'] ?? '',
        'sport': data['sport'] ?? '',
        'position': data['position'] ?? '',
        'city': data['city'] ?? '',
        'bio': data['bio'] ?? '',
        'clipCount': data['clipCount'] ?? 0,
        'followerCount': data['followerCount'] ?? 0,
        'followingCount': data['followingCount'] ?? 0,
      };
    } catch (e) {
      return null;
    }
  }

  /// Get public profile of any user
  static Future<Map<String, dynamic>?> getPublicProfile(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(AppPaths.users)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return {
        'uid': doc.id,
        'name': data['displayName'] ?? '',
        'role': data['role'] ?? '',
        'sport': data['sport'] ?? '',
        'position': data['position'] ?? '',
        'city': data['city'] ?? '',
        'bio': data['bio'] ?? '',
        'clipCount': data['clipCount'] ?? 0,
        'followerCount': data['followerCount'] ?? 0,
        'followingCount': data['followingCount'] ?? 0,
      };
    } catch (e) {
      return null;
    }
  }

  /// Get user's trial applications (private - only for own account)
  static Future<List<Map<String, dynamic>>> getMyApplications(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(AppPaths.trialApplications)
          .where('playerId', isEqualTo: uid)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'trialId': data['trialId'] as String? ?? '',
          'playerName': data['playerName'] as String? ?? '',
          'sport': data['sport'] as String? ?? '',
          'status': data['status'] as String? ?? '',
          'message': data['message'] as String? ?? '',
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get popular highlights (by view count)
  static Future<List<Map<String, dynamic>>> getPopularHighlights({
    String? sport,
    int limit = 5,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection(AppPaths.clips)
          .orderBy('viewCount', descending: true);

      if (sport != null && sport.isNotEmpty) {
        query = query.where('sport', isEqualTo: sport);
      }

      final snapshot = await query.limit(limit).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['title'] as String? ?? '',
          'playerName': data['playerName'] as String? ?? '',
          'playerId': data['playerId'] as String? ?? '',
          'sport': data['sport'] as String? ?? '',
          'viewCount': data['viewCount'] as int? ?? 0,
          'likeCount': data['likeCount'] as int? ?? 0,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Search across athletes, trials, and highlights simultaneously
  static Future<Map<String, List<Map<String, dynamic>>>> searchAll(
    String query,
    String sport,
  ) async {
    final athleteResults = await searchAthletes(
      sport: sport.isNotEmpty ? sport : null,
      limit: 3,
    );
    final trialResults = await searchTrials(
      sport: sport.isNotEmpty ? sport : null,
      limit: 3,
    );
    final highlightResults = await searchHighlights(
      sport: sport.isNotEmpty ? sport : null,
      limit: 3,
    );

    return {
      'athletes': athleteResults,
      'trials': trialResults,
      'highlights': highlightResults,
    };
  }
}

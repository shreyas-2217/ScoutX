import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'cloudinary_service.dart';
import '../cloudinary_config.dart';

import '../models/clip.dart';
import '../models/clip_comment.dart';
import '../models/app_notification.dart';
import '../models/conversation.dart';
import '../models/opening.dart';
import '../models/saved_clip.dart';
import '../models/trial.dart';
import '../models/trial_application.dart';
import '../models/user_profile.dart';
import '../constants.dart';

class Database {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CloudinaryService _cloudinary = CloudinaryService(scoutxCloudinary);

  // -------------------------------------------------------------------------
  // Users
  // -------------------------------------------------------------------------

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection(AppPaths.users).doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.id, doc.data()!);
  }

  Stream<UserProfile> streamUserProfile(String uid) {
    return _db
        .collection(AppPaths.users)
        .doc(uid)
        .snapshots()
        .map((doc) => UserProfile.fromMap(doc.id, doc.data()!));
  }

  Future<void> createUserProfile(UserProfile profile) async {
    await _db.collection(AppPaths.users).doc(profile.uid).set(profile.toMap());
  }

  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    await _db.collection(AppPaths.users).doc(uid).update(updates);
  }

  Future<Map<String, UserProfile>> getUsersByIds(List<String> ids) async {
    final result = <String, UserProfile>{};
    if (ids.isEmpty) return result;
    for (final id in ids) {
      final p = await getUserProfile(id);
      if (p != null) result[id] = p;
    }
    return result;
  }

  /// Cached AI scouting report stored on the user document, or null.
  Future<Map<String, dynamic>?> getScoutingReport(String uid) async {
    final doc = await _db.collection(AppPaths.users).doc(uid).get();
    if (!doc.exists) return null;
    final raw = doc.data()!['aiScoutingReport'];
    return raw is Map<String, dynamic> ? raw : null;
  }

  Stream<List<UserProfile>> streamUsers({String role = 'player'}) {
    return _db
        .collection(AppPaths.users)
        .where('role', isEqualTo: role)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => UserProfile.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  // -------------------------------------------------------------------------
  // Clips
  // -------------------------------------------------------------------------

  Future<String> uploadVideo(Clip clip, Uint8List bytes, String fileName) {
    return _cloudinary.uploadVideo(clip.playerId, bytes, fileName);
  }

  Future<String> addClip(Clip clip) async {
    final ref = await _db.collection(AppPaths.clips).add(clip.toMap());
    await _db.collection(AppPaths.users).doc(clip.playerId).update({
      'clipCount': FieldValue.increment(1),
    });
    return ref.id;
  }

  Future<void> deleteClip(String clipId) async {
    final clip = await getClip(clipId);
    await _db.collection(AppPaths.clips).doc(clipId).delete();
    if (clip != null) {
      await _db.collection(AppPaths.users).doc(clip.playerId).update({
        'clipCount': FieldValue.increment(-1),
      });
    }
  }

  Future<void> syncClipCount(String playerId) async {
    try {
      final snap = await _db
          .collection(AppPaths.clips)
          .where('playerId', isEqualTo: playerId)
          .get();
      final actualCount = snap.docs.length;
      await _db.collection(AppPaths.users).doc(playerId).update({
        'clipCount': actualCount,
      });
    } catch (_) {
      // Silently skip — profile will still load with existing clipCount value
    }
  }

  Stream<List<Clip>> streamClips({int limit = 60}) {
    return _db
        .collection(AppPaths.clips)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => Clip.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<Clip>> streamClipsForPlayer(String playerId) {
    return _db
        .collection(AppPaths.clips)
        .where('playerId', isEqualTo: playerId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Clip.fromMap(d.id, d.data()))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Future<List<Clip>> fetchClipsForPlayer(String playerId) async {
    final snap = await _db
        .collection(AppPaths.clips)
        .where('playerId', isEqualTo: playerId)
        .get();
    final clips = snap.docs.map((d) => Clip.fromMap(d.id, d.data())).toList();
    clips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return clips;
  }

  Future<Clip?> getClip(String clipId) async {
    final doc = await _db.collection(AppPaths.clips).doc(clipId).get();
    if (!doc.exists) return null;
    return Clip.fromMap(doc.id, doc.data()!);
  }

  // -------------------------------------------------------------------------
  // Likes
  // -------------------------------------------------------------------------

  Future<bool> hasLiked(String clipId, String uid) async {
    final snap = await _db
        .collection(AppPaths.likes)
        .where('clipId', isEqualTo: clipId)
        .get();
    return snap.docs.any((d) => d['uid'] == uid);
  }

  Future<void> likeClip(String clipId, String uid) async {
    await _db.collection(AppPaths.likes).add({'clipId': clipId, 'uid': uid});
    await _db.collection(AppPaths.clips).doc(clipId).update({
      'likeCount': FieldValue.increment(1),
    });
  }

  Future<void> unlikeClip(String clipId, String uid) async {
    final snap = await _db
        .collection(AppPaths.likes)
        .where('clipId', isEqualTo: clipId)
        .get();
    for (final d in snap.docs) {
      if (d['uid'] == uid) {
        await d.reference.delete();
      }
    }
    await _db.collection(AppPaths.clips).doc(clipId).update({
      'likeCount': FieldValue.increment(-1),
    });
  }

  // -------------------------------------------------------------------------
  // Comments
  // -------------------------------------------------------------------------

  Stream<List<ClipComment>> streamComments(String clipId) {
    return _db
        .collection(AppPaths.clipComments)
        .where('clipId', isEqualTo: clipId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ClipComment.fromMap(d.id, d.data()))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Future<void> addComment(ClipComment comment) async {
    await _db.collection(AppPaths.clipComments).add(comment.toMap());
    await _db.collection(AppPaths.clips).doc(comment.clipId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  Future<void> deleteComment(String commentId, String clipId) async {
    await _db.collection(AppPaths.clipComments).doc(commentId).delete();
    await _db.collection(AppPaths.clips).doc(clipId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }

  // -------------------------------------------------------------------------
  // Saved clips
  // -------------------------------------------------------------------------

  Future<void> saveClip(String uid, Clip clip) async {
    await _db.collection(AppPaths.savedClips).doc('${uid}_${clip.id}').set({
      'uid': uid,
      'clipId': clip.id,
      'title': clip.title,
      'videoUrl': clip.videoUrl,
      'sport': clip.sport,
      'position': clip.position,
      'playerName': clip.playerName,
      'savedAt': DateTime.now(),
    });
  }

  Future<void> unsaveClip(String uid, String clipId) async {
    await _db
        .collection(AppPaths.savedClips)
        .doc('${uid}_$clipId')
        .delete();
  }

  Stream<Set<String>> streamSavedClipIds(String uid) {
    return _db
        .collection(AppPaths.savedClips)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d['clipId'] as String).toSet());
  }

  Stream<List<SavedClip>> streamSavedClips(String uid) {
    return _db
        .collection(AppPaths.savedClips)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => SavedClip.fromMap(d.id, d.data()))
              .toList()
            ..sort((a, b) => b.savedAt.compareTo(a.savedAt)),
        );
  }

  // -------------------------------------------------------------------------
  // Follows
  // -------------------------------------------------------------------------

  String _followKey(String followerId, String followeeId) =>
      '${followerId}_$followeeId';

  Future<bool> isFollowing(String followerId, String followeeId) async {
    final doc = await _db
        .collection(AppPaths.follows)
        .doc(_followKey(followerId, followeeId))
        .get();
    return doc.exists;
  }

  Stream<Set<String>> streamFollowingIds(String uid) {
    return _db
        .collection(AppPaths.follows)
        .where('followerId', isEqualTo: uid)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => d['followeeId'] as String).toSet(),
        );
  }

  Future<void> follow(String followerId, String followeeId) async {
    await _db
        .collection(AppPaths.follows)
        .doc(_followKey(followerId, followeeId))
        .set({
      'followerId': followerId,
      'followeeId': followeeId,
      'createdAt': DateTime.now(),
    });
    await _db.collection(AppPaths.users).doc(followeeId).update({
      'followerCount': FieldValue.increment(1),
    });
    await _db.collection(AppPaths.users).doc(followerId).update({
      'followingCount': FieldValue.increment(1),
    });
  }

  Future<void> unfollow(String followerId, String followeeId) async {
    await _db
        .collection(AppPaths.follows)
        .doc(_followKey(followerId, followeeId))
        .delete();
    await _db.collection(AppPaths.users).doc(followeeId).update({
      'followerCount': FieldValue.increment(-1),
    });
    await _db.collection(AppPaths.users).doc(followerId).update({
      'followingCount': FieldValue.increment(-1),
    });
  }

  // -------------------------------------------------------------------------
  // Views
  // -------------------------------------------------------------------------

  Future<void> incrementClipViews(String clipId) async {
    await _db.collection(AppPaths.clips).doc(clipId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  // -------------------------------------------------------------------------
  // Reports
  // -------------------------------------------------------------------------

  Future<void> reportClip({
    required String clipId,
    required String reporterUid,
    required String reason,
  }) async {
    await _db.collection(AppPaths.reports).add({
      'clipId': clipId,
      'reporterUid': reporterUid,
      'reason': reason,
      'reportedAt': DateTime.now(),
    });
  }

  // -------------------------------------------------------------------------
  // Trials
  // -------------------------------------------------------------------------

  Future<String> addTrial(Trial trial) async {
    final ref = await _db.collection(AppPaths.trials).add(trial.toMap());
    return ref.id;
  }

  Stream<List<Trial>> streamTrials() {
    return _db
        .collection(AppPaths.trials)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Trial.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<Trial>> streamTrialsForCoach(String coachId) {
    return _db
        .collection(AppPaths.trials)
        .where('coachId', isEqualTo: coachId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Trial.fromMap(d.id, d.data()))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Future<Trial?> getTrial(String trialId) async {
    final doc = await _db.collection(AppPaths.trials).doc(trialId).get();
    if (!doc.exists) return null;
    return Trial.fromMap(doc.id, doc.data()!);
  }

  Stream<Trial> streamTrial(String trialId) {
    return _db
        .collection(AppPaths.trials)
        .doc(trialId)
        .snapshots()
        .map((doc) => Trial.fromMap(doc.id, doc.data()!));
  }

  Future<void> updateTrialStatus(String trialId, String status) async {
    await _db.collection(AppPaths.trials).doc(trialId).update({
      'status': status,
    });
  }

  /// Manually add/remove a player id from the trial's final selected list.
  Future<void> addPlayerToFinalList(String trialId, String playerId) async {
    await _db.collection(AppPaths.trials).doc(trialId).update({
      'selectedPlayerIds': FieldValue.arrayUnion([playerId]),
    });
  }

  Future<void> removePlayerFromFinalList(
    String trialId,
    String playerId,
  ) async {
    await _db.collection(AppPaths.trials).doc(trialId).update({
      'selectedPlayerIds': FieldValue.arrayRemove([playerId]),
    });
  }

  // -------------------------------------------------------------------------
  // Trial applications
  // -------------------------------------------------------------------------

  Future<String> applyToTrial(TrialApplication application) async {
    final ref = await _db
        .collection(AppPaths.trialApplications)
        .add(application.toMap());
    return ref.id;
  }

  Future<TrialApplication?> getApplicationFor(
    String trialId,
    String playerId,
  ) async {
    final snap = await _db
        .collection(AppPaths.trialApplications)
        .where('trialId', isEqualTo: trialId)
        .where('playerId', isEqualTo: playerId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return TrialApplication.fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  Stream<List<TrialApplication>> streamApplicationsForTrial(String trialId) {
    return _db
        .collection(AppPaths.trialApplications)
        .where('trialId', isEqualTo: trialId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => TrialApplication.fromMap(d.id, d.data()))
              .toList()
            ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt)),
        );
  }

  Stream<List<TrialApplication>> streamApplicationsForPlayer(String playerId) {
    return _db
        .collection(AppPaths.trialApplications)
        .where('playerId', isEqualTo: playerId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => TrialApplication.fromMap(d.id, d.data()))
              .toList()
            ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt)),
        );
  }

  Future<void> updateApplicationStatus(String appId, String status) async {
    await _db.collection(AppPaths.trialApplications).doc(appId).update({
      'status': status,
    });
  }

  // -------------------------------------------------------------------------
  // Openings
  // -------------------------------------------------------------------------

  Future<String> addOpening(Opening opening) async {
    final ref = await _db.collection(AppPaths.openings).add(opening.toMap());
    return ref.id;
  }

  Stream<List<Opening>> streamOpenings() {
    return _db
        .collection(AppPaths.openings)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Opening.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<Opening>> streamOpeningsForCoach(String coachId) {
    return _db
        .collection(AppPaths.openings)
        .where('coachId', isEqualTo: coachId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Opening.fromMap(d.id, d.data()))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Future<void> setOpeningStatus(String openingId, String status) async {
    await _db.collection(AppPaths.openings).doc(openingId).update({
      'status': status,
    });
  }

  Future<void> deleteOpening(String openingId) async {
    await _db.collection(AppPaths.openings).doc(openingId).delete();
  }

  // -------------------------------------------------------------------------
  // Account deletion (cascading)
  // -------------------------------------------------------------------------

  Future<void> deleteAccount(String uid) async {
    final refs = <DocumentReference<Map<String, dynamic>>>[];

    // 1. Delete user's clips
    final clipsSnap = await _db
        .collection(AppPaths.clips)
        .where('playerId', isEqualTo: uid)
        .get();
    for (final doc in clipsSnap.docs) {
      refs.add(doc.reference);
    }

    // 2. Delete user's likes
    final likesSnap = await _db
        .collection(AppPaths.likes)
        .where('uid', isEqualTo: uid)
        .get();
    for (final doc in likesSnap.docs) {
      refs.add(doc.reference);
    }

    // 3. Delete user's comments
    final commentsSnap = await _db
        .collection(AppPaths.clipComments)
        .where('uid', isEqualTo: uid)
        .get();
    for (final doc in commentsSnap.docs) {
      refs.add(doc.reference);
    }

    // 4. Delete user's saved clips
    final savedSnap = await _db
        .collection(AppPaths.savedClips)
        .where('uid', isEqualTo: uid)
        .get();
    for (final doc in savedSnap.docs) {
      refs.add(doc.reference);
    }

    // 5. Delete user's follow relations
    final followingSnap = await _db
        .collection(AppPaths.follows)
        .where('followerId', isEqualTo: uid)
        .get();
    for (final doc in followingSnap.docs) {
      refs.add(doc.reference);
    }
    final followersSnap = await _db
        .collection(AppPaths.follows)
        .where('followeeId', isEqualTo: uid)
        .get();
    for (final doc in followersSnap.docs) {
      refs.add(doc.reference);
    }

    // 6. Delete user's trial applications
    final appsSnap = await _db
        .collection(AppPaths.trialApplications)
        .where('playerId', isEqualTo: uid)
        .get();
    for (final doc in appsSnap.docs) {
      refs.add(doc.reference);
    }

    // 7. Delete user's openings (coach)
    final openingsSnap = await _db
        .collection(AppPaths.openings)
        .where('coachId', isEqualTo: uid)
        .get();
    for (final doc in openingsSnap.docs) {
      refs.add(doc.reference);
    }

    // 8. Delete user's notifications
    final notifsSnap = await _db
        .collection('notifications')
        .where('toUserId', isEqualTo: uid)
        .get();
    for (final doc in notifsSnap.docs) {
      refs.add(doc.reference);
    }
    final notifsFromSnap = await _db
        .collection('notifications')
        .where('fromUserId', isEqualTo: uid)
        .get();
    for (final doc in notifsFromSnap.docs) {
      refs.add(doc.reference);
    }

    // 9. Delete user's conversations (where user is a participant)
    final convsSnap = await _db
        .collection(AppPaths.conversations)
        .where('participantIds', arrayContains: uid)
        .get();
    for (final doc in convsSnap.docs) {
      refs.add(doc.reference);
    }

    // 10. Delete user profile doc
    refs.add(_db.collection(AppPaths.users).doc(uid));

    // Firestore batches are capped at 500 writes — commit in safe chunks so
    // deletion never aborts for users with lots of data.
    const chunkSize = 400;
    for (var i = 0; i < refs.length; i += chunkSize) {
      final batch = _db.batch();
      for (final ref in refs.skip(i).take(chunkSize)) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  }

  // -------------------------------------------------------------------------
  // Conversations & messages
  // -------------------------------------------------------------------------

  Future<String> getOrCreateConversation(
    String uidA,
    String uidB,
    Map<String, String> names,
  ) async {
    final key = (uidA.compareTo(uidB) <= 0) ? [uidA, uidB] : [uidB, uidA];
    final snap = await _db
        .collection(AppPaths.conversations)
        .where('participantIds', isEqualTo: key)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) return snap.docs.first.id;

    final doc = await _db.collection(AppPaths.conversations).add({
      'participantIds': key,
      'participantNames': {uidA: names[uidA], uidB: names[uidB]},
      'lastMessage': '',
      'lastMessageAt': DateTime.now(),
    });
    return doc.id;
  }

  Stream<List<Conversation>> streamConversations(String uid) {
    return _db
        .collection(AppPaths.conversations)
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Conversation.fromMap(d.id, d.data()))
              .toList()
            ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt)),
        );
  }

  Stream<List<ChatMessage>> streamMessages(String conversationId) {
    return _db
        .collection(AppPaths.conversations)
        .doc(conversationId)
        .collection(AppPaths.messages)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ChatMessage.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> sendMessage(
    String conversationId, {
    required String senderId,
    required String senderName,
    required String text,
    String? clipId,
    String? clipTitle,
    String? clipVideoUrl,
    String? receiverId,
  }) async {
    final msg = ChatMessage(
      id: '',
      senderId: senderId,
      senderName: senderName,
      text: text,
      clipId: clipId,
      clipTitle: clipTitle,
      clipVideoUrl: clipVideoUrl,
      createdAt: DateTime.now(),
    );
    await _db
        .collection(AppPaths.conversations)
        .doc(conversationId)
        .collection(AppPaths.messages)
        .add(msg.toMap());
    await _db.collection(AppPaths.conversations).doc(conversationId).update({
      'lastMessage': text,
      'lastMessageAt': DateTime.now(),
    });
    if (receiverId != null && receiverId.isNotEmpty) {
      await incrementUnreadCount(conversationId, receiverId);
      await createNotification(
        toUserId: receiverId,
        fromUserId: senderId,
        fromUserName: senderName,
        type: 'message',
        message: text.length > 50 ? '${text.substring(0, 50)}...' : text,
        conversationId: conversationId,
      );
    }
  }

  // === UNREAD MESSAGES ===

  Future<void> incrementUnreadCount(
      String conversationId, String participantId) async {
    await _db.collection(AppPaths.conversations).doc(conversationId).update({
      'unreadCounts.$participantId': FieldValue.increment(1),
    });
  }

  Future<void> resetUnreadCount(
      String conversationId, String participantId) async {
    await _db.collection(AppPaths.conversations).doc(conversationId).update({
      'unreadCounts.$participantId': 0,
    });
  }

  Stream<int> streamTotalUnreadCount(String uid) {
    return _db
        .collection(AppPaths.conversations)
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .map((snap) {
      int total = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final unreadCounts =
            data['unreadCounts'] as Map<String, dynamic>? ?? {};
        total += (unreadCounts[uid] as int?) ?? 0;
      }
      return total;
    });
  }

  int getUnreadCount(Map<String, dynamic>? unreadCounts, String uid) {
    if (unreadCounts == null) return 0;
    return (unreadCounts[uid] as int?) ?? 0;
  }

  // === NOTIFICATIONS ===

  Future<void> createNotification({
    required String toUserId,
    required String fromUserId,
    required String fromUserName,
    required String type,
    String? message,
    String? conversationId,
  }) async {
    await _db.collection('notifications').add({
      'toUserId': toUserId,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'type': type,
      'message': message,
      'conversationId': conversationId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AppNotification>> streamNotifications(String uid) {
    return _db
        .collection('notifications')
        .where('toUserId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => AppNotification.fromMap(d.id, d.data()))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list.take(50).toList();
        });
  }

  Stream<int> streamUnreadNotificationCount(String uid) {
    return _db
        .collection('notifications')
        .where('toUserId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _db
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsRead(String uid) async {
    final batch = _db.batch();
    final snap = await _db
        .collection('notifications')
        .where('toUserId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // === CLIP SEARCH ===

  Stream<List<Clip>> streamClipsForSearch({int limit = 150}) {
    return _db
        .collection(AppPaths.clips)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => Clip.fromMap(d.id, d.data())).toList(),
        );
  }

  // === USER SEARCH ===

  Stream<List<UserProfile>> searchUsers(String query) {
    if (query.trim().isEmpty) return Stream.value([]);
    final q = query.trim().toLowerCase();
    return _db.collection(AppPaths.users).snapshots().map((snap) {
      return snap.docs
          .map((d) => UserProfile.fromMap(d.id, d.data()))
          .where((p) => p.displayName.toLowerCase().contains(q))
          .toList();
    });
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String? clipId;
  final String? clipTitle;
  final String? clipVideoUrl;
  final DateTime createdAt;
  final List<String>? reactions; // List of emoji reactions (e.g., ['👍', '❤️', '🎥'])

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.clipId,
    this.clipTitle,
    this.clipVideoUrl,
    required this.createdAt,
    this.reactions,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'clipId': clipId,
      'clipTitle': clipTitle,
      'clipVideoUrl': clipVideoUrl,
      'createdAt': createdAt,
    };
    if (reactions != null && reactions!.isNotEmpty) {
      map['reactions'] = reactions;
    }
    return map;
  }

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      text: map['text'] as String? ?? '',
      clipId: map['clipId'] as String?,
      clipTitle: map['clipTitle'] as String?,
      clipVideoUrl: map['clipVideoUrl'] as String?,
      createdAt: _toDateTime(map['createdAt']) ?? DateTime.now(),
      reactions: (map['reactions'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

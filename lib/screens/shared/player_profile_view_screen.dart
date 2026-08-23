import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/clip.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/cloudinary_service.dart';
import '../../services/database.dart';
import '../../widgets/ai/scouting_report_sheet.dart';
import '../messaging/chat_screen.dart';
import 'clip_player_screen.dart';
import 'widgets.dart';

class PlayerProfileViewScreen extends StatefulWidget {
  final String playerId;

  const PlayerProfileViewScreen({super.key, required this.playerId});

  @override
  State<PlayerProfileViewScreen> createState() =>
      _PlayerProfileViewScreenState();
}

class _PlayerProfileViewScreenState extends State<PlayerProfileViewScreen> {
  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = context.read<Database>().getUserProfile(widget.playerId);
  }

  Future<void> _openChat(UserProfile me, UserProfile player) async {
    final db = context.read<Database>();
    final convId = await db.getOrCreateConversation(
      me.uid,
      player.uid,
      {me.uid: me.displayName, player.uid: player.displayName},
    );
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: convId,
          otherId: player.uid,
          otherName: player.displayName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Profile')),
      body: FutureBuilder<UserProfile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface),
            );
          }
          final player = snapshot.data;
          if (player == null) {
            return EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Player not found',
              animate: false,
            );
          }
          final me = context.watch<AuthProvider>().profile;
          final showMessage = me != null && me.uid != player.uid;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // Hero header
              _ProfileHero(player: player, me: me, showMessage: showMessage, onMessage: showMessage ? () => _openChat(me, player) : null),

              // Stats
              _StatsBar(player: player),

              // Info
              _InfoSection(player: player),

              // Clips
              _ClipsSection(playerId: player.uid),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final UserProfile player;
  final UserProfile? me;
  final bool showMessage;
  final VoidCallback? onMessage;

  const _ProfileHero({
    required this.player,
    this.me,
    required this.showMessage,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isSelf = me?.uid == player.uid;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.onSurface,
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
              ),
              child: CircleAvatar(
                radius: 44,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                backgroundImage: (player.profileImageUrl != null && player.profileImageUrl!.isNotEmpty)
                    ? NetworkImage(player.profileImageUrl!)
                    : null,
                child: (player.profileImageUrl == null || player.profileImageUrl!.isEmpty)
                    ? InitialsAvatar(name: player.displayName, radius: 44)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  player.displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (player.clipCount >= 3) ...[
                const SizedBox(width: 6),
                const VerifiedBadge(size: 20, animate: true),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (player.sport != null) ...[
                Icon(Icons.sports_soccer, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  player.sport!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (player.position != null)
                Text(
                  ' Â· ${player.position!}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          if (player.city != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  player.city!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if (player.bio != null && player.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              player.bio!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (!isSelf && me != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _FollowButton(playerId: player.uid)),
                if (showMessage) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onMessage,
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Message'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => ScoutingReportSheet.show(context, player),
              icon: const Icon(Icons.psychology, size: 18),
              label: const Text('AI Scouting Report'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                foregroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  final UserProfile player;

  const _StatsBar({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat(value: '${player.clipCount < 0 ? 0 : player.clipCount}', label: 'Clips', color: Theme.of(context).colorScheme.onSurface),
          Container(width: 1, height: 32, color: Theme.of(context).colorScheme.outlineVariant),
          _Stat(value: _compact(player.followerCount), label: 'Followers', color: Theme.of(context).colorScheme.onSurface),
          Container(width: 1, height: 32, color: Theme.of(context).colorScheme.outlineVariant),
          _Stat(value: '${player.followingCount}', label: 'Following', color: Theme.of(context).colorScheme.onSurface),
        ],
      ),
    );
  }

  String _compact(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _Stat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final UserProfile player;

  const _InfoSection({required this.player});

  @override
  Widget build(BuildContext context) {
    final items = <_InfoItem>[
      if (player.sport != null) _InfoItem(icon: Icons.sports_soccer, label: 'Sport', value: player.sport!),
      if (player.position != null) _InfoItem(icon: Icons.sports_football, label: 'Position', value: player.position!),
      if (player.heightCm != null) _InfoItem(icon: Icons.height, label: 'Height', value: '${player.heightCm} cm'),
      if (player.weightKg != null) _InfoItem(icon: Icons.monitor_weight_outlined, label: 'Weight', value: '${player.weightKg} kg'),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 16, decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text('Athletic Info', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((item) => SizedBox(
              width: (MediaQuery.of(context).size.width - 52) / 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(item.icon, size: 18, color: Theme.of(context).colorScheme.onSurface),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          Text(item.value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({required this.icon, required this.label, required this.value});
}

class _ClipsSection extends StatelessWidget {
  final String playerId;

  const _ClipsSection({required this.playerId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 16, decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text('Highlights', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Clip>>(
            stream: context.read<Database>().streamClipsForPlayer(playerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface));
              }
              final clips = snapshot.data ?? [];
              if (clips.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.videocam_off_outlined, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text('No highlights yet', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        'This player hasn\'t shared any highlights.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              final screenWidth = MediaQuery.of(context).size.width;
              final isWide = screenWidth > 700;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 4 : 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: isWide ? 1.0 : 0.62,
                ),
                itemCount: clips.length,
                itemBuilder: (context, index) {
                  final clip = clips[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ClipPlayerScreen(videoUrl: clip.videoUrl, title: clip.title),
                        ),
                      );
                    },
                    child: _ProfileClipTile(clip: clip),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatefulWidget {
  final String playerId;

  const _FollowButton({required this.playerId});

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _following = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkFollowing();
  }

  Future<void> _checkFollowing() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    final following = await context.read<Database>().streamFollowingIds(uid).first;
    if (mounted) setState(() => _following = following.contains(widget.playerId));
  }

  Future<void> _toggleFollow() async {
    setState(() => _loading = true);
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final db = context.read<Database>();
    final auth = context.read<AuthProvider>();
    if (_following) {
      await db.unfollow(uid, widget.playerId);
    } else {
      await db.follow(uid, widget.playerId);
      final profile = await db.getUserProfile(uid);
      if (profile != null) {
        await db.createNotification(
          toUserId: widget.playerId,
          fromUserId: uid,
          fromUserName: profile.displayName,
          type: 'follow',
        );
      }
    }
    // Refresh the local profile so followingCount stays in sync
    await auth.refreshProfile();
    if (mounted) {
      setState(() {
        _following = !_following;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: 48,
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onSurface))),
      );
    }
    return _following
        ? OutlinedButton.icon(
            onPressed: _toggleFollow,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Following'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        : FilledButton.icon(
            onPressed: _toggleFollow,
            icon: const Icon(Icons.person_add_outlined, size: 18),
            label: const Text('Follow'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
  }
}

class _ProfileClipTile extends StatelessWidget {
  final Clip clip;
  const _ProfileClipTile({required this.clip});

  static const Map<String, List<Color>> _sportGradients = {
    'Football': [Color(0xFF1B5E20), Color(0xFF43A047)],
    'Soccer': [Color(0xFF1B5E20), Color(0xFF43A047)],
    'Basketball': [Color(0xFFE65100), Color(0xFFFF9800)],
    'Cricket': [Color(0xFF0D47A1), Color(0xFF42A5F5)],
    'Tennis': [Color(0xFF827717), Color(0xFFCDDC39)],
    'Rugby': [Color(0xFF4A148C), Color(0xFFAB47BC)],
    'Athletics': [Color(0xFFB71C1C), Color(0xFFEF5350)],
    'Swimming': [Color(0xFF006064), Color(0xFF26C6DA)],
    'Baseball': [Color(0xFF1A237E), Color(0xFF5C6BC0)],
    'Volleyball': [Color(0xFF33691E), Color(0xFF8BC34A)],
  };

  List<Color> _gradientFor(BuildContext context) {
    final key = _sportGradients.keys.firstWhere(
      (k) => k.toLowerCase() == clip.sport.toLowerCase(),
      orElse: () => '',
    );
    return key.isNotEmpty ? _sportGradients[key]! : [DSColors.voltDark, DSColors.voltLight];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _gradientFor(context);
    final thumbnail = CloudinaryService.videoThumbnail(
      clip.videoUrl,
      width: 320,
      height: 320,
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (thumbnail != null)
            Image.network(
              thumbnail,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, size: 24, color: Colors.white),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                ),
              ),
              child: Text(
                clip.title.isEmpty ? 'Highlight' : clip.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${clip.viewCount}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/clip.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/cloudinary_service.dart';
import '../../services/database.dart';
import '../../widgets/sport_icons.dart';
import '../shared/edit_profile_screen.dart';
import '../shared/saved_clips_screen.dart';
import '../shared/widgets.dart';
import '../shared/reels_feed.dart';
import '../shared/player_profile_view_screen.dart';

class MyProfileScreen extends StatelessWidget {
  final UserProfile profile;

  const MyProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final current = auth.profile ?? profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  size: 22,
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: themeProvider.isDark ? 'Switch to light mode' : 'Switch to dark mode',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Hero profile header
          _ProfileHeader(profile: current),

          // Stats
          _StatsRow(profile: current),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(profile: current),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SavedClipsScreen()),
                      );
                    },
                    icon: const Icon(Icons.bookmark_outline, size: 18),
                    label: const Text('Saved'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // About section
          if (current.bio != null && current.bio!.isNotEmpty)
            _SectionBlock(
              title: 'About',
              child: Text(
                current.bio!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

          // Athletic info
          _SectionBlock(
            title: 'Athletic Information',
            child: _InfoGrid(profile: current),
          ),

          // Your Highlights
          _SectionBlock(
            title: 'Your Highlights',
            child: const _YourReelsGrid(),
          ),

          // Sign out + Delete account (responsive)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            await context.read<AuthProvider>().signOut();
                            if (context.mounted) {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Sign out failed: $e')),
                              );
                            }
                          }
                        },
                        icon: Icon(Icons.logout, size: 18, color: Theme.of(context).colorScheme.error),
                        label: Text('Sign Out', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).colorScheme.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmDeleteAccount(context),
                        icon: Icon(Icons.delete_forever_outlined, size: 18, color: Theme.of(context).colorScheme.error),
                        label: Text('Delete Account', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).colorScheme.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmDeleteAccount(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Account'),
      content: const Text(
        'This will permanently delete your account and all data (clips, messages, follows, saved items). This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ],
    ),
  );
  if (confirm != true || !context.mounted) return;
  try {
    await context.read<AuthProvider>().deleteAccount();
  } catch (_) {}
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        children: [
          // Avatar
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
                backgroundImage: (profile.profileImageUrl != null && profile.profileImageUrl!.isNotEmpty)
                    ? NetworkImage(profile.profileImageUrl!)
                    : null,
                child: (profile.profileImageUrl == null || profile.profileImageUrl!.isEmpty)
                    ? InitialsAvatar(name: profile.displayName, radius: 44)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name + verified
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (profile.clipCount >= 3) ...[
                const SizedBox(width: 6),
                const VerifiedBadge(size: 20, animate: true),
              ],
            ],
          ),

          // Username
          if (profile.username != null && profile.username!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '@${profile.username}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),

          // Sport + position with proper icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (profile.sport != null) ...[
                Icon(SportIcons.getSportIcon(profile.sport), size: 16, color: SportIcons.getSportColor(profile.sport)),
                const SizedBox(width: 4),
                Text(
                  profile.sport!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (profile.position != null) ...[
                const SizedBox(width: 8),
                Icon(PositionIcons.getPositionIcon(profile.position), size: 16, color: PositionIcons.getPositionColor(profile.position)),
                const SizedBox(width: 4),
                Text(
                  profile.position!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          if (profile.city != null && profile.city!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  profile.city!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if (profile.ageGroup != null && profile.ageGroup!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cake_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  profile.ageGroup!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],

          // Role badge
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              profile.role.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final UserProfile profile;

  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            value: '${profile.clipCount < 0 ? 0 : profile.clipCount}',
            label: 'Clips',
            color: Theme.of(context).colorScheme.onSurface,
          ),
          Container(width: 1, height: 32, color: Theme.of(context).colorScheme.outlineVariant),
          _StatItem(
            value: _compact(profile.followerCount),
            label: 'Followers',
            color: Theme.of(context).colorScheme.onSurface,
          ),
          Container(width: 1, height: 32, color: Theme.of(context).colorScheme.outlineVariant),
          _StatItem(
            value: '${profile.followingCount}',
            label: 'Following',
            color: Theme.of(context).colorScheme.onSurface,
          ),
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

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionBlock({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final UserProfile profile;

  const _InfoGrid({required this.profile});

  @override
  Widget build(BuildContext context) {
    final items = <_InfoItem>[
      if (profile.sport != null)
        _InfoItem(icon: SportIcons.getSportIcon(profile.sport), label: 'Sport', value: profile.sport!),
      if (profile.position != null)
        _InfoItem(icon: PositionIcons.getPositionIcon(profile.position), label: 'Position', value: profile.position!),
      if (profile.ageGroup != null && profile.ageGroup!.isNotEmpty)
        _InfoItem(icon: Icons.cake_outlined, label: 'Age Group', value: profile.ageGroup!),
      if (profile.heightCm != null)
        _InfoItem(icon: Icons.height, label: 'Height', value: '${profile.heightCm} cm'),
      if (profile.weightKg != null)
        _InfoItem(icon: Icons.monitor_weight_outlined, label: 'Weight', value: '${profile.weightKg} kg'),
      if (profile.city != null && profile.city!.isNotEmpty)
        _InfoItem(icon: Icons.location_on_outlined, label: 'Location', value: profile.city!),
      if (profile.contactEmail != null && profile.contactEmail!.isNotEmpty)
        _InfoItem(icon: Icons.email_outlined, label: 'Email', value: profile.contactEmail!),
      if (profile.phone != null && profile.phone!.isNotEmpty)
        _InfoItem(icon: Icons.phone_outlined, label: 'Phone', value: profile.phone!),
    ];

    if (items.isEmpty) {
      return Text(
        'No athletic information added yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Wrap(
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
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      item.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _YourReelsGrid extends StatelessWidget {
  const _YourReelsGrid();

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return const SizedBox.shrink();
    final db = context.read<Database>();

    return StreamBuilder<List<Clip>>(
      stream: db.streamClipsForPlayer(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface),
            ),
          );
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
                Icon(
                  Icons.videocam_off_outlined,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'No highlights yet',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload your first highlight to get discovered.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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
                    builder: (_) => ReelsFeed(
                      clipsStream: Stream.value(clips),
                      initialIndex: index,
                      onDelete: (deletedClip) async {
                        await db.deleteClip(deletedClip.id);
                      },
                      onOpenProfile: (c) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PlayerProfileViewScreen(playerId: c.playerId),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadius.sheet)),
                  ),
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 4,
                          margin: EdgeInsets.symmetric(vertical: DSSpacing.md),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(DSRadius.full),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                          title: Text('Delete highlight', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          onTap: () async {
                            Navigator.pop(ctx);
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: Text('Delete clip?'),
                                content: Text('This permanently removes the highlight.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text('Cancel')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx, true),
                                    style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await db.deleteClip(clip.id);
                            }
                          },
                        ),
                        SizedBox(height: DSSpacing.md),
                      ],
                    ),
                  ),
                );
              },
              child: _ReelTile(clip: clip),
            );
          },
        );
      },
    );
  }
}

class _ReelTile extends StatelessWidget {
  final Clip clip;

  const _ReelTile({required this.clip});

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

  List<Color> _gradient(BuildContext context) {
    final key = _sportGradients.keys.firstWhere(
      (k) => k.toLowerCase() == clip.sport.toLowerCase(),
      orElse: () => '',
    );
    if (key.isNotEmpty) return _sportGradients[key]!;
    return [
      Theme.of(context).colorScheme.surfaceContainerHighest,
      Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _gradient(context);
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Text(
                clip.title.isEmpty ? 'Highlight' : clip.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
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

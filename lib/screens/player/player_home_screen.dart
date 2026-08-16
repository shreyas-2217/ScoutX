import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';
import 'package:provider/provider.dart';

import '../../models/clip.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../shared/widgets.dart';
import '../shared/reels_feed.dart';
import '../shared/search_screen.dart';
import '../shared/player_profile_view_screen.dart';
import '../../core/tab_switcher.dart';
import 'upload_clip_screen.dart';

class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    final uid = auth.user?.uid;
    final db = context.read<Database>();
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final name = profile?.displayName.split(' ').first ?? 'Athlete';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium app bar
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 0,
            title: BrandLogo(markSize: 28, fontSize: 20, animate: false),
          ),

          // Greeting + Search
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, $name',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover opportunities built for your game.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IgnorePointer(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search athletes, coaches, highlights...',
                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            prefixIcon: Icon(Icons.search, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _QuickAction(
                    icon: Icons.videocam_outlined,
                    label: 'Upload Clip',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const UploadClipScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    icon: Icons.emoji_events_outlined,
                    label: 'Find Trials',
                    onTap: () {
                      context.read<TabSwitcher>().switchTo(1);
                    },
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    icon: Icons.explore_outlined,
                    label: 'Discover',
                    onTap: () {
                      context.read<TabSwitcher>().switchTo(1);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Section: Discover Talents
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: DSColors.volt,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Discover Talents',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Other players' clips feed
          SliverToBoxAdapter(
            child: SizedBox(
              height: 320,
              child: StreamBuilder<List<Clip>>(
                stream: db.streamClips(limit: 30),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: DSColors.volt));
                  }
                  final allClips = snapshot.data ?? [];
                  final otherClips = allClips.where((c) => c.playerId != uid).toList();
                  if (otherClips.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text(
                              'No highlights yet',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Check back later for athlete highlights.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: otherClips.length,
                    itemBuilder: (context, index) {
                      final clip = otherClips[index];
                      return Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReelsFeed(
                                  clipsStream: Stream.value(otherClips),
                                  initialIndex: index,
                                  onOpenProfile: (c) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PlayerProfileViewScreen(
                                          playerId: c.playerId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          child: _HighlightCard(clip: clip),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Section: Featured Athletes
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: DSColors.cyan,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Trending Athletes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Featured athletes horizontal list
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: StreamBuilder(
                stream: db.streamClips(limit: 10),
                builder: (context, snapshot) {
                  final clips = snapshot.data ?? [];
                  final uniquePlayers = <String, dynamic>{};
                  for (final c in clips) {
                    uniquePlayers.putIfAbsent(c.playerId, () => c);
                  }
                  final players = uniquePlayers.values.toList();
                  if (players.isEmpty) {
                    return Center(
                      child: Text(
                        'No athletes to show yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final clip = players[index];
                      return Container(
                        width: 130,
                        margin: const EdgeInsets.only(right: 12),
                        child: _AthleteMiniCard(
                          name: clip.playerName,
                          sport: clip.sport,
                          position: clip.position,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Section: All Highlights (full reels feed)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: DSColors.amber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'All Highlights',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Full reels feed
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ReelsFeed(
                clipsStream: db.streamClips(),
                onDelete: (clip) => db.deleteClip(clip.id),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Material(
        color: Colors.transparent,
        elevation: 0,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UploadClipScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: DSColors.volt,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: DSColors.volt.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam_outlined, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Upload',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: DSColors.volt),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final dynamic clip;

  const _HighlightCard({required this.clip});

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

  List<Color> get _gradient {
    final key = _sportGradients.keys.firstWhere(
      (k) => k.toLowerCase() == clip.sport.toLowerCase(),
      orElse: () => '',
    );
    return key.isNotEmpty ? _sportGradients[key]! : [DSColors.voltDark, DSColors.voltLight];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _gradient,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        clip.sport,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.visibility, size: 10, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            _formatCount(clip.viewCount),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded, size: 28, color: Colors.black87),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      clip.playerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clip.title.isEmpty ? 'Highlight' : clip.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${clip.sport} · ${clip.viewCount} views',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _AthleteMiniCard extends StatelessWidget {
  final String name;
  final String? sport;
  final String? position;

  const _AthleteMiniCard({
    required this.name,
    this.sport,
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InitialsAvatar(name: name, radius: 24),
          const SizedBox(height: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            [sport, position].where((e) => e != null).join(' · '),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

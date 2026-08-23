import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../coach/coach_discover_screen.dart';
import '../coach/coach_openings_screen.dart';
import '../coach/coach_trials_screen.dart';
import '../player/player_highlights_screen.dart';
import '../shared/my_profile_screen.dart';
import '../shared/saved_clips_screen.dart';
import '../shared/widgets.dart' show AnimatedShellContent;
import '../messaging/responsive_messaging.dart';
import 'app_shell.dart';

class CoachShell extends StatefulWidget {
  final UserProfile profile;

  const CoachShell({super.key, required this.profile});

  @override
  State<CoachShell> createState() => _CoachShellState();
}

class _CoachShellState extends State<CoachShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const CoachDiscoverScreen(),
      const PlayerHighlightsScreen(),
      const CoachOpeningsScreen(),
      const CoachTrialsScreen(),
      const SavedClipsScreen(),
      const ResponsiveMessaging(),
      MyProfileScreen(profile: widget.profile),
    ];

    final uid = context.watch<AuthProvider>().user?.uid ?? '';
    final db = context.read<Database>();

    final navItems = [
      const AppNavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Discover'),
      const AppNavItem(icon: Icons.play_circle_outline, activeIcon: Icons.play_circle, label: 'Highlights'),
      const AppNavItem(icon: Icons.campaign_outlined, activeIcon: Icons.campaign, label: 'Openings'),
      const AppNavItem(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events, label: 'Trials'),
      const AppNavItem(icon: Icons.bookmark_outline, activeIcon: Icons.bookmark, label: 'Saved'),
      AppNavItem(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: 'Messages',
        trailing: _UnreadBadge(uid: uid, db: db),
      ),
      const AppNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
    ];

    return AppShell(
      currentIndex: _index,
      onIndexChanged: (i) => setState(() => _index = i),
      navItems: navItems,
      child: AnimatedShellContent(
        screens: screens,
        currentIndex: _index,
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final String uid;
  final Database db;
  const _UnreadBadge({required this.uid, required this.db});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: db.streamTotalUnreadCount(uid),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        if (count == 0) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
          decoration: const BoxDecoration(
            color: DSColors.red,
            shape: BoxShape.circle,
          ),
          child: Text(
            count > 99 ? '99+' : '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

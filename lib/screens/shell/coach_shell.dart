import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../coach/coach_discover_screen.dart';
import '../coach/coach_openings_screen.dart';
import '../coach/coach_trials_screen.dart';
import '../player/player_highlights_screen.dart';
import '../shared/my_profile_screen.dart';
import '../shared/saved_clips_screen.dart';
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

    final navItems = [
      const AppNavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Discover'),
      const AppNavItem(icon: Icons.play_circle_outline, activeIcon: Icons.play_circle, label: 'Highlights'),
      const AppNavItem(icon: Icons.campaign_outlined, activeIcon: Icons.campaign, label: 'Openings'),
      const AppNavItem(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events, label: 'Trials'),
      const AppNavItem(icon: Icons.bookmark_outline, activeIcon: Icons.bookmark, label: 'Saved'),
      const AppNavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Messages'),
      const AppNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
    ];

    return AppShell(
      currentIndex: _index,
      onIndexChanged: (i) => setState(() => _index = i),
      navItems: navItems,
      child: screens[_index],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/tab_switcher.dart';
import '../../models/user_profile.dart';
import '../player/player_home_screen.dart';
import '../player/player_highlights_screen.dart';
import '../player/player_trials_screen.dart';
import '../shared/my_profile_screen.dart';
import '../shared/saved_clips_screen.dart';
import '../messaging/responsive_messaging.dart';
import 'app_shell.dart';

class PlayerShell extends StatefulWidget {
  final UserProfile profile;

  const PlayerShell({super.key, required this.profile});

  @override
  State<PlayerShell> createState() => _PlayerShellState();
}

class _PlayerShellState extends State<PlayerShell> {
  final _tabSwitcher = TabSwitcher();

  @override
  void dispose() {
    _tabSwitcher.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const PlayerHomeScreen(),
      const PlayerHighlightsScreen(),
      const PlayerTrialsScreen(),
      const SavedClipsScreen(),
      const ResponsiveMessaging(),
      MyProfileScreen(profile: widget.profile),
    ];

    final navItems = [
      const AppNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      const AppNavItem(icon: Icons.play_circle_outline, activeIcon: Icons.play_circle, label: 'Highlights'),
      const AppNavItem(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events, label: 'Trials'),
      const AppNavItem(icon: Icons.bookmark_outline, activeIcon: Icons.bookmark, label: 'Saved'),
      const AppNavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Messages'),
      const AppNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
    ];

    return ListenableBuilder(
      listenable: _tabSwitcher,
      builder: (context, _) {
        return Provider<TabSwitcher>.value(
          value: _tabSwitcher,
          child: AppShell(
            currentIndex: _tabSwitcher.currentIndex,
            onIndexChanged: (i) => _tabSwitcher.switchTo(i),
            navItems: navItems,
            child: screens[_tabSwitcher.currentIndex],
          ),
        );
      },
    );
  }
}

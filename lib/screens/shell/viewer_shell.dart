import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../viewer/reels_screen.dart';
import '../shared/my_profile_screen.dart';
import '../shared/saved_clips_screen.dart';
import '../messaging/responsive_messaging.dart';
import 'app_shell.dart';

class ViewerShell extends StatefulWidget {
  final UserProfile profile;

  const ViewerShell({super.key, required this.profile});

  @override
  State<ViewerShell> createState() => _ViewerShellState();
}

class _ViewerShellState extends State<ViewerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const ReelsScreen(),
      const SavedClipsScreen(),
      const ResponsiveMessaging(),
      MyProfileScreen(profile: widget.profile),
    ];

    final navItems = [
      const AppNavItem(icon: Icons.play_circle_outline, activeIcon: Icons.play_circle, label: 'Reels'),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../viewer/reels_screen.dart';
import '../shared/my_profile_screen.dart';
import '../shared/saved_clips_screen.dart';
import '../shared/widgets.dart' show AnimatedShellContent;
import '../messaging/responsive_messaging.dart';
import '../messaging/notifications_screen.dart';
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
      const NotificationsScreen(),
      const ResponsiveMessaging(),
      MyProfileScreen(profile: widget.profile),
    ];

    final uid = context.watch<AuthProvider>().user?.uid ?? '';
    final db = context.read<Database>();

    final navItems = [
      const AppNavItem(icon: Icons.play_circle_outline, activeIcon: Icons.play_circle, label: 'Reels'),
      const AppNavItem(icon: Icons.bookmark_outline, activeIcon: Icons.bookmark, label: 'Saved'),
      AppNavItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        label: 'Alerts',
        trailing: uid.isEmpty
            ? null
            : ShellCountBadge(stream: db.streamUnreadNotificationCount(uid)),
      ),
      AppNavItem(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: 'Messages',
        trailing: uid.isEmpty
            ? null
            : ShellCountBadge(stream: db.streamTotalUnreadCount(uid)),
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

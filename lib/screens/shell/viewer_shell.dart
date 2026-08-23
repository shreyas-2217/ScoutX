import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../viewer/reels_screen.dart';
import '../shared/my_profile_screen.dart';
import '../shared/saved_clips_screen.dart';
import '../shared/widgets.dart' show AnimatedShellContent;
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

    final uid = context.watch<AuthProvider>().user?.uid ?? '';
    final db = context.read<Database>();

    final navItems = [
      const AppNavItem(icon: Icons.play_circle_outline, activeIcon: Icons.play_circle, label: 'Reels'),
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

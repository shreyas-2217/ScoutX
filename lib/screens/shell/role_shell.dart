import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import 'coach_shell.dart';
import 'player_shell.dart';
import 'viewer_shell.dart';

/// Chooses the correct bottom-nav shell based on the user's role.
class RoleShell extends StatelessWidget {
  final UserProfile profile;

  const RoleShell({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    switch (profile.role) {
      case 'player':
        return PlayerShell(profile: profile);
      case 'coach':
        return CoachShell(profile: profile);
      default:
        return ViewerShell(profile: profile);
    }
  }
}

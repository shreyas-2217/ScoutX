import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/database.dart';
import '../shared/reels_feed.dart';
import '../shared/player_profile_view_screen.dart';

class PlayerHighlightsScreen extends StatelessWidget {
  const PlayerHighlightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<Database>();

    return ReelsFeed(
      clipsStream: db.streamClips(),
      onOpenProfile: (clip) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlayerProfileViewScreen(playerId: clip.playerId),
          ),
        );
      },
    );
  }
}

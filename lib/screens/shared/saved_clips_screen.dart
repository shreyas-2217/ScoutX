import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';
import 'package:provider/provider.dart';

import '../../models/saved_clip.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import 'clip_player_screen.dart';
import 'widgets.dart';

/// Grid of the current user's saved clips.
class SavedClipsScreen extends StatelessWidget {
  const SavedClipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Clips')),
      body: uid == null
          ? const SizedBox.shrink()
          : AnimatedPage(
              child: StreamBuilder<List<SavedClip>>(
                stream: context.read<Database>().streamSavedClips(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: DSColors.volt),
                          SizedBox(height: DSSpacing.md),
                          Text(
                            'Loading saved clips...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: DSColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final saved = snapshot.data ?? [];
                  if (saved.isEmpty) {
                    return EmptyState(
                      icon: DSIcons.bookmark,
                      title: 'No saved clips',
                      subtitle: 'Tap the bookmark on a reel to save it here.',
                    );
                  }
                  return GridView.builder(
                    padding: EdgeInsets.all(DSSpacing.md),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: DSSpacing.sm,
                      crossAxisSpacing: DSSpacing.sm,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: saved.length,
                    itemBuilder: (context, index) {
                      final s = saved[index];
                      return StaggeredItem(
                        index: index,
                        delay: DSMotion.listItemStagger * index,
                        duration: DSMotion.fast,
                        child: _SavedTile(saved: s),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _SavedTile extends StatelessWidget {
  final SavedClip saved;

  const _SavedTile({required this.saved});

  @override
  Widget build(BuildContext context) {
    return DSCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClipPlayerScreen(
              videoUrl: saved.videoUrl,
              title: saved.title.isEmpty ? 'Saved clip' : saved.title,
            ),
          ),
        );
      },
      padding: EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: DSColors.volt.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  DSIcons.playCircle,
                  size: 36,
                  color: DSColors.volt,
                ),
              ),
            ),
          ),
          SizedBox(height: DSSpacing.sm),
          Text(
            saved.title.isEmpty ? 'Highlight' : saved.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: DSSpacing.xs),
          Text(
            '${saved.sport} · ${saved.position}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: DSColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2),
          Text(
            saved.playerName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: DSColors.onSurfaceDisabled,
            ),
          ),
        ],
      ),
    );
  }
}



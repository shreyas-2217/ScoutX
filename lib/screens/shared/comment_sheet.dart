import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/clip_comment.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import 'widgets.dart';

/// Instagram-style bottom sheet listing a clip's comments with a reply bar.
class CommentSheet extends StatefulWidget {
  final String clipId;

  const CommentSheet({super.key, required this.clipId});

  @override
  State<CommentSheet> createState() => _CommentSheetState();

  static Future<void> show(BuildContext context, String clipId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadius.sheet)),
      ),
      builder: (_) => CommentSheet(clipId: clipId),
    );
  }
}

class _CommentSheetState extends State<CommentSheet>
    with SingleTickerProviderStateMixin {
  final _input = TextEditingController();
  bool _sending = false;
  late final AnimationController _controller;
  late final Animation<double> _opacityAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.normal,
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: DSMotion.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _input.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final auth = context.read<AuthProvider>();
    final db = context.read<Database>();
    final user = auth.user;
    final me = auth.profile;
    if (user == null || me == null) return;
    setState(() => _sending = true);
    await db.addComment(
      ClipComment(
        id: '',
        clipId: widget.clipId,
        uid: user.uid,
        name: me.displayName,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
    // Notify clip owner (skip self-comments)
    try {
      final clip = await db.getClip(widget.clipId);
      if (clip != null && clip.playerId != user.uid) {
        await db.createNotification(
          toUserId: clip.playerId,
          fromUserId: user.uid,
          fromUserName: me.displayName,
          type: 'comment',
          message: text.length > 50 ? '${text.substring(0, 50)}...' : text,
        );
      }
    } catch (_) {}
    _input.clear();
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _delete(ClipComment comment) async {
    await context.read<Database>().deleteComment(comment.id, widget.clipId);
  }

  @override
  Widget build(BuildContext context) {
    final myUid = context.watch<AuthProvider>().user?.uid;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.translate(
            offset: _slideAnim.value * 50,
            child: child,
          ),
        );
      },
      child: AnimatedPadding(
        duration: DSMotion.normal,
        curve: DSMotion.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: DSSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(DSRadius.full),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DSSpacing.lg),
                child: Row(
                  children: [
                    Text(
                      'Comments',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(DSIcons.x, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
              // Comments list
              Expanded(
                child: StreamBuilder<List<ClipComment>>(
                  stream: context.read<Database>().streamComments(widget.clipId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface),
                            SizedBox(height: DSSpacing.md),
                            Text(
                              'Loading comments...',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final comments = snapshot.data ?? [];
                    if (comments.isEmpty) {
                      return EmptyState(
                        icon: DSIcons.chatCircle,
                        title: 'No comments yet',
                        subtitle: 'Be the first to comment.',
                        animate: false,
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: DSSpacing.md,
                        vertical: DSSpacing.sm,
                      ),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final c = comments[index];
                        final isMine = c.uid == myUid;
                        return StaggeredItem(
                          index: index,
                          delay: DSMotion.listItemStagger * index,
                          duration: DSMotion.fast,
                          child: _CommentTile(
                            comment: c,
                            isMine: isMine,
                            onDelete: isMine ? () => _delete(c) : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Input bar
              SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    DSSpacing.md,
                    DSSpacing.sm,
                    DSSpacing.md,
                    DSSpacing.md + MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    border: Border(
                      top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          decoration: InputDecoration(
                            hintText: 'Add a commentâ€¦',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: DSSpacing.md,
                              vertical: DSSpacing.sm,
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                          textInputAction: TextInputAction.send,
                          maxLines: null,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(width: DSSpacing.xs),
                      DSButton(
                        label: '',
                        leadingIcon: DSIcons.send,
                        loading: _sending,
                        variant: DSButtonVariant.filled,
                        padding: EdgeInsets.all(DSSpacing.md),
                        onPressed: _sending ? null : _send,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final ClipComment comment;
  final bool isMine;
  final VoidCallback? onDelete;

  const _CommentTile({
    required this.comment,
    required this.isMine,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DSSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialsAvatar(name: comment.name, radius: 16),
          SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: DSSpacing.sm),
                    Text(
                      timeAgo(comment.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: DSSpacing.xs),
                Text(
                  comment.text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (isMine)
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                DSIcons.trash,
                size: DSIconSize.sm,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
              ),
              tooltip: 'Delete comment',
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size(36, 36),
              ),
            ),
        ],
      ),
    );
  }
}

class StaggeredItem extends StatefulWidget {
  final int index;
  final Duration delay;
  final Duration duration;
  final Widget child;

  const StaggeredItem({
    super.key,
    required this.index,
    required this.delay,
    required this.duration,
    required this.child,
  });

  @override
  State<StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: DSMotion.easeOut));
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.translate(
            offset: _slideAnim.value * 20,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}



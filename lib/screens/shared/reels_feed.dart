import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../models/clip.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import 'package:scoutx/design_system.dart';
import 'comment_sheet.dart';
import 'share_sheet.dart';
import 'widgets.dart';

/// Vertical TikTok/Instagram-style feed of player clips.
class ReelsFeed extends StatefulWidget {
  final Stream<List<Clip>> clipsStream;
  final void Function(Clip clip)? onOpenProfile;
  final void Function(Clip clip)? onDelete;
  final int initialIndex;

  const ReelsFeed({
    super.key,
    required this.clipsStream,
    this.onOpenProfile,
    this.onDelete,
    this.initialIndex = 0,
  });

  @override
  State<ReelsFeed> createState() => _ReelsFeedState();
}

class _ReelsFeedState extends State<ReelsFeed> {
  late final PageController _pageController =
      PageController(initialPage: widget.initialIndex);
  final Set<String> _hidden = {};
  late int _activeIndex;
  List<Clip> _clips = [];

  /// Using ValueNotifiers so ReelItems rebuild independently
  final ValueNotifier<Set<String>> _followingNotifier = ValueNotifier({});
  final ValueNotifier<Set<String>> _savedNotifier = ValueNotifier({});

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialIndex;
    final uid = context.read<AuthProvider>().user?.uid;
    final db = context.read<Database>();
    if (uid == null) return;
    db.streamFollowingIds(uid).listen((s) {
      if (mounted) _followingNotifier.value = Set.from(s);
    });
    db.streamSavedClipIds(uid).listen((s) {
      if (mounted) _savedNotifier.value = Set.from(s);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _followingNotifier.dispose();
    _savedNotifier.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _activeIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Clip>>(
      stream: widget.clipsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return EmptyState(
            icon: DSIcons.warningCircle,
            title: 'Could not load clips',
            animate: false,
          );
        }
        if (snapshot.hasData) {
          final incoming = snapshot.data!;
          final filtered =
              incoming.where((c) => !_hidden.contains(c.id)).toList();
          if (_clips.length != filtered.length ||
              !_listEquals(_clips, filtered)) {
            _clips = filtered;
          }
        }
        if (snapshot.connectionState == ConnectionState.waiting && _clips.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: DSColors.volt),
                SizedBox(height: DSSpacing.md),
                Text(
                  'Loading highlights...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DSColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }
        if (_clips.isEmpty) {
          return EmptyState(
            icon: DSIcons.videoCameraSlash,
            title: 'No clips yet',
            subtitle: 'Players haven\'t uploaded any clips yet.',
            animate: false,
          );
        }
        final activeIndex = _activeIndex.clamp(0, _clips.length - 1);
        return SizedBox.expand(
          child: PageView.builder(
            key: const PageStorageKey<String>('reels_feed'),
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _clips.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return ReelItem(
                key: ValueKey<String>(_clips[index].id),
                clip: _clips[index],
                active: index == activeIndex,
                followingNotifier: _followingNotifier,
                savedNotifier: _savedNotifier,
                onOpenProfile: widget.onOpenProfile,
                onDelete: widget.onDelete,
                onHideClip: (id) => setState(() => _hidden.add(id)),
              );
            },
          ),
        );
      },
    );
  }

  static bool _listEquals(List<Clip> a, List<Clip> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }
}

class ReelItem extends StatefulWidget {
  final Clip clip;
  final bool active;
  final ValueNotifier<Set<String>> followingNotifier;
  final ValueNotifier<Set<String>> savedNotifier;
  final void Function(Clip clip)? onOpenProfile;
  final void Function(Clip clip)? onDelete;
  final void Function(String clipId)? onHideClip;

  const ReelItem({
    super.key,
    required this.clip,
    required this.active,
    required this.followingNotifier,
    required this.savedNotifier,
    this.onOpenProfile,
    this.onDelete,
    this.onHideClip,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem>
    with TickerProviderStateMixin {
  static final Map<String, UserProfile?> _profileCache = {};

  VideoPlayerController? _controller;
  bool _ready = false;
  bool _playing = false;
  bool _liked = false;
  bool _verified = false;
  bool _viewCounted = false;

  late final AnimationController _heartController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  late final AnimationController _likeButtonController = AnimationController(
    vsync: this,
    duration: DSMotion.fast,
  );
  late final AnimationController _followButtonController = AnimationController(
    vsync: this,
    duration: DSMotion.fast,
  );

  @override
  void initState() {
    super.initState();
    _initVideo();
    _checkLiked();
    _loadVerified();
  }

  Future<void> _checkLiked() async {
    final db = context.read<Database>();
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    final liked = await db.hasLiked(widget.clip.id, uid);
    if (mounted && liked) setState(() => _liked = true);
  }

  Future<void> _loadVerified() async {
    final cached = _profileCache[widget.clip.playerId];
    if (cached != null) {
      if (mounted) _verified = cached.clipCount >= 3;
      return;
    }
    final profile =
        await context.read<Database>().getUserProfile(widget.clip.playerId);
    _profileCache[widget.clip.playerId] = profile;
    if (mounted) {
      _verified = (profile?.clipCount ?? 0) >= 3;
    }
  }

  Future<void> _initVideo() async {
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.clip.videoUrl));
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted) return;
      final shouldPlay = widget.active;
      if (shouldPlay) {
        controller.setLooping(true);
        controller.play();
      }
      if (mounted) {
        setState(() {
          _ready = true;
          _playing = shouldPlay;
        });
      }
      if (shouldPlay) _countView();
    } catch (_) {
      // Ignore: video URL may not be playable yet.
    }
  }

  void _countView() {
    if (_viewCounted) return;
    _viewCounted = true;
    context.read<Database>().incrementClipViews(widget.clip.id);
  }

  @override
  void didUpdateWidget(covariant ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      final c = _controller;
      if (c != null && _ready) {
        if (widget.active) {
          c.setLooping(true);
          c.play();
          setState(() => _playing = true);
          _countView();
        } else {
          c.pause();
          setState(() => _playing = false);
        }
      }
    }
  }

  @override
  void deactivate() {
    _controller?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _heartController.dispose();
    _likeButtonController.dispose();
    _followButtonController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !_ready) return;
    if (_playing) {
      c.pause();
    } else {
      c.play();
    }
    setState(() => _playing = !_playing);
  }

  Future<void> _toggleLike() async {
    final auth = context.read<AuthProvider>();
    final db = context.read<Database>();
    final uid = auth.user?.uid;
    if (uid == null) return;

    _likeButtonController.forward().then((_) => _likeButtonController.reverse());

    if (_liked) {
      await db.unlikeClip(widget.clip.id, uid);
    } else {
      await db.likeClip(widget.clip.id, uid);
    }
    if (mounted) setState(() => _liked = !_liked);
  }

  void _onDoubleTap() {
    _heartController.forward(from: 0);
    if (!_liked) {
      _toggleLike();
    }
  }

  Future<void> _toggleSave() async {
    final uid = context.read<AuthProvider>().user?.uid;
    final db = context.read<Database>();
    if (uid == null) return;
    final isSaved = widget.savedNotifier.value.contains(widget.clip.id);
    if (isSaved) {
      await db.unsaveClip(uid, widget.clip.id);
    } else {
      await db.saveClip(uid, widget.clip);
    }
  }

  Future<void> _toggleFollow() async {
    final uid = context.read<AuthProvider>().user?.uid;
    final db = context.read<Database>();
    if (uid == null) return;

    _followButtonController.forward().then((_) => _followButtonController.reverse());

    final isFollowing = widget.followingNotifier.value.contains(widget.clip.playerId);
    if (isFollowing) {
      await db.unfollow(uid, widget.clip.playerId);
    } else {
      await db.follow(uid, widget.clip.playerId);
    }
  }

  void _openMore() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: DSColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadius.sheet)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: DSSpacing.md),
              decoration: BoxDecoration(
                color: DSColors.outlineVariant,
                borderRadius: BorderRadius.circular(DSRadius.full),
              ),
            ),
            _SheetAction(
              icon: DSIcons.report,
              label: 'Report',
              onTap: () {
                Navigator.pop(ctx);
                _reportClip();
              },
            ),
            _SheetAction(
              icon: DSIcons.copyLink,
              label: 'Copy link',
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(text: ShareSheet.linkFor(widget.clip)),
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('Link copied'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DSRadius.md),
                      ),
                    ),
                  );
                }
              },
            ),
            _SheetAction(
              icon: DSIcons.hide,
              label: 'Not interested',
              onTap: () {
                Navigator.pop(ctx);
                widget.onHideClip?.call(widget.clip.id);
              },
            ),
            if (widget.onDelete != null &&
                context.read<AuthProvider>().user?.uid == widget.clip.playerId)
              _SheetAction(
                 icon: DSIcons.delete,
                label: 'Delete',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete();
                },
              ),
            SizedBox(height: DSSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _reportClip() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    final reasons = const [
      'Inappropriate content',
      'Spam or misleading',
      'Violates my rights',
      'Other',
    ];
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Report this clip', style: Theme.of(ctx).textTheme.titleMedium),
        children: [
          for (final r in reasons)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, r),
              child: Text(r),
            ),
        ],
      ),
    );
    if (reason == null || !mounted) return;
    await context
        .read<Database>()
        .reportClip(clipId: widget.clip.id, reporterUid: uid, reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report sent. Thanks for the feedback.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DSRadius.md)),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final onDelete = widget.onDelete;
    if (onDelete == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete clip?'),
        content: Text('This permanently removes the highlight.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: DSColors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      onDelete(widget.clip);
      widget.onHideClip?.call(widget.clip.id);
    }
  }

  void _openProfile() {
    widget.onOpenProfile?.call(widget.clip);
  }

  @override
  Widget build(BuildContext context) {
    final myUid = context.watch<AuthProvider>().user?.uid;
    final isSelf = myUid == widget.clip.playerId;
    final likeCount = widget.clip.likeCount + (_liked ? 1 : 0);

    final maxH = MediaQuery.of(context).size.height * 0.75;

    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTap: _onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Colors.black),
          if (_ready && _controller != null)
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH),
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: DSColors.volt),
                  SizedBox(height: DSSpacing.md),
                  Text(
                    'Loading video...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          if (!_playing && _ready)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(DSSpacing.lg),
                child: Icon(
                  DSIcons.playCircle,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
          // Top gradient for the header
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 140,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom gradient for legibility
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 260,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Right action rail
          Positioned(
            right: 12,
            bottom: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  _AnimatedRailButton(
                    icon: _liked ? DSIcons.like : DSIcons.likeOutline,
                    color: _liked ? Colors.redAccent : Colors.white,
                    count: _compact(likeCount),
                    onTap: _toggleLike,
                    controller: _likeButtonController,
                  ),
                  _AnimatedRailButton(
                    icon: DSIcons.comment,
                    color: Colors.white,
                    count: _compact(widget.clip.commentCount),
                    onTap: () => CommentSheet.show(context, widget.clip.id),
                  ),
                  _AnimatedRailButton(
                    icon: DSIcons.share,
                    color: Colors.white,
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      backgroundColor: DSColors.surfaceContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadius.sheet)),
                      ),
                      builder: (_) => ShareSheet(clip: widget.clip),
                    ),
                  ),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: widget.savedNotifier,
                    builder: (context, savedSet, _) {
                      final isSaved = savedSet.contains(widget.clip.id);
                      return _AnimatedRailButton(
                        icon: isSaved ? DSIcons.save : DSIcons.saveOutline,
                        color: isSaved ? DSColors.amber : Colors.white,
                        onTap: _toggleSave,
                      );
                    },
                  ),
                  _AnimatedRailButton(
                    icon: DSIcons.more,
                    color: Colors.white,
                    onTap: _openMore,
                  ),
                ],
              ),
            ),
          ),
          // Caption bottom-left
          Positioned(
            left: 16,
            right: 76,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _openProfile,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(
                      children: [
                        InitialsAvatar(name: widget.clip.playerName, radius: 14),
                        SizedBox(width: DSSpacing.sm),
                        Flexible(
                          child: Text(
                            widget.clip.playerName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 8),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_verified) ...[
                          SizedBox(width: DSSpacing.xs),
                          VerifiedBadge(size: 13, animate: true),
                        ],
                        if (!isSelf) ...[
                          SizedBox(width: DSSpacing.sm),
                          _buildFollowButton(),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: DSSpacing.xs),
                Text(
                  widget.clip.description.isEmpty
                      ? (widget.clip.title.isEmpty
                          ? 'Highlight'
                          : widget.clip.title)
                      : widget.clip.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 6),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: DSSpacing.xs),
                Row(
                  children: [
                    TagChip(text: widget.clip.sport, color: Colors.lightGreenAccent),
                    SizedBox(width: DSSpacing.xs),
                    TagChip(text: widget.clip.position, color: Colors.cyanAccent),
                    SizedBox(width: DSSpacing.sm),
                    Text(
                      '${_compact(widget.clip.viewCount)} views · ${timeAgo(widget.clip.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: DSSpacing.sm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(DSIcons.music, size: DSIconSize.xs, color: Colors.white),
                    SizedBox(width: DSSpacing.xs),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: MarqueeText(
                        text: '${widget.clip.sport} · ${widget.clip.position}',
                        style: (Theme.of(context)
                                    .textTheme
                                    .labelMedium ??
                                const TextStyle())
                            .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 4),
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Double-tap heart burst
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _heartController,
              builder: (context, child) {
                final t = Curves.easeOutBack.transform(_heartController.value);
                final opacity = (1 - _heartController.value).clamp(0.0, 1.0);
                return Center(
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: _heartController.value == 0 ? 0 : t,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(DSSpacing.lg),
                        child: Icon(
                          DSIcons.like,
                          size: 100,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: widget.followingNotifier,
      builder: (context, followingSet, _) {
        final isFollowing = followingSet.contains(widget.clip.playerId);
        if (isFollowing) {
          return ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.95).animate(
              CurvedAnimation(parent: _followButtonController, curve: DSMotion.easeOut),
            ),
            child: OutlinedButton(
              onPressed: _toggleFollow,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white70, width: 1.5),
                padding: EdgeInsets.symmetric(horizontal: DSSpacing.md),
                minimumSize: Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DSRadius.chip)),
              ),
              child: Text(
                'Following',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }
        return ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.95).animate(
            CurvedAnimation(parent: _followButtonController, curve: DSMotion.easeOut),
          ),
          child: FilledButton(
            onPressed: _toggleFollow,
            style: FilledButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: DSSpacing.lg),
              minimumSize: Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DSRadius.chip)),
            ),
            child: Text(
              'Follow',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedRailButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String? count;
  final VoidCallback onTap;
  final AnimationController? controller;

  const _AnimatedRailButton({
    required this.icon,
    this.color = Colors.white,
    this.count,
    required this.onTap,
    this.controller,
  });

  @override
  State<_AnimatedRailButton> createState() => _AnimatedRailButtonState();
}

class _AnimatedRailButtonState extends State<_AnimatedRailButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _localController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _localController = AnimationController(
      vsync: this,
      duration: DSMotion.fast,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _localController, curve: DSMotion.easeOut),
    );
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _localController.forward();
    widget.controller?.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _localController.reverse();
    widget.controller?.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _localController.reverse();
    widget.controller?.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller ?? _localController;
    final scaleAnim = widget.controller != null
        ? Tween<double>(begin: 1.0, end: 1.15).animate(
            CurvedAnimation(parent: controller, curve: DSMotion.easeOut),
          )
        : _scaleAnim;

    return Padding(
      padding: EdgeInsets.only(bottom: DSSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Transform.scale(
                scale: scaleAnim.value,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTapDown: _handleTapDown,
                    onTapUp: _handleTapUp,
                    onTapCancel: _handleTapCancel,
                    child: Icon(widget.icon, color: widget.color, size: DSIconSize.xl),
                  ),
                ),
              );
            },
          ),
          if (widget.count != null)
            Padding(
              padding: EdgeInsets.only(top: DSSpacing.xs),
              child: Text(
                widget.count!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 4),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? DSColors.red : DSColors.onSurface;
    return ListTile(
      leading: Icon(icon, color: color, size: DSIconSize.md),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: DSSpacing.xs),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DSRadius.md)),
    );
  }
}

String _compact(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

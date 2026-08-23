import 'package:flutter/material.dart';
import '../../design_system.dart';
import 'initials_avatar.dart';

class VideoCard extends StatefulWidget {
  final String playerName;
  final String playerPosition;
  final String title;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? duration;
  final int likes;
  final int comments;
  final int views;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final bool isLiked;

  const VideoCard({
    super.key,
    required this.playerName,
    required this.playerPosition,
    required this.title,
    this.videoUrl,
    this.thumbnailUrl,
    this.duration,
    this.likes = 0,
    this.comments = 0,
    this.views = 0,
    this.onTap,
    this.onLike,
    this.onComment,
    this.isLiked = false,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _isHovered = false;

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DSMotion.fast,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(DSRadius.card),
            border: Border.all(
              color: _isHovered ? Theme.of(context).colorScheme.outline : Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
            boxShadow: _isHovered ? DSElevation.level2 : DSElevation.level1,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVideoThumbnail(),
              _buildVideoInfo(),
              _buildEngagementRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.thumbnailUrl != null)
            Image.network(
              widget.thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          else
            _buildPlaceholder(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          Center(
            child: AnimatedContainer(
              duration: DSMotion.fast,
              width: _isHovered ? 52 : 48,
              height: _isHovered ? 52 : 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                DSIcons.play,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 28,
              ),
            ),
          ),
          if (widget.duration != null)
            Positioned(
              top: DSSpacing.sm,
              right: DSSpacing.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(DSRadius.xs),
                ),
                child: Text(
                  widget.duration!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: DSSpacing.sm,
            left: DSSpacing.sm,
            right: DSSpacing.sm,
            child: Row(
              children: [
                InitialsAvatar(
                  name: widget.playerName,
                  size: AvatarSize.sm,
                ),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.playerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.playerPosition,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Center(
        child: Icon(
          DSIcons.videoCamera,
          size: 40,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(DSSpacing.md, DSSpacing.sm, DSSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: DSSpacing.xs),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: DSColors.voltSurface,
                  borderRadius: BorderRadius.circular(DSRadius.chip),
                ),
                child: Text(
                  widget.playerPosition,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.md,
        DSSpacing.sm,
        DSSpacing.md,
        DSSpacing.sm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onLike,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isLiked ? DSIcons.like : DSIcons.likeOutline,
                  size: 16,
                  color: widget.isLiked ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatCount(widget.likes),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: widget.isLiked ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DSSpacing.md),
          GestureDetector(
            onTap: widget.onComment,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  DSIcons.comment,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatCount(widget.comments),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Icon(
            DSIcons.eye,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            _formatCount(widget.views),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

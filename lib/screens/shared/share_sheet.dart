import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants.dart';
import '../../models/clip.dart';
import '../../models/conversation.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import 'widgets.dart';

/// Bottom sheet with all share options for a clip.
class ShareSheet extends StatefulWidget {
  final Clip clip;

  const ShareSheet({super.key, required this.clip});

  static String linkFor(Clip clip) =>
      '${AppConstants.shareBaseUrl}/#/clip/${clip.id}';

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet>
    with SingleTickerProviderStateMixin {
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
            offset: _slideAnim.value * 50,
            child: child,
          ),
        );
      },
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: DSSpacing.md),
              decoration: BoxDecoration(
                color: DSColors.outlineVariant,
                borderRadius: BorderRadius.circular(DSRadius.full),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DSSpacing.lg),
              child: Row(
                children: [
                  Text(
                    'Share',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(DSIcons.x, color: DSColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: DSColors.outlineVariant),
            // Share options
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ShareAction(
                    icon: DSIcons.link,
                    label: 'Copy link',
                    subtitle: ShareSheet.linkFor(widget.clip),
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: ShareSheet.linkFor(widget.clip)),
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Link copied to clipboard'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(DSRadius.md),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  _ShareAction(
                    icon: DSIcons.send,
                    label: 'Share to DM',
                    onTap: () {
                      Navigator.pop(context);
                      _shareToDm(context);
                    },
                  ),
                  _ShareAction(
                    icon: DSIcons.share,
                    label: 'Share…',
                    onTap: () async {
                      Navigator.pop(context);
                      await SharePlus.instance.share(
                        ShareParams(
                          text: 'Check out this highlight on ScoutX: ${widget.clip.title}\n'
                              '${ShareSheet.linkFor(widget.clip)}',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: DSSpacing.md + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _shareToDm(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final db = context.read<Database>();
    final user = auth.user;
    final me = auth.profile;
    if (user == null || me == null) return;

    final conversations = await db.streamConversations(user.uid).first;
    if (!context.mounted) return;

    final picked = await showModalBottomSheet<Conversation>(
      context: context,
      backgroundColor: DSColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadius.sheet)),
      ),
      builder: (ctx) {
        return SafeArea(
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DSSpacing.lg),
                child: Row(
                  children: [
                    Text(
                      'Send to…',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(DSIcons.x, color: DSColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: DSColors.outlineVariant),
              if (conversations.isEmpty)
                EmptyState(
                  icon: DSIcons.chatCircleDots,
                  title: 'No conversations yet',
                  subtitle: 'Start a chat to share highlights.',
                  animate: false,
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: conversations.length,
                    itemBuilder: (ctx, index) {
                      final c = conversations[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: DSColors.surfaceContainerHigh,
                          child: InitialsAvatar(
                            name: c.otherParticipantName(user.uid) ?? 'User',
                            radius: 16,
                          ),
                        ),
                        title: Text(
                          c.otherParticipantName(user.uid) ?? 'Chat',
                          style: Theme.of(ctx).textTheme.bodyLarge,
                        ),
                        onTap: () => Navigator.pop(ctx, c),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: DSSpacing.lg,
                          vertical: DSSpacing.xs,
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: DSSpacing.md + MediaQuery.of(ctx).padding.bottom),
            ],
          ),
        );
      },
    );

    if (picked == null || !context.mounted) return;
    final label =
        '${widget.clip.title.isEmpty ? 'Highlight' : widget.clip.title} · ${widget.clip.playerName}';
    await db.sendMessage(
      picked.id,
      senderId: user.uid,
      senderName: me.displayName,
      text: 'Check out this highlight: $label',
      clipId: widget.clip.id,
      clipTitle: widget.clip.title,
      clipVideoUrl: widget.clip.videoUrl,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.md),
          ),
        ),
      );
    }
  }
}

class _ShareAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _ShareAction({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DSColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        child: Icon(icon, color: DSColors.onSurface, size: DSIconSize.md),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DSColors.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.xs,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DSRadius.md)),
      hoverColor: DSColors.hoverOverlay,
      splashColor: DSColors.pressOverlay,
    );
  }
}



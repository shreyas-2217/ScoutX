import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/cloudinary_service.dart';
import '../../services/database.dart';
import '../shared/clip_player_screen.dart';
import '../shared/player_profile_view_screen.dart';
import '../shared/widgets.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherId;
  final String otherName;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherId,
    required this.otherName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  void _markAsRead() {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid != null) {
      context
          .read<Database>()
          .resetUnreadCount(widget.conversationId, uid);
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;

    final auth = context.read<AuthProvider>();
    final db = context.read<Database>();
    final uid = auth.user?.uid;
    final name = auth.profile?.displayName ?? 'User';
    if (uid == null) return;

    setState(() => _sending = true);
    _input.clear();

    try {
      await db.sendMessage(
        widget.conversationId,
        senderId: uid,
        senderName: name,
        text: text,
        receiverId: widget.otherId,
      );
      _scrollToBottom();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send. Try again.')),
        );
        _input.text = text;
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: DSMotion.normal,
          curve: DSMotion.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myUid = context.watch<AuthProvider>().user?.uid;
    final db = context.read<Database>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(DSIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    PlayerProfileViewScreen(playerId: widget.otherId),
              ),
            );
          },
          child: Row(
            children: [
              InitialsAvatar(name: widget.otherName, radius: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherName,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(DSIcons.moreVertRounded),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'profile', child: Text('View Profile')),
              const PopupMenuItem(
                  value: 'clear', child: Text('Clear Chat')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: db.streamMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: DSColors.onSurface),
                  );
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          DSIcons.forumRounded,
                          size: 48,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Say hello!',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Send a message to start the conversation.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMine = msg.senderId == myUid;
                    final showHeader = index == 0 ||
                        messages[index - 1].senderId != msg.senderId;
                    return _ChatBubble(
                      message: msg,
                      isMine: isMine,
                      showHeader: showHeader,
                    );
                  },
                );
              },
            ),
          ),
          _buildInputBar(theme),
        ],
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerTheme.color ?? theme.colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle:
                    TextStyle(color: theme.colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DSRadius.full),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: DSMotion.fast,
            child: IconButton(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: DSColors.onSurface,
                      ),
                    )
                  : const Icon(DSIcons.send, color: DSColors.onSurface),
              style: IconButton.styleFrom(
                backgroundColor: DSColors.onSurface.withValues(alpha: 0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'profile':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                PlayerProfileViewScreen(playerId: widget.otherId),
          ),
        );
        break;
      case 'clear':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coming soon')),
        );
        break;
    }
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool showHeader;

  const _ChatBubble({
    required this.message,
    required this.isMine,
    required this.showHeader,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: showHeader ? 12 : 2,
          left: isMine ? 60 : 0,
          right: isMine ? 0 : 60,
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (showHeader && !isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(
                  message.senderName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine
                    ? DSColors.onSurface
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(DSRadius.lg),
                  topRight: const Radius.circular(DSRadius.lg),
                  bottomLeft:
                      Radius.circular(isMine ? DSRadius.lg : DSRadius.sm),
                  bottomRight:
                      Radius.circular(isMine ? DSRadius.sm : DSRadius.lg),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMine
                          ? DSColors.onBrand
                          : theme.colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  if (message.clipId != null) ...[
                    const SizedBox(height: 8),
                    _ClipCard(message: message),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      color: isMine
                          ? DSColors.onBrand.withValues(alpha: 0.6)
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }
}

class _ClipCard extends StatelessWidget {
  final ChatMessage message;

  const _ClipCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final title = (message.clipTitle?.isEmpty ?? true)
        ? 'Highlight'
        : message.clipTitle!;
    final thumbnail = CloudinaryService.videoThumbnail(
      message.clipVideoUrl,
      width: 120,
      height: 120,
    );
    return GestureDetector(
      onTap: () {
        final url = message.clipVideoUrl;
        if (url == null || url.isEmpty) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClipPlayerScreen(videoUrl: url, title: title),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: DSColors.onSurface.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(DSRadius.sm),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: DSColors.onSurface.withValues(alpha: 0.2)),
                    if (thumbnail != null)
                      Image.network(
                        thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DSColors.onSurface,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

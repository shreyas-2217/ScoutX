import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/conversation.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../../widgets/skeletons.dart';
import '../shared/widgets.dart';
import 'chat_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;
    if (uid == null) return const SizedBox.shrink();
    final db = context.read<Database>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(DSIcons.magnifyingGlass),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Conversation>>(
        stream: db.streamConversations(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton();
          }
          final conversations = snapshot.data ?? [];
          if (conversations.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conv = conversations[index];
              return _ConversationTile(
                conversation: conv,
                currentUid: uid,
                onTap: () {
                  final otherId = conv.otherParticipantId(uid);
                  final otherName =
                      conv.otherParticipantName(uid) ?? 'User';
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        conversationId: conv.id,
                        otherId: otherId,
                        otherName: otherName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(DSSpacing.md),
      itemCount: 6,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const SkeletonBox(width: 52, height: 52, borderRadius: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 140, height: 14),
                  SizedBox(height: 6),
                  SkeletonBox(width: 200, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              DSIcons.chatCircleDots,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect with players, coaches and scouts to start building your network.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _UserSearchSheet(),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String currentUid;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.currentUid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final otherName = conversation.otherParticipantName(currentUid) ?? 'User';
    final unread = conversation.unreadCounts[currentUid] ?? 0;
    final hasUnread = unread > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: hasUnread
              ? DSColors.onSurface.withValues(alpha: 0.04)
              : Colors.transparent,
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  InitialsAvatar(name: otherName, radius: 26),
                  if (hasUnread)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: DSColors.red,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight:
                            hasUnread ? FontWeight.w700 : FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conversation.lastMessage.isEmpty
                          ? 'Say hi'
                          : conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: hasUnread
                            ? DSColors.onSurface
                            : DSColors.onSurfaceVariant,
                        fontWeight:
                            hasUnread ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeAgo(conversation.lastMessageAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: DSColors.onSurfaceDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserSearchSheet extends StatefulWidget {
  const _UserSearchSheet();

  @override
  State<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends State<_UserSearchSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<Database>();
    final myUid = context.read<AuthProvider>().user?.uid ?? '';
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: DSColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search players, coaches...',
                  prefixIcon: const Icon(DSIcons.magnifyingGlass,
                      color: DSColors.onSurfaceVariant),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSRadius.input),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: _query.trim().isEmpty
                  ? Center(
                      child: Text(
                        'Type to search for users',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: DSColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : StreamBuilder<List<UserProfile>>(
                      stream: db.searchUsers(_query),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: DSColors.onSurface),
                          );
                        }
                        final users = (snapshot.data ?? [])
                            .where((u) => u.uid != myUid)
                            .toList();
                        if (users.isEmpty) {
                          return Center(
                            child: Text(
                              'No users found',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: DSColors.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: InitialsAvatar(
                                  name: user.displayName, radius: 22),
                              title: Text(
                                user.displayName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                [
                                  user.role[0].toUpperCase() +
                                      user.role.substring(1),
                                  if (user.sport != null) user.sport!,
                                ].join(' · '),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: DSColors.onSurfaceVariant,
                                ),
                              ),
                              onTap: () async {
                                final auth = context.read<AuthProvider>();
                                final me = auth.profile;
                                if (me == null) return;
                                final convId =
                                    await db.getOrCreateConversation(
                                  myUid,
                                  user.uid,
                                  {myUid: me.displayName, user.uid: user.displayName},
                                );
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      conversationId: convId,
                                      otherId: user.uid,
                                      otherName: user.displayName,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

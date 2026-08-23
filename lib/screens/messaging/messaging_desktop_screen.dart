import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/conversation.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../shared/widgets.dart';
import 'chat_screen.dart';

class MessagingDesktopScreen extends StatefulWidget {
  const MessagingDesktopScreen({super.key});

  @override
  State<MessagingDesktopScreen> createState() => _MessagingDesktopScreenState();
}

class _MessagingDesktopScreenState extends State<MessagingDesktopScreen> {
  String? _selectedConvId;
  String? _selectedOtherId;
  String? _selectedOtherName;

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      body: Row(
        children: [
          // Left panel: conversation list
          SizedBox(
            width: 340,
            child: _ConversationList(
              uid: uid,
              selectedId: _selectedConvId,
              onSelect: (conv) {
                setState(() {
                  _selectedConvId = conv.id;
                  _selectedOtherId = conv.otherParticipantId(uid);
                  _selectedOtherName = conv.otherParticipantName(uid) ?? 'User';
                });
              },
            ),
          ),
          // Divider
          VerticalDivider(width: 1, color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outline),
          // Right panel: chat or empty state
          Expanded(
            child: _selectedConvId != null
                ? ChatScreen(
                    conversationId: _selectedConvId!,
                    otherId: _selectedOtherId!,
                    otherName: _selectedOtherName!,
                  )
                : _buildEmptyState(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('Select a conversation', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Choose a conversation from the left to start messaging.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  final String uid;
  final String? selectedId;
  final ValueChanged<Conversation> onSelect;

  const _ConversationList({
    required this.uid,
    this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final db = context.read<Database>();
    return StreamBuilder<List<Conversation>>(
      stream: db.streamConversations(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface));
        }
        final conversations = snapshot.data ?? [];
        if (conversations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 12),
                  Text('No conversations', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conv = conversations[index];
            final otherName = conv.otherParticipantName(uid) ?? 'User';
            final isSelected = conv.id == selectedId;
            final myUnread = conv.unreadCounts[uid] ?? 0;

            return ListTile(
              selected: isSelected,
              selectedTileColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
              leading: InitialsAvatar(name: otherName, radius: 22),
              title: Text(otherName, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              subtitle: Text(
                conv.lastMessage.isEmpty ? 'Start chatting' : conv.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              trailing: myUnread > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$myUnread', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    )
                  : Text(
                      _timeAgo(conv.lastMessageAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
              onTap: () => onSelect(conv),
            );
          },
        );
      },
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}

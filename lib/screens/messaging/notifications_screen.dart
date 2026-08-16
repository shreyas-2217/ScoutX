import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_notification.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../shared/player_profile_view_screen.dart';
import '../shared/widgets.dart';
import '../../widgets/skeletons.dart';
import 'chat_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;
    if (uid == null) return const SizedBox.shrink();
    final db = context.read<Database>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => db.markAllNotificationsRead(uid),
            child: Text(
              'Mark all read',
              style: TextStyle(color: DSColors.volt),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: db.streamNotifications(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton();
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _NotificationTile(
                notification: notif,
                onTap: () => _handleTap(context, notif, uid, db),
              );
            },
          );
        },
      ),
    );
  }

  void _handleTap(
      BuildContext context, AppNotification notif, String myUid, Database db) {
    if (notif.type == 'message' && notif.conversationId != null) {
      if (!notif.isRead) {
        db.markNotificationRead(notif.id);
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: notif.conversationId!,
            otherId: notif.fromUserId,
            otherName: notif.fromUserName,
          ),
        ),
      );
    } else if (notif.type == 'follow') {
      if (!notif.isRead) {
        db.markNotificationRead(notif.id);
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlayerProfileViewScreen(playerId: notif.fromUserId),
        ),
      );
    }
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(DSSpacing.md),
      itemCount: 5,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const SkeletonBox(width: 44, height: 44, borderRadius: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 220, height: 14),
                  SizedBox(height: 6),
                  SkeletonBox(width: 100, height: 12),
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
              DSIcons.notifications,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'When someone follows you or messages you, it will appear here.',
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
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notif = notification;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: notif.isRead
              ? Colors.transparent
              : DSColors.volt.withValues(alpha: 0.04),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialsAvatar(name: notif.fromUserName, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: notif.fromUserName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: DSColors.onSurface,
                        ),
                        children: [
                          TextSpan(
                            text: _notificationText(notif),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: DSColors.onSurfaceVariant,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeAgo(notif.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: DSColors.onSurfaceDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notif.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: DSColors.volt,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _notificationText(AppNotification notif) {
    switch (notif.type) {
      case 'follow':
        return ' started following you';
      case 'message':
        return notif.message != null && notif.message!.isNotEmpty
            ? ' sent you a message: "${notif.message}"'
            : ' sent you a message';
      default:
        return ' interacted with you';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoutx/design_system.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ai_provider.dart';
import '../../services/database.dart';
import '../../widgets/ai/scoutx_ai_button.dart';
import '../ai/scoutx_ai_screen.dart';
import '../messaging/inbox_screen.dart';
import '../messaging/notifications_screen.dart';
import '../shared/my_profile_screen.dart';
import '../shared/widgets.dart';

class AppShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<AppNavItem> navItems;
  final Widget child;
  final String title;

  const AppShell({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.navItems,
    required this.child,
    this.title = 'ScoutX',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;
        
        if (isDesktop) {
          return _DesktopLayout(
            currentIndex: currentIndex,
            onIndexChanged: onIndexChanged,
            navItems: navItems,
            child: child,
          );
        }
        
        return _MobileLayout(
          currentIndex: currentIndex,
          onIndexChanged: onIndexChanged,
          navItems: navItems,
          child: child,
        );
      },
    );
  }
}

class AppNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget? trailing;

  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.trailing,
  });
}

class _DesktopLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<AppNavItem> navItems;
  final Widget child;

  const _DesktopLayout({
    required this.currentIndex,
    required this.onIndexChanged,
    required this.navItems,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // Sidebar
              Container(
                width: 240,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: BrandLogo(
                          markSize: 32,
                          fontSize: 20,
                          animate: false,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: navItems.length,
                        itemBuilder: (context, index) {
                          final item = navItems[index];
                          final isSelected = index == currentIndex;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () => onIndexChanged(index),
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? DSColors.volt.withValues(alpha: 0.08) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? DSColors.volt.withValues(alpha: 0.2) : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected ? item.activeIcon : item.icon,
                                        size: 22,
                                        color: isSelected ? DSColors.volt : Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            color: isSelected ? DSColors.volt : Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      if (item.trailing != null) item.trailing!,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Divider(
                            color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: InitialsAvatar(name: context.watch<AuthProvider>().profile?.displayName ?? 'User', radius: 20),
                            title: Text(
                              'Profile',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            onTap: () {
                              final auth = context.read<AuthProvider>();
                              if (auth.profile != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MyProfileScreen(profile: auth.profile!),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main content (must be inside Row, not Stack)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 400),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search athletes, coaches, trials...',
                                    prefixIcon: Icon(Icons.search, size: 20),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _BadgeIconButton(
                              icon: Icons.notifications_outlined,
                              stream: context.read<AuthProvider>().user != null
                                  ? context.read<Database>().streamUnreadNotificationCount(context.read<AuthProvider>().user!.uid)
                                  : const Stream.empty(),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                                );
                              },
                            ),
                            _BadgeIconButton(
                              icon: Icons.chat_bubble_outline,
                              stream: context.read<AuthProvider>().user != null
                                  ? context.read<Database>().streamTotalUnreadCount(context.read<AuthProvider>().user!.uid)
                                  : const Stream.empty(),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const InboxScreen()),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => onIndexChanged(navItems.length - 1),
                              child: InitialsAvatar(
                                name: context.watch<AuthProvider>().profile?.displayName ?? 'U',
                                radius: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ScoutX AI floating button + overlay
          Positioned(
            left: 260,
            bottom: 20,
            child: _AIOverlay(),
          ),
        ],
      ),
    );
  }
}

class _BadgeIconButton extends StatelessWidget {
  final IconData icon;
  final Stream<int> stream;
  final VoidCallback onPressed;

  const _BadgeIconButton({
    required this.icon,
    required this.stream,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(icon),
              onPressed: onPressed,
            ),
            if (count > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: DSColors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<AppNavItem> navItems;
  final Widget child;

  const _MobileLayout({
    required this.currentIndex,
    required this.onIndexChanged,
    required this.navItems,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child,
          Positioned(
            left: 16,
            bottom: 160,
            child: _AIOverlay(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isSelected = index == currentIndex;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onIndexChanged(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? DSColors.volt.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            size: 24,
                            color: isSelected
                                ? DSColors.volt
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? DSColors.volt
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                     ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _AIOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AIProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    if (ai.isOpen) {
      return GestureDetector(
        onTap: () {},
        child: Container(
          width: isDesktop ? 420 : MediaQuery.of(context).size.width,
          height: isDesktop ? MediaQuery.of(context).size.height - 80 : null,
          constraints: isDesktop ? null : BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          margin: EdgeInsets.only(
            right: isDesktop ? 16 : 16,
            bottom: isDesktop ? 16 : 80,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: const ScoutXAIScreen(),
        ),
      );
    }

    return const ScoutXAIFloatingButton();
  }
}

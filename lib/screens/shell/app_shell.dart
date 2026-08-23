import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_glass_kit/liquid_glass_kit.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ai_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/fab_visibility_provider.dart';
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
    // The scroll-aware FAB state is global, but only the Home screen's scroll
    // position ever hides it. Re-show it on every tab switch so leaving Home
    // never leaves the FAB/AI button stuck invisible on other tabs.
    void handleIndexChanged(int index) {
      context.read<FabVisibilityProvider>().show();
      onIndexChanged(index);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;
        
        if (isDesktop) {
          return _DesktopLayout(
            currentIndex: currentIndex,
            onIndexChanged: handleIndexChanged,
            navItems: navItems,
            child: child,
          );
        }
        
        return _MobileLayout(
          currentIndex: currentIndex,
          onIndexChanged: handleIndexChanged,
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
                                    color: isSelected ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15) : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected ? item.activeIcon : item.icon,
                                        size: 22,
                                        color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
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
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            Text('v4.1 • 30 Jan', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5), letterSpacing: 0.5)),
                            const SizedBox(height: 8),
                            Divider(
                              color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Consumer<ThemeProvider>(
                              builder: (context, themeProvider, _) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    themeProvider.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  title: Text(
                                    themeProvider.isDark ? 'Dark Mode' : 'Light Mode',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  trailing: Switch(
                                    value: themeProvider.isDark,
                                    onChanged: (_) => themeProvider.toggleTheme(),
                                    activeThumbColor: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  onTap: () => themeProvider.toggleTheme(),
                                );
                              },
                            ),
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
                    ),
                  ],
                ),
              ),

              // Main content (must be inside Row, not Stack)
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
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
                                        prefixIcon: const Icon(Icons.search, size: 20),
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

          // ScoutX AI — above Upload FAB (which sits at 16), hidden on Highlights/Reels
          Positioned(
            right: 20,
            bottom: 90,
            child: _AIOverlay(
              currentIndex: currentIndex,
              navItems: navItems,
            ),
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
            bottom: 140,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: _AIOverlay(
                currentIndex: currentIndex,
                navItems: navItems,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: LiquidGlassContainer(
              blur: 18,
              opacity: 0.78,
              borderRadius: 28,
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
              borderColor: Colors.white.withValues(alpha: 0.18),
              borderWidth: 1,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, 8)),
              ],
              padding: EdgeInsets.symmetric(horizontal: navItems.length > 5 ? 4 : 8, vertical: 6),
              child: SafeArea(
                top: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = navItems.length > 5;
                    final double iconSz = isCompact ? 20 : 22;
                    final double fontSz = isCompact ? 8.5 : 10;
                    return Row(
                      children: List.generate(navItems.length, (index) {
                        final item = navItems[index];
                        final isSelected = index == currentIndex;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onIndexChanged(index),
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(vertical: isCompact ? 6 : 8, horizontal: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Icon(
                                        isSelected ? item.activeIcon : item.icon,
                                        size: iconSz,
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.onSurface
                                            : Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      if (item.trailing != null)
                                        Positioned(right: -6, top: -4, child: item.trailing!),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      item.label,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: fontSz,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.onSurface
                                            : Theme.of(context).colorScheme.onSurfaceVariant,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate(target: isSelected ? 1 : 0)
                                .scale(duration: 180.ms, curve: Curves.easeOut, begin: const Offset(0.92, 0.92), end: const Offset(1, 1)),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AIOverlay extends StatefulWidget {
  final int currentIndex;
  final List<AppNavItem> navItems;
  const _AIOverlay({super.key, required this.currentIndex, required this.navItems});

  @override
  State<_AIOverlay> createState() => _AIOverlayState();
}

class _AIOverlayState extends State<_AIOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide entirely on Highlights / Reels tabs
    final label = widget.navItems[widget.currentIndex].label.toLowerCase();
    final isHighlightsTab = label.contains('highlight') || label.contains('reel');
    if (isHighlightsTab) {
      // If AI was open and user switched to highlights, close it
      final ai = context.read<AIProvider>();
      if (ai.isOpen) WidgetsBinding.instance.addPostFrameCallback((_) => ai.close());
      return const SizedBox.shrink();
    }

    final ai = context.watch<AIProvider>();
    final fabVisible = context.watch<FabVisibilityProvider>().isVisible;
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    Widget child;
    if (ai.isOpen) {
      _controller.forward();
      child = FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: GestureDetector(
            onTap: () {},
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: isDesktop
                    ? LiquidGlassContainer(
                        width: 420,
                        height: MediaQuery.of(context).size.height * 0.75,
                        borderRadius: 20,
                        blur: 18,
                        opacity: 0.92,
                        color: Theme.of(context).colorScheme.surface,
                        borderColor: Colors.white.withValues(alpha: 0.18),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 28, spreadRadius: 2),
                        ],
                        child: const ScoutXAIScreen(),
                      )
                    : ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.72,
                        ),
                        child: LiquidGlassContainer(
                          width: MediaQuery.of(context).size.width - 32,
                          borderRadius: 20,
                          blur: 18,
                          opacity: 0.92,
                          color: Theme.of(context).colorScheme.surface,
                          borderColor: Colors.white.withValues(alpha: 0.18),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 28, spreadRadius: 2),
                          ],
                          child: const ScoutXAIScreen(),
                        ),
                      ),
              ),
            ),
          ),
        ),
      );
     } else {
      _controller.reverse();
      child = const ScoutXAIFloatingButton();
    }
    return AnimatedScale(
      scale: fabVisible ? 1 : 0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: fabVisible ? 1 : 0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: IgnorePointer(ignoring: !fabVisible, child: child),
      ),
    );
  }
}

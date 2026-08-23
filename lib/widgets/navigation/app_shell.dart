import 'package:flutter/material.dart';
import 'mobile_nav.dart';
import 'desktop_nav_rail.dart';

class AppShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<DesktopNavRailItem> navItems;
  final List<MobileNavItem> mobileNavItems;
  final Widget child;
  final double desktopMaxWidth;

  const AppShell({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.navItems,
    required this.mobileNavItems,
    required this.child,
    this.desktopMaxWidth = 960,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        if (isDesktop) {
          return _DesktopLayout(
            currentIndex: currentIndex,
            onTap: onTap,
            navItems: navItems,
            desktopMaxWidth: desktopMaxWidth,
            child: child,
          );
        }

        return _MobileLayout(
          currentIndex: currentIndex,
          onTap: onTap,
          mobileNavItems: mobileNavItems,
          child: child,
        );
      },
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<DesktopNavRailItem> navItems;
  final Widget child;
  final double desktopMaxWidth;

  const _DesktopLayout({
    required this.currentIndex,
    required this.onTap,
    required this.navItems,
    required this.desktopMaxWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          DesktopNavRail(
            currentIndex: currentIndex,
            onTap: onTap,
            items: navItems,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: desktopMaxWidth),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<MobileNavItem> mobileNavItems;
  final Widget child;

  const _MobileLayout({
    required this.currentIndex,
    required this.onTap,
    required this.mobileNavItems,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: MobileNav(
        currentIndex: currentIndex,
        onTap: onTap,
        items: mobileNavItems,
      ),
      body: child,
    );
  }
}

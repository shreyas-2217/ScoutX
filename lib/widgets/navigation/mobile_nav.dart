import 'package:flutter/material.dart';
import '../../design_system.dart';

class MobileNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<MobileNavItem> items;

  const MobileNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DSColors.surface,
        border: Border(
          top: BorderSide(color: DSColors.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;

              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: DSMotion.fast,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? DSColors.voltSurface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(DSRadius.lg),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: DSIconSize.bottomNav,
                        color: isActive ? DSColors.onSurface : DSColors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                          color: isActive ? DSColors.onSurface : DSColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class MobileNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const MobileNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

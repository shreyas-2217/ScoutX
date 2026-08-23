import 'package:flutter/material.dart';
import '../../design_system.dart';

class DesktopNavRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<DesktopNavRailItem> items;

  const DesktopNavRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: const BoxDecoration(
        color: DSColors.surface,
        border: Border(
          right: BorderSide(color: DSColors.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: DSSpacing.lg),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isActive = index == currentIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: DSMotion.fast,
                      padding: const EdgeInsets.symmetric(
                        vertical: DSSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? DSColors.voltSurface : Colors.transparent,
                        borderRadius: BorderRadius.circular(DSRadius.lg),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            size: DSIconSize.md,
                            color: isActive ? DSColors.onSurface : DSColors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive ? DSColors.onSurface : DSColors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DesktopNavRailItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const DesktopNavRailItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

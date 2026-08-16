import 'package:flutter/material.dart';
import '../../design_system.dart';

class StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? DSColors.volt;
    final bgColor = iconBackgroundColor ?? DSColors.voltSurface;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm + 4),
      decoration: BoxDecoration(
        color: DSColors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: DSColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: DSColors.onSurface,
              height: 1.1,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: DSColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

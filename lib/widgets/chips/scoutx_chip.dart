import 'package:flutter/material.dart';
import '../../design_system.dart';

enum SXChipVariant { defaultChip, sport, position, skillLevel }
enum SXChipStatus { none, accepted, pending, rejected }

class SXChip extends StatelessWidget {
  final String label;
  final SXChipVariant variant;
  final SXChipStatus status;
  final bool compact;
  final VoidCallback? onTap;

  const SXChip({
    super.key,
    required this.label,
    this.variant = SXChipVariant.defaultChip,
    this.status = SXChipStatus.none,
    this.compact = true,
    this.onTap,
  });

  Color get _backgroundColor {
    if (status != SXChipStatus.none) {
      switch (status) {
        case SXChipStatus.accepted:
          return DSColors.voltSurface;
        case SXChipStatus.pending:
          return const Color(0xFFFFF8E1);
        case SXChipStatus.rejected:
          return const Color(0xFFFFEBEE);
        case SXChipStatus.none:
          return DSColors.surfaceContainer;
      }
    }
    switch (variant) {
      case SXChipVariant.defaultChip:
        return DSColors.surfaceContainer;
      case SXChipVariant.sport:
        return DSColors.voltSurface;
      case SXChipVariant.position:
        return const Color(0xFFE0F7FA);
      case SXChipVariant.skillLevel:
        return const Color(0xFFFFF8E1);
    }
  }

  Color get _textColor {
    if (status != SXChipStatus.none) {
      switch (status) {
        case SXChipStatus.accepted:
          return DSColors.volt;
        case SXChipStatus.pending:
          return DSColors.amber;
        case SXChipStatus.rejected:
          return DSColors.red;
        case SXChipStatus.none:
          return DSColors.onSurfaceVariant;
      }
    }
    switch (variant) {
      case SXChipVariant.defaultChip:
        return DSColors.onSurfaceVariant;
      case SXChipVariant.sport:
        return DSColors.volt;
      case SXChipVariant.position:
        return const Color(0xFF00838F);
      case SXChipVariant.skillLevel:
        return const Color(0xFFE65100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(DSRadius.chip),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _textColor,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: chip);
    }
    return chip;
  }
}

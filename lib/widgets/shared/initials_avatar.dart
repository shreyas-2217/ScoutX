import 'dart:math';
import 'package:flutter/material.dart';
import '../../design_system.dart';

enum AvatarSize { sm, md, lg, xl }

class InitialsAvatar extends StatelessWidget {
  final String name;
  final AvatarSize size;
  final bool showOnlineIndicator;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = AvatarSize.md,
    this.showOnlineIndicator = false,
  });

  double get _dimension {
    switch (size) {
      case AvatarSize.sm:
        return 32;
      case AvatarSize.md:
        return 40;
      case AvatarSize.lg:
        return 56;
      case AvatarSize.xl:
        return 80;
    }
  }

  double get _fontSize {
    switch (size) {
      case AvatarSize.sm:
        return 12;
      case AvatarSize.md:
        return 14;
      case AvatarSize.lg:
        return 20;
      case AvatarSize.xl:
        return 28;
    }
  }

  double get _onlineIndicatorSize {
    switch (size) {
      case AvatarSize.sm:
        return 8;
      case AvatarSize.md:
        return 10;
      case AvatarSize.lg:
        return 12;
      case AvatarSize.xl:
        return 14;
    }
  }

  Color get _backgroundColor {
    final colors = [
      DSColors.volt,
      DSColors.voltLight,
      DSColors.cyan,
      DSColors.green,
      DSColors.indigo,
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, min(2, parts.first.length)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _dimension,
      height: _dimension,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: _dimension,
            height: _dimension,
            decoration: BoxDecoration(
              color: _backgroundColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: TextStyle(
                color: DSColors.onBrand,
                fontSize: _fontSize,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          if (showOnlineIndicator)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: _onlineIndicatorSize,
                height: _onlineIndicatorSize,
                decoration: BoxDecoration(
                  color: DSColors.onSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DSColors.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

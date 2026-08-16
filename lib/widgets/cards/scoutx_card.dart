import 'package:flutter/material.dart';
import '../../design_system.dart';

class SXCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool elevateOnHover;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const SXCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.elevateOnHover = true,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  State<SXCard> createState() => _SXCardState();
}

class _SXCardState extends State<SXCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final card = MouseRegion(
      onEnter: widget.elevateOnHover ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.elevateOnHover ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DSMotion.fast,
          curve: DSMotion.easeOut,
          margin: widget.margin,
          padding: widget.padding ?? const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? DSColors.surface,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(DSRadius.card),
            border: Border.all(
              color: _isHovered ? DSColors.outline : DSColors.outlineVariant,
              width: 1,
            ),
            boxShadow: _isHovered ? DSElevation.level2 : DSElevation.level1,
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap != null) {
      return card;
    }
    return MouseRegion(
      onEnter: widget.elevateOnHover ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.elevateOnHover ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: DSMotion.fast,
        curve: DSMotion.easeOut,
        margin: widget.margin,
        padding: widget.padding ?? const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? DSColors.surface,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(DSRadius.card),
          border: Border.all(
            color: _isHovered ? DSColors.outline : DSColors.outlineVariant,
            width: 1,
          ),
          boxShadow: _isHovered ? DSElevation.level2 : DSElevation.level1,
        ),
        child: widget.child,
      ),
    );
  }
}

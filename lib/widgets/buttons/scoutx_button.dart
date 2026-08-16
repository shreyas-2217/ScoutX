import 'package:flutter/material.dart';
import '../../design_system.dart';

enum SXButtonVariant { primary, secondary, ghost, destructive }
enum SXButtonSize { sm, md, lg }

class SXButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final SXButtonVariant variant;
  final SXButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool loading;
  final bool fullWidth;

  const SXButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SXButtonVariant.primary,
    this.size = SXButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = false,
  });

  @override
  State<SXButton> createState() => _SXButtonState();
}

class _SXButtonState extends State<SXButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.loading;

  double get _height {
    switch (widget.size) {
      case SXButtonSize.sm:
        return 36;
      case SXButtonSize.md:
        return 44;
      case SXButtonSize.lg:
        return 52;
    }
  }

  double get _horizontalPadding {
    switch (widget.size) {
      case SXButtonSize.sm:
        return 12;
      case SXButtonSize.md:
        return 16;
      case SXButtonSize.lg:
        return 20;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case SXButtonSize.sm:
        return 16;
      case SXButtonSize.md:
        return 18;
      case SXButtonSize.lg:
        return 20;
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case SXButtonSize.sm:
        return const TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
      case SXButtonSize.md:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      case SXButtonSize.lg:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    }
  }

  Color get _backgroundColor {
    if (!_isEnabled) {
      switch (widget.variant) {
        case SXButtonVariant.primary:
          return DSColors.volt.withValues(alpha: 0.5);
        case SXButtonVariant.secondary:
          return Colors.transparent;
        case SXButtonVariant.ghost:
          return Colors.transparent;
        case SXButtonVariant.destructive:
          return DSColors.red.withValues(alpha: 0.5);
      }
    }

    if (_isHovered && !_isPressed) {
      switch (widget.variant) {
        case SXButtonVariant.primary:
          return DSColors.voltDark;
        case SXButtonVariant.secondary:
          return DSColors.surfaceContainer;
        case SXButtonVariant.ghost:
          return DSColors.surfaceContainer;
        case SXButtonVariant.destructive:
          return const Color(0xFFD32F2F);
      }
    }

    if (_isPressed) {
      switch (widget.variant) {
        case SXButtonVariant.primary:
          return DSColors.voltDark;
        case SXButtonVariant.secondary:
          return DSColors.surfaceContainerHigh;
        case SXButtonVariant.ghost:
          return DSColors.surfaceContainerHigh;
        case SXButtonVariant.destructive:
          return const Color(0xFFC62828);
      }
    }

    switch (widget.variant) {
      case SXButtonVariant.primary:
        return DSColors.volt;
      case SXButtonVariant.secondary:
        return Colors.transparent;
      case SXButtonVariant.ghost:
        return Colors.transparent;
      case SXButtonVariant.destructive:
        return DSColors.red;
    }
  }

  Color get _foregroundColor {
    if (!_isEnabled) {
      return DSColors.onSurfaceDisabled;
    }
    switch (widget.variant) {
      case SXButtonVariant.primary:
        return DSColors.onBrand;
      case SXButtonVariant.secondary:
        return DSColors.onSurface;
      case SXButtonVariant.ghost:
        return DSColors.onSurface;
      case SXButtonVariant.destructive:
        return DSColors.onError;
    }
  }

  Color get _spinnerColor {
    switch (widget.variant) {
      case SXButtonVariant.primary:
      case SXButtonVariant.destructive:
        return DSColors.onBrand;
      case SXButtonVariant.secondary:
      case SXButtonVariant.ghost:
        return DSColors.onSurface;
    }
  }

  Border? get _border {
    if (widget.variant == SXButtonVariant.secondary) {
      if (!_isEnabled) {
        return Border.all(color: DSColors.outline.withValues(alpha: 0.5), width: 1.5);
      }
      if (_isPressed) {
        return Border.all(color: DSColors.volt.withValues(alpha: 0.4), width: 1.5);
      }
      return Border.all(color: DSColors.outline, width: 1.5);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: _isEnabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: DSMotion.press,
          curve: DSMotion.easeOut,
          child: AnimatedContainer(
            duration: DSMotion.fast,
            curve: DSMotion.easeOut,
            height: _height,
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(DSRadius.button),
              border: _border,
            ),
            child: Row(
              mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.loading) ...[
                  SizedBox(
                    width: _iconSize,
                    height: _iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_spinnerColor),
                    ),
                  ),
                  SizedBox(width: DSSpacing.sm),
                ] else if (widget.leadingIcon != null) ...[
                  Icon(widget.leadingIcon, size: _iconSize, color: _foregroundColor),
                  SizedBox(width: DSSpacing.xs),
                ],
                if (!widget.loading || widget.label.isNotEmpty)
                  Text(
                    widget.label,
                    style: _textStyle.copyWith(color: _foregroundColor),
                  ),
                if (widget.trailingIcon != null && !widget.loading) ...[
                  SizedBox(width: DSSpacing.xs),
                  Icon(widget.trailingIcon, size: _iconSize, color: _foregroundColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

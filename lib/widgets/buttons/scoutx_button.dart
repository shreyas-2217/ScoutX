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

  Color _backgroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!_isEnabled) {
      switch (widget.variant) {
        case SXButtonVariant.primary:
          return scheme.onSurface.withValues(alpha: 0.12);
        case SXButtonVariant.secondary:
        case SXButtonVariant.ghost:
          return Colors.transparent;
        case SXButtonVariant.destructive:
          return scheme.error.withValues(alpha: 0.12);
      }
    }
    if (_isHovered && !_isPressed) {
      switch (widget.variant) {
        case SXButtonVariant.primary:
          return scheme.onSurface.withValues(alpha: 0.92);
        case SXButtonVariant.secondary:
        case SXButtonVariant.ghost:
          return scheme.surfaceContainerHighest;
        case SXButtonVariant.destructive:
          return scheme.error.withValues(alpha: 0.9);
      }
    }
    if (_isPressed) {
      switch (widget.variant) {
        case SXButtonVariant.primary:
          return scheme.onSurface.withValues(alpha: 0.84);
        case SXButtonVariant.secondary:
        case SXButtonVariant.ghost:
          return scheme.surfaceContainerHigh;
        case SXButtonVariant.destructive:
          return scheme.error.withValues(alpha: 0.85);
      }
    }
    switch (widget.variant) {
      case SXButtonVariant.primary:
        return scheme.onSurface;
      case SXButtonVariant.secondary:
      case SXButtonVariant.ghost:
        return Colors.transparent;
      case SXButtonVariant.destructive:
        return scheme.error;
    }
  }

  Color _foregroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!_isEnabled) {
      return scheme.onSurface.withValues(alpha: 0.38);
    }
    switch (widget.variant) {
      case SXButtonVariant.primary:
        return scheme.surface;
      case SXButtonVariant.secondary:
      case SXButtonVariant.ghost:
        return scheme.onSurface;
      case SXButtonVariant.destructive:
        return scheme.onError;
    }
  }

  Color _spinnerColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (widget.variant) {
      case SXButtonVariant.primary:
      case SXButtonVariant.destructive:
        return scheme.surface;
      case SXButtonVariant.secondary:
      case SXButtonVariant.ghost:
        return scheme.onSurface;
    }
  }

  Border? _border(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (widget.variant == SXButtonVariant.secondary) {
      if (!_isEnabled) {
        return Border.all(color: scheme.outline.withValues(alpha: 0.5), width: 1.5);
      }
      if (_isPressed) {
        return Border.all(color: scheme.onSurface.withValues(alpha: 0.4), width: 1.5);
      }
      return Border.all(color: scheme.outline, width: 1.5);
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
              color: _backgroundColor(context),
              borderRadius: BorderRadius.circular(DSRadius.button),
              border: _border(context),
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
                      valueColor: AlwaysStoppedAnimation<Color>(_spinnerColor(context)),
                    ),
                  ),
                  SizedBox(width: DSSpacing.sm),
                ] else if (widget.leadingIcon != null) ...[
                  Icon(widget.leadingIcon, size: _iconSize, color: _foregroundColor(context)),
                  SizedBox(width: DSSpacing.xs),
                ],
                if (!widget.loading || widget.label.isNotEmpty)
                  Text(
                    widget.label,
                    style: _textStyle.copyWith(color: _foregroundColor(context)),
                  ),
                if (widget.trailingIcon != null && !widget.loading) ...[
                  SizedBox(width: DSSpacing.xs),
                  Icon(widget.trailingIcon, size: _iconSize, color: _foregroundColor(context)),
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

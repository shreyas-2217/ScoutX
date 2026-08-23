import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:scoutx/design_system.dart';
export '../../design_system.dart';

class BrandLogo extends StatefulWidget {
  final double markSize;
  final double fontSize;
  final Color? textColor;
  final bool animate;

  const BrandLogo({
    super.key,
    this.markSize = 40,
    this.fontSize = 24,
    this.textColor,
    this.animate = true,
  });

  @override
  State<BrandLogo> createState() => _BrandLogoState();
}

class _BrandLogoState extends State<BrandLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.normal,
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Force high-contrast: pure white/black, never blends with bg
    final markBg = isDark ? Colors.white : const Color(0xFF1C1B1B);
    final markIcon = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    final textCol = widget.textColor ?? (isDark ? Colors.white : const Color(0xFF1C1B1B));
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Opacity(
            opacity: _opacityAnim.value,
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.markSize,
            height: widget.markSize,
            decoration: BoxDecoration(
              color: markBg,
              borderRadius: BorderRadius.circular(widget.markSize * 0.28),
              boxShadow: const [
                BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
              border: Border.all(
                color: isDark ? const Color(0x4DFFFFFF) : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Icon(
              DSIcons.brand,
              color: markIcon,
              size: widget.markSize * 0.55,
            ),
          ),
          SizedBox(width: DSSpacing.sm),
          Text(
            'ScoutX',
            style: GoogleFonts.sora(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.32,
              color: textCol,
            ),
          ),
        ],
      ),
    );
  }
}

enum DSButtonVariant { filled, outlined, text, tonal, elevated }

class DSButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool loading;
  final bool fullWidth;
  final DSButtonVariant variant;
  final Color? customColor;
  final EdgeInsetsGeometry? padding;

  const DSButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = false,
    this.variant = DSButtonVariant.filled,
    this.customColor,
    this.padding,
  });

  @override
  State<DSButton> createState() => _DSButtonState();
}

class _DSButtonState extends State<DSButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
    pressed ? _controller.forward() : _controller.reverse();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.press,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.barlowCondensed(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.32,
      color: Theme.of(context).colorScheme.surface,
    );
    
    final isDisabled = widget.onPressed == null || widget.loading;
    final color = widget.customColor ?? Theme.of(context).colorScheme.onSurface;
    
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading) ...[
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: widget.variant == DSButtonVariant.filled 
                  ? Theme.of(context).colorScheme.surface 
                  : color,
            ),
          ),
        ] else ...[
          if (widget.leadingIcon != null) ...[
            Icon(widget.leadingIcon, size: 20),
            SizedBox(width: DSSpacing.sm),
          ],
          Text(widget.label, style: textStyle),
          if (widget.trailingIcon != null) ...[
            SizedBox(width: DSSpacing.sm),
            Icon(widget.trailingIcon, size: 20),
          ],
        ],
      ],
    );

    Widget button;
    final borderRadius = BorderRadius.circular(DSRadius.button);
    final horizontalPadding = widget.padding?.horizontal ?? DSSpacing.lg;
    final verticalPadding = widget.padding?.vertical ?? DSSpacing.md;

    switch (widget.variant) {
      case DSButtonVariant.filled:
        button = _FilledButton(
          content: content,
          color: color,
          onPressed: isDisabled ? null : widget.onPressed,
          loading: widget.loading,
          fullWidth: widget.fullWidth,
          borderRadius: borderRadius,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          pressed: _pressed,
        );
        break;
      case DSButtonVariant.outlined:
        button = _OutlinedButton(
          content: content,
          color: color,
          onPressed: isDisabled ? null : widget.onPressed,
          loading: widget.loading,
          fullWidth: widget.fullWidth,
          borderRadius: borderRadius,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          pressed: _pressed,
        );
        break;
      case DSButtonVariant.text:
        button = _TextButton(
          content: content,
          color: color,
          onPressed: isDisabled ? null : widget.onPressed,
          loading: widget.loading,
          fullWidth: widget.fullWidth,
          borderRadius: borderRadius,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          pressed: _pressed,
        );
        break;
      case DSButtonVariant.tonal:
        button = _TonalButton(
          content: content,
          color: color,
          onPressed: isDisabled ? null : widget.onPressed,
          loading: widget.loading,
          fullWidth: widget.fullWidth,
          borderRadius: borderRadius,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          pressed: _pressed,
        );
        break;
      case DSButtonVariant.elevated:
        button = _ElevatedButton(
          content: content,
          color: color,
          onPressed: isDisabled ? null : widget.onPressed,
          loading: widget.loading,
          fullWidth: widget.fullWidth,
          borderRadius: borderRadius,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          pressed: _pressed,
        );
        break;
    }

    // Listener (not GestureDetector) so raw pointer events never compete
    // with the inner InkWell's tap recognizer.
    return Listener(
      onPointerDown: isDisabled ? null : (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _scaleAnim.value,
        duration: DSMotion.press,
        curve: DSMotion.easeOut,
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.5 : 1.0,
          duration: DSMotion.fast,
          child: button,
        ),
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  final Widget content;
  final Color color;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool pressed;

  const _FilledButton({
    required this.content,
    required this.color,
    this.onPressed,
    required this.loading,
    required this.fullWidth,
    required this.borderRadius,
    required this.padding,
    required this.pressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      height: 52,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: borderRadius,
          splashColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
          highlightColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
          child: Center(child: content),
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final Widget content;
  final Color color;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool pressed;

  const _OutlinedButton({
    required this.content,
    required this.color,
    this.onPressed,
    required this.loading,
    required this.fullWidth,
    required this.borderRadius,
    required this.padding,
    required this.pressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      height: 52,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
        color: pressed ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04) : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: borderRadius,
          splashColor: color.withValues(alpha: 0.08),
          highlightColor: color.withValues(alpha: 0.04),
          child: Center(child: content),
        ),
      ),
    );
  }
}

class _TextButton extends StatelessWidget {
  final Widget content;
  final Color color;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool pressed;

  const _TextButton({
    required this.content,
    required this.color,
    this.onPressed,
    required this.loading,
    required this.fullWidth,
    required this.borderRadius,
    required this.padding,
    required this.pressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      height: 44,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: pressed ? color.withValues(alpha: 0.06) : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: borderRadius,
          splashColor: color.withValues(alpha: 0.08),
          highlightColor: color.withValues(alpha: 0.04),
          child: Center(child: content),
        ),
      ),
    );
  }
}

class _TonalButton extends StatelessWidget {
  final Widget content;
  final Color color;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool pressed;

  const _TonalButton({
    required this.content,
    required this.color,
    this.onPressed,
    required this.loading,
    required this.fullWidth,
    required this.borderRadius,
    required this.padding,
    required this.pressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      height: 52,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: color.withValues(alpha: pressed ? 0.18 : 0.10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: borderRadius,
          splashColor: color.withValues(alpha: 0.12),
          highlightColor: color.withValues(alpha: 0.08),
          child: Center(child: content),
        ),
      ),
    );
  }
}

class _ElevatedButton extends StatelessWidget {
  final Widget content;
  final Color color;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool pressed;

  const _ElevatedButton({
    required this.content,
    required this.color,
    this.onPressed,
    required this.loading,
    required this.fullWidth,
    required this.borderRadius,
    required this.padding,
    required this.pressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      height: 52,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: pressed ? DSElevation.level1 : DSElevation.level2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: borderRadius,
          splashColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
          highlightColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
          child: Center(child: content),
        ),
      ),
    );
  }
}

class SectionHeader extends StatefulWidget {
  final String text;
  final bool tint;
  final bool animate;

  const SectionHeader({
    super.key,
    required this.text,
    this.tint = true,
    this.animate = true,
  });

  @override
  State<SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<SectionHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.normal,
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: DSMotion.easeOut));
    
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.translate(
            offset: _slideAnim.value * 20,
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          if (widget.tint) ...[
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface,
                borderRadius: BorderRadius.circular(DSRadius.xs),
              ),
            ),
            SizedBox(width: DSSpacing.sm),
          ],
          Text(
            widget.text,
            style: GoogleFonts.barlowCondensed(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.32,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class InitialsAvatar extends StatefulWidget {
  final String name;
  final double radius;
  final bool pulse;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.radius = 24,
    this.pulse = false,
  });

  @override
  State<InitialsAvatar> createState() => _InitialsAvatarState();
}

class _InitialsAvatarState extends State<InitialsAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    if (widget.pulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials(widget.name);
    // High-contrast, theme-visible palette (saturated, works on light & dark)
    const palette = [
      Color(0xFF1E88E5),
      Color(0xFF43A047),
      Color(0xFFE53935),
      Color(0xFF8E24AA),
      Color(0xFFFB8C00),
      Color(0xFF00897B),
      Color(0xFF3949AB),
    ];
    final color = palette[widget.name.hashCode.abs() % palette.length];

    Widget avatar = CircleAvatar(
      radius: widget.radius,
      backgroundColor: color.withValues(alpha: 0.14),
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: widget.radius * 0.7,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    if (widget.pulse) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnim.value,
            child: child,
          );
        },
        child: avatar,
      );
    }
    return avatar;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class EmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool animate;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.animate = true,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.slow,
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: DSMotion.easeOut));
    
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.translate(
            offset: _slideAnim.value * 30,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: child,
            ),
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(DSSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon, 
                  size: DSIconSize.emptyState, 
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: DSSpacing.lg),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.subtitle != null) ...[
                SizedBox(height: DSSpacing.sm),
                Text(
                  widget.subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (widget.action != null) ...[
                SizedBox(height: DSSpacing.lg),
                widget.action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TagChip extends StatefulWidget {
  final String text;
  final Color? color;
  final VoidCallback? onTap;
  final bool removable;
  final VoidCallback? onRemoved;

  const TagChip({
    super.key,
    required this.text,
    this.color,
    this.onTap,
    this.removable = false,
    this.onRemoved,
  });

  @override
  State<TagChip> createState() => _TagChipState();
}

class _TagChipState extends State<TagChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.press,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = widget.color ?? Theme.of(context).colorScheme.onSurface;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _scaleAnim.value,
        duration: DSMotion.press,
        curve: DSMotion.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm + 2,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: chipColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(DSRadius.chip),
            border: Border.all(
              color: chipColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: chipColor,
                ),
              ),
              if (widget.removable) ...[
                SizedBox(width: DSSpacing.xs),
                GestureDetector(
                  onTap: widget.onRemoved,
                  child: Icon(
                     DSIcons.x,
                    size: DSIconSize.xs,
                    color: chipColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  final double size;
  final bool animate;

  const VerifiedBadge({
    super.key,
    this.size = 16,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget badge = Icon(
      DSIcons.sealCheck,
      size: size,
      color: Theme.of(context).colorScheme.onSurface,
    );
    
    if (animate) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: DSMotion.normal,
        curve: DSMotion.easeOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(opacity: value, child: child),
          );
        },
        child: badge,
      );
    }
    return badge;
  }
}

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double spacing;

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.spacing = 48,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _overflowing = false;
  double _textWidth = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _layout(double available) {
    final textWidth = _measureText();
    final overflowing = textWidth > available;
    if (overflowing != _overflowing || textWidth != _textWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _overflowing = overflowing;
          _textWidth = textWidth;
        });
        if (overflowing) {
          _controller.repeat();
        } else {
          _controller.stop();
          _controller.value = 0;
        }
      });
    }
  }

  double _measureText() {
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _layout(constraints.maxWidth);
        if (!_overflowing) {
          return Text(
            widget.text,
            style: widget.style,
            overflow: TextOverflow.ellipsis,
          );
        }
        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FractionalTranslation(
                translation: Offset(-_controller.value, 0),
                child: child,
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.text, style: widget.style),
                SizedBox(width: widget.spacing),
                Text(widget.text, style: widget.style),
                SizedBox(width: widget.spacing),
                Text(widget.text, style: widget.style),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DSCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool elevated;
  final Color? color;
  final List<BoxShadow>? shadows;
  final BorderRadius? borderRadius;
  final bool animate;

  const DSCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevated = false,
    this.color,
    this.shadows,
    this.borderRadius,
    this.animate = true,
  });

  @override
  State<DSCard> createState() => _DSCardState();
}

class _DSCardState extends State<DSCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.normal,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.01).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme-aware so cards stay readable in dark mode (a hardcoded light
    // surface made light-on-light text everywhere in dark theme).
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = widget.color ?? colorScheme.surface;
    final cardRadius = widget.borderRadius ?? 
        BorderRadius.circular(DSRadius.card);
    final cardShadows = widget.elevated 
        ? (widget.shadows ?? DSElevation.cardShadow) 
        : (widget.shadows ?? const []);

    Widget card = Container(
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: cardRadius,
        boxShadow: cardShadows,
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      card = MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnim.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: cardRadius,
                    boxShadow: _hovered || _controller.isAnimating
                        ? DSElevation.level2
                        : cardShadows,
                  ),
                  child: child,
                ),
              );
            },
            child: card,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _opacityAnim.value) * 20),
            child: child,
          ),
        );
      },
      child: card,
    );
  }
}

class ShimmerPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.shimmer,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Theme.of(context).colorScheme.surfaceContainer;
    final highlightColor = widget.highlightColor ?? 
        Theme.of(context).colorScheme.surfaceContainerHigh;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(DSRadius.md),
            gradient: LinearGradient(
              begin: Alignment(-1.0, 0.0),
              end: Alignment(1.0, 0.0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((v) => v.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Axis axis;
  final double spacing;
  final Duration staggerDelay;
  final Duration animationDuration;
  final Curve curve;

  const StaggeredList({
    super.key,
    required this.children,
    this.axis = Axis.vertical,
    this.spacing = DSSpacing.md,
    this.staggerDelay = DSMotion.listItemStagger,
    this.animationDuration = DSMotion.normal,
    this.curve = DSMotion.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(children.length, (index) {
        return StaggeredItem(
          index: index,
          delay: staggerDelay * index,
          duration: animationDuration,
          curve: curve,
          child: Padding(
            padding: axis == Axis.vertical
                ? EdgeInsets.only(bottom: index == children.length - 1 ? 0 : spacing)
                : EdgeInsets.only(right: index == children.length - 1 ? 0 : spacing),
            child: children[index],
          ),
        );
      }),
    );
  }
}

class StaggeredItem extends StatefulWidget {
  final int index;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Widget child;

  const StaggeredItem({
    super.key,
    required this.index,
    required this.delay,
    required this.duration,
    this.curve = DSMotion.easeOut,
    required this.child,
  });

  @override
  State<StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.translate(
            offset: _slideAnim.value * 30,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class AnimatedPage extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedPage({
    super.key,
    required this.child,
    this.duration = DSMotion.pageTransition,
    this.curve = DSMotion.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class DSHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final Widget? placeholderBuilder;

  const DSHero({
    super.key,
    required this.tag,
    required this.child,
    this.placeholderBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: animation.value,
              child: Transform.scale(
                scale: 0.95 + (0.05 * animation.value),
                child: toHeroContext.widget,
              ),
            );
          },
        );
      },
      placeholderBuilder: (context, size, widget) {
        return placeholderBuilder ?? 
            Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
            );
      },
      child: child,
    );
  }
}

class AnimatedShellContent extends StatefulWidget {
  final List<Widget> screens;
  final int currentIndex;
  final Duration duration;
  final Curve curve;

  const AnimatedShellContent({
    super.key,
    required this.screens,
    required this.currentIndex,
    this.duration = DSMotion.pageTransition,
    this.curve = DSMotion.easeOut,
  });

  @override
  State<AnimatedShellContent> createState() => _AnimatedShellContentState();
}

class _AnimatedShellContentState extends State<AnimatedShellContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AnimatedShellContent oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.duration,
      switchInCurve: widget.curve,
      switchOutCurve: widget.curve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final inAnimation = CurvedAnimation(
          parent: animation,
          curve: widget.curve,
          reverseCurve: widget.curve,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(inAnimation),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1.0).animate(inAnimation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(inAnimation),
              child: child,
            ),
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(widget.currentIndex),
        child: widget.screens[widget.currentIndex],
      ),
    );
  }
}

String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dt.day}/${dt.month}/${dt.year}';
}

class DSNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<DSNavItem> items;

  const DSNavBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(
                child: _NavBarItem(
                  item: items[i],
                  selected: i == selectedIndex,
                  onTap: () => onSelected(i),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DSNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const DSNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavBarItem extends StatefulWidget {
  final DSNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.fast,
    );
    _slideAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
  }

  @override
  void didUpdateWidget(_NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected && widget.selected) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selected;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_controller.value * 0.08),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(DSRadius.lg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? widget.item.activeIcon : widget.item.icon,
                    color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: DSIconSize.bottomNav,
                  ),
                  const SizedBox(height: 4),
                  AnimatedSlide(
                    offset: Offset(0, _slideAnim.value * 0.5),
                    duration: DSMotion.fast,
                    child: Text(
                      widget.item.label,
                      style: (Theme.of(context).textTheme.labelSmall ??
                              const TextStyle(fontSize: 12))
                          .copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ConstrainedContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = 720,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width <= maxWidth) {
          return child;
        }
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}

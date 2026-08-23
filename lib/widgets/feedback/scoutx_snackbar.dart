import 'package:flutter/material.dart';
import '../../design_system.dart';

enum SnackBarType { success, error, info }

class SXSnackBar {
  static void show(BuildContext context, String message, {SnackBarType type = SnackBarType.info}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _SXSnackBarWidget(
        message: message,
        type: type,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  static void success(BuildContext context, String message) {
    show(context, message, type: SnackBarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message, type: SnackBarType.error);
  }

  static void info(BuildContext context, String message) {
    show(context, message, type: SnackBarType.info);
  }
}

class _SXSnackBarWidget extends StatefulWidget {
  final String message;
  final SnackBarType type;
  final VoidCallback onDismiss;

  const _SXSnackBarWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_SXSnackBarWidget> createState() => _SXSnackBarWidgetState();
}

class _SXSnackBarWidgetState extends State<_SXSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.fast,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case SnackBarType.success:
        return DSColors.voltSurface;
      case SnackBarType.error:
        return const Color(0xFFFFEBEE);
      case SnackBarType.info:
        return const Color(0xFFE3F2FD);
    }
  }

  Color get _iconColor {
    switch (widget.type) {
      case SnackBarType.success:
        return DSColors.volt;
      case SnackBarType.error:
        return Theme.of(context).colorScheme.error;
      case SnackBarType.info:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  Color get _textColor {
    switch (widget.type) {
      case SnackBarType.success:
        return DSColors.voltDark;
      case SnackBarType.error:
        return const Color(0xFFC62828);
      case SnackBarType.info:
        return const Color(0xFF1565C0);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case SnackBarType.success:
        return DSIcons.checkCircle;
      case SnackBarType.error:
        return DSIcons.xCircle;
      case SnackBarType.info:
        return DSIcons.info;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + DSSpacing.sm,
      left: DSSpacing.md,
      right: DSSpacing.md,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.md,
                  vertical: DSSpacing.sm + 4,
                ),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(DSRadius.lg),
                  border: Border.all(
                    color: _iconColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: DSElevation.level2,
                ),
                child: Row(
                  children: [
                    Icon(_icon, size: 20, color: _iconColor),
                    const SizedBox(width: DSSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(DSIcons.close, size: 16, color: _textColor.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

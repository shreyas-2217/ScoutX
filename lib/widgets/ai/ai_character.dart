import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';

enum AICharacterState { idle, thinking, success, error, greeting }

class AICharacter extends StatelessWidget {
  final AICharacterState state;
  final double size;

  const AICharacter({
    super.key,
    this.state = AICharacterState.idle,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.onSurface, Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.75,
            height: size * 0.75,
            decoration: BoxDecoration(
              color: DSColors.voltDark,
              shape: BoxShape.circle,
            ),
          ),
          Icon(
            _getIcon(),
            color: Colors.white,
            size: size * 0.4,
          ),
          if (state == AICharacterState.thinking)
            Positioned(
              bottom: size * 0.05,
              child: _ThinkingDots(size: size * 0.15),
            ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (state) {
      case AICharacterState.idle:
        return Icons.auto_awesome;
      case AICharacterState.thinking:
        return Icons.psychology;
      case AICharacterState.success:
        return Icons.check_circle_outline;
      case AICharacterState.error:
        return Icons.error_outline;
      case AICharacterState.greeting:
        return Icons.waving_hand;
    }
  }
}

class _ThinkingDots extends StatefulWidget {
  final double size;
  const _ThinkingDots({required this.size});

  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
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
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.3;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity =
                (value < 0.5 ? value * 2 : (1 - value) * 2).clamp(0.3, 1.0);
            return Container(
              width: widget.size,
              height: widget.size,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

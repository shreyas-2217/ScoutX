import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider.dart';

class ScoutXAIFloatingButton extends StatefulWidget {
  const ScoutXAIFloatingButton({super.key});

  @override
  State<ScoutXAIFloatingButton> createState() => _ScoutXAIFloatingButtonState();
}

class _ScoutXAIFloatingButtonState extends State<ScoutXAIFloatingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AIProvider>();
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Use inverseSurface so button contrasts with background in both modes
    final btnColor = isDark ? scheme.inverseSurface : scheme.onSurface;
    final iconColor = isDark ? scheme.onInverseSurface : scheme.surface;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => ai.toggleOpen(),
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            final scale = ai.isOpen ? 1.0 : _pulseAnim.value;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [btnColor, btnColor.withValues(alpha: 0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: btnColor.withValues(alpha: ai.isOpen ? 0.35 : 0.22),
                      blurRadius: ai.isOpen ? 20 : 12,
                      spreadRadius: ai.isOpen ? 4 : 2,
                    ),
                  ],
                ),
                child: Icon(
                  ai.isOpen ? Icons.close : Icons.auto_awesome,
                  color: iconColor,
                  size: 24,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

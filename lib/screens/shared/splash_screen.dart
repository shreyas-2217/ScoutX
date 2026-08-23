import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:scoutx/design_system.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _taglineSlide;
  late final Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.slowest,
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );

    _titleSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );

    _taglineSlide = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );

    _controller.forward();
    Future.delayed(DSMotion.slowest, () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: DSColors.surface),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -100,
              child: _glow(DSColors.onSurface.withValues(alpha: 0.05)),
            ),
            Positioned(
              bottom: -140,
              left: -120,
              child: _glow(DSColors.onSurface.withValues(alpha: 0.03)),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: DSColors.onSurface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: DSElevation.level1,
                            ),
                            child: Icon(
                              DSIcons.brand,
                              color: DSColors.surface,
                              size: 52,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Transform.translate(
                        offset: Offset(0, _titleSlide.value),
                        child: Opacity(
                          opacity: _titleOpacity.value,
                          child: Text(
                            'ScoutX',
                            style: GoogleFonts.sora(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              color: DSColors.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Transform.translate(
                        offset: Offset(0, _taglineSlide.value),
                        child: Opacity(
                          opacity: _taglineOpacity.value,
                          child: Text(
                            'Find your next player. Get scouted.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: DSColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(Color color) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.5 + (_controller.value * 0.5),
            child: child,
          );
        },
        child: Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.12),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

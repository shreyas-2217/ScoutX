import 'package:flutter/material.dart';
import '../../design_system.dart';

class _Shimmer extends StatefulWidget {
  final Widget child;

  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final dx = _controller.value * 2 - 1;
            return LinearGradient(
              begin: Alignment(-1.0 + dx, 0),
              end: Alignment(0.0 + dx, 0),
              colors: const [
                DSColors.surfaceContainer,
                DSColors.surfaceContainerHigh,
                DSColors.surfaceContainer,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: DSColors.surfaceContainer,
          borderRadius: borderRadius ?? BorderRadius.circular(DSRadius.md),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double? height;

  const SkeletonCard({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        height: height ?? 200,
        decoration: BoxDecoration(
          color: DSColors.surfaceContainer,
          borderRadius: BorderRadius.circular(DSRadius.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 120, height: 16, borderRadius: BorderRadius.circular(DSRadius.sm)),
              const SizedBox(height: DSSpacing.sm),
              SkeletonBox(width: double.infinity, height: 14, borderRadius: BorderRadius.circular(DSRadius.sm)),
              const SizedBox(height: DSSpacing.xs),
              SkeletonBox(width: 200, height: 14, borderRadius: BorderRadius.circular(DSRadius.sm)),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
        child: Row(
          children: [
            SkeletonBox(
              width: 40,
              height: 40,
              borderRadius: BorderRadius.circular(DSRadius.full),
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 140, height: 14, borderRadius: BorderRadius.circular(DSRadius.sm)),
                  const SizedBox(height: DSSpacing.xs),
                  SkeletonBox(width: 200, height: 12, borderRadius: BorderRadius.circular(DSRadius.sm)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonTrialCard extends StatelessWidget {
  const SkeletonTrialCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        decoration: BoxDecoration(
          color: DSColors.surfaceContainer,
          borderRadius: BorderRadius.circular(DSRadius.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(width: 40, height: 40, borderRadius: BorderRadius.circular(DSRadius.full)),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 120, height: 14, borderRadius: BorderRadius.circular(DSRadius.sm)),
                        const SizedBox(height: DSSpacing.xs),
                        SkeletonBox(width: 80, height: 12, borderRadius: BorderRadius.circular(DSRadius.sm)),
                      ],
                    ),
                  ),
                  SkeletonBox(width: 60, height: 24, borderRadius: BorderRadius.circular(DSRadius.chip)),
                ],
              ),
              const SizedBox(height: DSSpacing.md),
              SkeletonBox(width: double.infinity, height: 14, borderRadius: BorderRadius.circular(DSRadius.sm)),
              const SizedBox(height: DSSpacing.xs),
              SkeletonBox(width: 240, height: 14, borderRadius: BorderRadius.circular(DSRadius.sm)),
              const SizedBox(height: DSSpacing.md),
              Row(
                children: [
                  SkeletonBox(width: 80, height: 24, borderRadius: BorderRadius.circular(DSRadius.chip)),
                  const SizedBox(width: DSSpacing.sm),
                  SkeletonBox(width: 80, height: 24, borderRadius: BorderRadius.circular(DSRadius.chip)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonProfileHeader extends StatelessWidget {
  const SkeletonProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Center(
        child: Column(
          children: [
            SkeletonBox(
              width: 80,
              height: 80,
              borderRadius: BorderRadius.circular(DSRadius.full),
            ),
            const SizedBox(height: DSSpacing.md),
            SkeletonBox(width: 140, height: 18, borderRadius: BorderRadius.circular(DSRadius.sm)),
            const SizedBox(height: DSSpacing.sm),
            SkeletonBox(width: 100, height: 14, borderRadius: BorderRadius.circular(DSRadius.sm)),
            const SizedBox(height: DSSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBox(width: 60, height: 40, borderRadius: BorderRadius.circular(DSRadius.sm)),
                const SizedBox(width: DSSpacing.lg),
                SkeletonBox(width: 60, height: 40, borderRadius: BorderRadius.circular(DSRadius.sm)),
                const SizedBox(width: DSSpacing.lg),
                SkeletonBox(width: 60, height: 40, borderRadius: BorderRadius.circular(DSRadius.sm)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

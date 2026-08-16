import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';

class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ??
        (isDark ? DSColors.darkSurfaceContainer : DSColors.surfaceContainer);
    final highlightColor = widget.highlightColor ??
        (isDark ? DSColors.darkSurfaceContainerHigh : DSColors.surfaceContainerHigh);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DSRadius.md),
            gradient: LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = DSRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.xs),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(DSRadius.card),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonBox(width: 48, height: 48, borderRadius: 24),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 140, height: 16),
                    const SizedBox(height: DSSpacing.sm),
                    SkeletonBox(width: 100, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          SkeletonBox(width: double.infinity, height: 120),
          const SizedBox(height: DSSpacing.md),
          Row(
            children: [
              SkeletonBox(width: 60, height: 12),
              const SizedBox(width: DSSpacing.sm),
              SkeletonBox(width: 60, height: 12),
              const SizedBox(width: DSSpacing.sm),
              SkeletonBox(width: 60, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonTrialCard extends StatelessWidget {
  const SkeletonTrialCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.xs),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(DSRadius.card),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: SkeletonBox(width: double.infinity, height: 20)),
              const SizedBox(width: DSSpacing.sm),
              SkeletonBox(width: 60, height: 24, borderRadius: DSRadius.chip),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          SkeletonBox(width: 150, height: 14),
          const SizedBox(height: DSSpacing.md),
          Row(
            children: [
              SkeletonBox(width: 80, height: 28, borderRadius: DSRadius.chip),
              const SizedBox(width: DSSpacing.sm),
              SkeletonBox(width: 80, height: 28, borderRadius: DSRadius.chip),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Row(
            children: [
              const SkeletonBox(width: 16, height: 16),
              const SizedBox(width: DSSpacing.xs),
              SkeletonBox(width: 100, height: 12),
              const SizedBox(width: DSSpacing.md),
              const SkeletonBox(width: 16, height: 16),
              const SizedBox(width: DSSpacing.xs),
              SkeletonBox(width: 80, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonProfileHeader extends StatelessWidget {
  const SkeletonProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(DSSpacing.md),
      padding: const EdgeInsets.all(DSSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(DSRadius.card),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          const SkeletonBox(width: 80, height: 80, borderRadius: 40),
          const SizedBox(height: DSSpacing.md),
          SkeletonBox(width: 140, height: 20),
          const SizedBox(height: DSSpacing.sm),
          SkeletonBox(width: 100, height: 14),
          const SizedBox(height: DSSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonBox(width: 60, height: 12),
              const SizedBox(width: DSSpacing.lg),
              SkeletonBox(width: 60, height: 12),
              const SizedBox(width: DSSpacing.lg),
              SkeletonBox(width: 60, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonReelItem extends StatelessWidget {
  const SkeletonReelItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const SkeletonBox(width: double.infinity, height: double.infinity),
        Positioned(
          bottom: 100,
          left: 16,
          child: Row(
            children: [
              const SkeletonBox(width: 40, height: 40, borderRadius: 20),
              const SizedBox(width: DSSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonBox(width: 120, height: 16),
                  const SizedBox(height: DSSpacing.xs),
                  SkeletonBox(width: 80, height: 12),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              const SkeletonBox(width: 44, height: 44, borderRadius: 22),
              const SizedBox(height: DSSpacing.md),
              const SkeletonBox(width: 44, height: 44, borderRadius: 22),
              const SizedBox(height: DSSpacing.md),
              const SkeletonBox(width: 44, height: 44, borderRadius: 22),
            ],
          ),
        ),
      ],
    );
  }
}

class SkeletonMessageTile extends StatelessWidget {
  const SkeletonMessageTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Row(
        children: [
          const SkeletonBox(width: 52, height: 52, borderRadius: 26),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 16),
                const SizedBox(height: DSSpacing.sm),
                SkeletonBox(width: double.infinity, height: 14),
              ],
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          SkeletonBox(width: 50, height: 12),
        ],
      ),
    );
  }
}

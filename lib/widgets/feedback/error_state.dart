import 'package:flutter/material.dart';
import '../../design_system.dart';

class ErrorState extends StatelessWidget {
  final String? title;
  final String description;
  final String? retryLabel;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title,
    required this.description,
    this.retryLabel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                DSIcons.warningCircle,
                size: 32,
                color: DSColors.red,
              ),
            ),
            const SizedBox(height: DSSpacing.md),
            Text(
              title ?? 'Something went wrong',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DSColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: DSColors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (retryLabel != null && onRetry != null) ...[
              const SizedBox(height: DSSpacing.lg),
              Builder(
                builder: (context) => ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DSColors.volt,
                    foregroundColor: DSColors.onBrand,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.lg,
                      vertical: DSSpacing.sm + 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DSRadius.button),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    retryLabel!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

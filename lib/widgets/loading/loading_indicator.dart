import 'package:flutter/material.dart';
import '../../design_system.dart';

enum LoadingSize { small, medium, large }

class LoadingIndicator extends StatelessWidget {
  final LoadingSize size;
  final String? message;

  const LoadingIndicator({
    super.key,
    this.size = LoadingSize.medium,
    this.message,
  });

  double get _dimension {
    switch (size) {
      case LoadingSize.small:
        return 20;
      case LoadingSize.medium:
        return 32;
      case LoadingSize.large:
        return 48;
    }
  }

  double get _strokeWidth {
    switch (size) {
      case LoadingSize.small:
        return 2;
      case LoadingSize.medium:
        return 2.5;
      case LoadingSize.large:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _dimension,
            height: _dimension,
            child: CircularProgressIndicator(
              strokeWidth: _strokeWidth,
              valueColor: const AlwaysStoppedAnimation<Color>(DSColors.volt),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: size == LoadingSize.small ? DSSpacing.xs : DSSpacing.sm),
            Text(
              message!,
              style: TextStyle(
                color: DSColors.onSurfaceVariant,
                fontSize: size == LoadingSize.small ? 12 : 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FullScreenLoading extends StatelessWidget {
  final String? message;

  const FullScreenLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColors.bg,
      child: LoadingIndicator(
        size: LoadingSize.large,
        message: message,
      ),
    );
  }
}

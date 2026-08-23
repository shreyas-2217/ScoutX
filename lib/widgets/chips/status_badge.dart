import 'package:flutter/material.dart';
import '../../design_system.dart';

enum StatusType { accepted, pending, rejected }

class StatusBadge extends StatelessWidget {
  final StatusType status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = true,
  });

  Color get _backgroundColor {
    switch (status) {
      case StatusType.accepted:
        return DSColors.voltSurface;
      case StatusType.pending:
        return const Color(0xFFFFF8E1);
      case StatusType.rejected:
        return const Color(0xFFFFEBEE);
    }
  }

  Color _textColor(BuildContext context) {
    switch (status) {
      case StatusType.accepted:
        return DSColors.volt;
      case StatusType.pending:
        return DSColors.amber;
      case StatusType.rejected:
        return Theme.of(context).colorScheme.error;
    }
  }

  IconData get _icon {
    switch (status) {
      case StatusType.accepted:
        return DSIcons.check;
      case StatusType.pending:
        return DSIcons.hourglass;
      case StatusType.rejected:
        return DSIcons.close;
    }
  }

  String get _label {
    switch (status) {
      case StatusType.accepted:
        return 'Accepted';
      case StatusType.pending:
        return 'Pending';
      case StatusType.rejected:
        return 'Rejected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(DSRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: compact ? 12 : 14, color: _textColor(context)),
          SizedBox(width: compact ? 4 : 6),
          Text(
            _label,
            style: TextStyle(
              color: _textColor(context),
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';

class DistanceFilter extends StatelessWidget {
  final double? selectedDistance;
  final ValueChanged<double?> onDistanceChanged;
  final String? selectedSort;
  final ValueChanged<String?>? onSortChanged;

  static const List<Map<String, dynamic>> distances = [
    {'label': 'Near Me', 'value': 10.0},
    {'label': '5 km', 'value': 5.0},
    {'label': '10 km', 'value': 10.0},
    {'label': '25 km', 'value': 25.0},
    {'label': '50 km', 'value': 50.0},
    {'label': 'Anywhere', 'value': null},
  ];

  static const List<String> sortOptions = [
    'Nearest',
    'Latest',
    'Closing Soon',
  ];

  const DistanceFilter({
    super.key,
    this.selectedDistance,
    required this.onDistanceChanged,
    this.selectedSort,
    this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Distance chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: distances.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final d = distances[index];
                final isSelected = selectedDistance == d['value'];
                return FilterChip(
                  label: Text(d['label']),
                  selected: isSelected,
                  onSelected: (_) => onDistanceChanged(d['value']),
                  selectedColor: DSColors.volt.withValues(alpha: 0.2),
                  checkmarkColor: DSColors.volt,
                  backgroundColor: DSColors.surfaceContainerHigh,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? DSColors.volt : null,
                  ),
                  side: BorderSide(
                    color: isSelected ? DSColors.volt : DSColors.outlineVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

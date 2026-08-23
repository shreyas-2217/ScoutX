import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';

class AISuggestionChips extends StatelessWidget {
  final String role;
  final Function(String) onSuggestionTap;

  const AISuggestionChips({
    super.key,
    required this.role,
    required this.onSuggestionTap,
  });

  static const Map<String, List<String>> suggestions = {
    'player': [
      'Find football trials in my area',
      'Show me top-rated strikers',
      'How can I improve my profile?',
      'Show popular highlights',
    ],
    'coach': [
      'Search for fast wingers under 21',
      'Find trials near London',
      'Show me all goalkeepers',
      'Show popular highlights',
    ],
    'viewer': [
      'Show me top athletes',
      'Find upcoming trials',
      'Show popular highlights',
      'Who are the best strikers?',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final items = suggestions[role] ?? suggestions['viewer']!;
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((s) {
        return GestureDetector(
          onTap: () => onSuggestionTap(s),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: DSColors.onSurface.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              s,
              style: TextStyle(
                color: DSColors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

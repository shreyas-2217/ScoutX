import 'package:flutter/material.dart';
import '../constants.dart';
import '../design_system.dart';

class SkillSelector extends StatefulWidget {
  final String? sport;
  final List<String> selectedSkills;
  final ValueChanged<List<String>> onSkillsChanged;

  const SkillSelector({
    super.key,
    this.sport,
    required this.selectedSkills,
    required this.onSkillsChanged,
  });

  @override
  State<SkillSelector> createState() => _SkillSelectorState();
}

class _SkillSelectorState extends State<SkillSelector> {
  final _search = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _filtered = [];
  bool _showAddCustom = false;

  List<String> get _availableSkills {
    if (widget.sport == null) return const [];
    return AppConstants.skillLibrary[widget.sport] ?? const [];
  }

  @override
  void initState() {
    super.initState();
    _filtered = _availableSkills;
    _search.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant SkillSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sport != widget.sport) {
      _filtered = _availableSkills;
      _search.clear();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _search.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _availableSkills;
      } else {
        _filtered = _availableSkills
            .where((s) => s.toLowerCase().contains(q))
            .toList();
      }
      _showAddCustom = q.isNotEmpty &&
          !_availableSkills
              .any((s) => s.toLowerCase() == q) &&
          !widget.selectedSkills
              .any((s) => s.toLowerCase() == q);
    });
  }

  void _toggleSkill(String skill) {
    final updated = List<String>.from(widget.selectedSkills);
    final existing = updated.indexWhere(
      (s) => s.toLowerCase() == skill.toLowerCase(),
    );
    if (existing >= 0) {
      updated.removeAt(existing);
    } else {
      updated.add(skill);
    }
    widget.onSkillsChanged(updated);
  }

  void _addCustomSkill(String skill) {
    final trimmed = skill.trim();
    if (trimmed.isEmpty) return;
    if (widget.selectedSkills
        .any((s) => s.toLowerCase() == trimmed.toLowerCase())) {
      return;
    }
    final updated = List<String>.from(widget.selectedSkills);
    updated.add(trimmed);
    widget.onSkillsChanged(updated);
    _search.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sport == null) {
      return Text(
        'Select a sport first to see available skills.',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _search,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search skills...',
            prefixIcon: Icon(Icons.search, size: 20),
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSRadius.input),
              borderSide: BorderSide(color: DSColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSRadius.input),
              borderSide: BorderSide(color: DSColors.outlineVariant),
            ),
          ),
        ),
        if (widget.selectedSkills.isNotEmpty) ...[
          SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.selectedSkills.map((skill) {
              return Chip(
                label: Text(skill, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _toggleSkill(skill),
                backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.18)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSRadius.chip),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
        SizedBox(height: DSSpacing.sm),
        Container(
          constraints: BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filtered.length + (_showAddCustom ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _filtered.length && _showAddCustom) {
                final customText = _search.text.trim();
                return ListTile(
                  dense: true,
                  leading: Icon(Icons.add_circle_outline,
                      color: Theme.of(context).colorScheme.onSurface, size: 20),
                  title: Text(
                    'Add "$customText"',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => _addCustomSkill(customText),
                );
              }

              final skill = _filtered[index];
              final isSelected = widget.selectedSkills.any(
                (s) => s.toLowerCase() == skill.toLowerCase(),
              );

              return ListTile(
                dense: true,
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                title: Text(
                  skill,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () => _toggleSkill(skill),
              );
            },
          ),
        ),
      ],
    );
  }
}

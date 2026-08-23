import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/trial.dart';
import '../../models/trial_application.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../services/database.dart';
import '../../services/location_service.dart';
import '../../widgets/distance_filter.dart';
import '../shared/widgets.dart';
import '../trials/trial_detail_screen.dart';

class PlayerTrialsScreen extends StatefulWidget {
  const PlayerTrialsScreen({super.key});

  @override
  State<PlayerTrialsScreen> createState() => _PlayerTrialsScreenState();
}

class _PlayerTrialsScreenState extends State<PlayerTrialsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _sportFilter;
  String? _skillFilter;
  double? _distanceFilter;
  String _sortOption = 'Latest';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trials'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Open Trials'),
            Tab(text: 'My Applications'),
          ],
          labelColor: Theme.of(context).colorScheme.onSurface,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          indicatorColor: Theme.of(context).colorScheme.onSurface,
          indicatorWeight: 3,
          labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OpenTrialsTab(
            sportFilter: _sportFilter,
            skillFilter: _skillFilter,
            distanceFilter: _distanceFilter,
            sortOption: _sortOption,
            onSportFilterChanged: (s) => setState(() => _sportFilter = s),
            onSkillFilterChanged: (s) => setState(() => _skillFilter = s),
            onDistanceFilterChanged: (d) => setState(() => _distanceFilter = d),
            onSortChanged: (s) {
              if (s == null) return;
              setState(() => _sortOption = s);
            },
          ),
          if (uid != null) _MyApplicationsTab(uid: uid) else const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _OpenTrialsTab extends StatelessWidget {
  final String? sportFilter;
  final String? skillFilter;
  final double? distanceFilter;
  final String sortOption;
  final ValueChanged<String?> onSportFilterChanged;
  final ValueChanged<String?> onSkillFilterChanged;
  final ValueChanged<double?> onDistanceFilterChanged;
  final ValueChanged<String?> onSortChanged;

  const _OpenTrialsTab({
    this.sportFilter,
    this.skillFilter,
    this.distanceFilter,
    this.sortOption = 'Latest',
    required this.onSportFilterChanged,
    required this.onSkillFilterChanged,
    required this.onDistanceFilterChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();

    return Column(
      children: [
        // Location status bar
        if (locationProvider.hasLocation)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.onSurface),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationProvider.currentCity ?? 'Location active',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Distance filter
        if (locationProvider.hasLocation)
          DistanceFilter(
            selectedDistance: distanceFilter,
            onDistanceChanged: onDistanceFilterChanged,
            selectedSort: sortOption,
            onSortChanged: onSortChanged,
          ),

        // Filter chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _FilterChip(
                label: sportFilter ?? 'Sport',
                isSelected: sportFilter != null,
                onTap: () => _showSportFilter(context),
                onClear: sportFilter != null ? () => onSportFilterChanged(null) : null,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: skillFilter ?? 'Level',
                isSelected: skillFilter != null,
                onTap: () => _showSkillFilter(context),
                onClear: skillFilter != null ? () => onSkillFilterChanged(null) : null,
              ),
            ],
          ),
        ),

        // Trials list
        Expanded(
          child: StreamBuilder<List<Trial>>(
            stream: context.read<Database>().streamTrials(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface),
                );
              }
              var trials = snapshot.data ?? [];
              var open = trials.where((t) => t.status == 'open').toList();

              // Apply sport filter
              if (sportFilter != null) {
                open = open.where((t) => t.sport == sportFilter).toList();
              }
              // Apply skill filter
              if (skillFilter != null) {
                open = open.where((t) => t.skillLevel == skillFilter).toList();
              }

              // Apply distance filter
              if (distanceFilter != null && locationProvider.hasLocation) {
                open = open.where((t) {
                  if (t.latitude == null || t.longitude == null) return false;
                  final dist = locationProvider.distanceTo(t.latitude!, t.longitude!);
                  if (dist == null) return false;
                  return dist <= distanceFilter!;
                }).toList();
              }

              // Apply sorting
              switch (sortOption) {
                case 'Nearest':
                  double distOf(Trial t) {
                    if (!locationProvider.hasLocation ||
                        t.latitude == null ||
                        t.longitude == null) {
                      return double.infinity;
                    }
                    return locationProvider
                            .distanceTo(t.latitude!, t.longitude!) ??
                        double.infinity;
                  }

                  open.sort((a, b) => distOf(a).compareTo(distOf(b)));
                  break;
                case 'Closing Soon':
                  DateTime? dateOf(Trial t) {
                    final raw = t.date?.trim();
                    if (raw == null || raw.isEmpty) return null;
                    try {
                      return DateFormat('d MMM yyyy').parse(raw);
                    } catch (_) {}
                    return DateTime.tryParse(raw);
                  }

                  int rankOf(Trial t) {
                    final d = dateOf(t);
                    if (d == null) return 2;
                    return d.isBefore(DateTime.now()) ? 1 : 0;
                  }

                  open.sort((a, b) {
                    final rank = rankOf(a).compareTo(rankOf(b));
                    if (rank != 0) return rank;
                    return (dateOf(a) ?? DateTime(9999))
                        .compareTo(dateOf(b) ?? DateTime(9999));
                  });
                  break;
                case 'Latest':
                default:
                  open.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  break;
              }

              if (open.isEmpty) {
                return EmptyState(
                  icon: Icons.emoji_events_outlined,
                  title: distanceFilter != null
                      ? 'No trials found within ${LocationService.formatDistance(distanceFilter!)}'
                      : 'No open trials',
                  subtitle: sportFilter != null || skillFilter != null
                      ? 'No trials match your filters. Try adjusting them.'
                      : 'Check back soon for new opportunities.',
                  action: (sportFilter != null || skillFilter != null || distanceFilter != null)
                      ? DSButton(
                          label: 'Clear Filters',
                          variant: DSButtonVariant.outlined,
                          onPressed: () {
                            onSportFilterChanged(null);
                            onSkillFilterChanged(null);
                            onDistanceFilterChanged(null);
                          },
                        )
                      : null,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: open.length,
                itemBuilder: (context, index) {
                  final t = open[index];
                  return _PremiumTrialCard(trial: t);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSportFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Filter by Sport',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.sportList
                    .map((s) => FilterChip(
                          label: Text(s),
                          selected: sportFilter == s,
                          onSelected: (selected) {
                            onSportFilterChanged(selected ? s : null);
                            Navigator.pop(ctx);
                          },
                          selectedColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                          checkmarkColor: Theme.of(context).colorScheme.onSurface,
                          side: BorderSide(
                            color: sportFilter == s ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.outlineVariant,
                          ),
                      ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSkillFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Filter by Skill Level',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.skillLevels
                    .map((s) => FilterChip(
                          label: Text(s),
                          selected: skillFilter == s,
                          onSelected: (selected) {
                            onSkillFilterChanged(selected ? s : null);
                            Navigator.pop(ctx);
                          },
                          selectedColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                          checkmarkColor: Theme.of(context).colorScheme.onSurface,
                          side: BorderSide(
                            color: skillFilter == s ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Theme.of(context).colorScheme.onSurface : null,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 14, color: isSelected ? Theme.of(context).colorScheme.onSurface : null),
              ),
            ] else ...[
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ],
        ),
      ),
    );
  }
}

class _PremiumTrialCard extends StatelessWidget {
  final Trial trial;

  const _PremiumTrialCard({required this.trial});

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final distance = (trial.latitude != null && trial.longitude != null && locationProvider.hasLocation)
        ? locationProvider.distanceTo(trial.latitude!, trial.longitude!)
        : null;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TrialDetailScreen(trial: trial)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    trial.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trial.skillLevel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Coach info
            Text(
              '${trial.teamName} Â· ${trial.coachName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Tag(text: trial.sport, color: Theme.of(context).colorScheme.onSurface),
                _Tag(text: trial.position, color: Theme.of(context).colorScheme.onSurface),
              ],
            ),
            const SizedBox(height: 12),

            // Details row
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  trial.date ?? 'Flexible date',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    trial.location ?? 'Location TBD',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (distance != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      LocationService.formatDistance(distance),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Apply button
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TrialDetailScreen(trial: trial)),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('View & Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;

  const _Tag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _MyApplicationsTab extends StatelessWidget {
  final String uid;

  const _MyApplicationsTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TrialApplication>>(
      stream: context.read<Database>().streamApplicationsForPlayer(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface),
          );
        }
        final apps = snapshot.data ?? [];
        if (apps.isEmpty) {
          return EmptyState(
            icon: Icons.send_outlined,
            title: 'No applications yet',
            subtitle: 'Apply to an open trial and track its status here.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            return _ApplicationCard(application: app);
          },
        );
      },
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final TrialApplication application;

  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final color = switch (application.status) {
      'accepted' => Theme.of(context).colorScheme.onSurface,
      'rejected' => Theme.of(context).colorScheme.error,
      _ => DSColors.amber,
    };
    final icon = switch (application.status) {
      'accepted' => Icons.check_circle_outline,
      'rejected' => Icons.cancel_outlined,
      _ => Icons.hourglass_empty,
    };
    final statusLabel = switch (application.status) {
      'accepted' => 'Accepted',
      'rejected' => 'Rejected',
      _ => 'Pending',
    };

    return FutureBuilder<Trial?>(
      future: context.read<Database>().getTrial(application.trialId),
      builder: (context, snapshot) {
        final trial = snapshot.data;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trial?.title ?? 'Trial',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trial?.teamName ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Applied ${timeAgo(application.appliedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

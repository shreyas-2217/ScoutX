import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/clip.dart';
import '../../providers/location_provider.dart';
import '../../services/database.dart';
import '../../widgets/distance_filter.dart';
import '../shared/widgets.dart';
import '../shared/player_profile_view_screen.dart';
import '../shared/reels_feed.dart';
import '../messaging/inbox_screen.dart';

/// Coach home: reels feed of player clips with search + filters.
class CoachDiscoverScreen extends StatefulWidget {
  const CoachDiscoverScreen({super.key});

  @override
  State<CoachDiscoverScreen> createState() => _CoachDiscoverScreenState();
}

class _CoachDiscoverScreenState extends State<CoachDiscoverScreen>
    with SingleTickerProviderStateMixin {
  final _search = TextEditingController();
  String? _sport;
  String? _position;
  double? _distanceFilter;

  late final AnimationController _controller;
  late final Animation<double> _opacityAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.normal,
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: DSMotion.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _search.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const BrandLogo(markSize: 28, fontSize: 20),
        actions: [
          IconButton(
            icon: Icon(DSIcons.chatCircleDots, size: DSIconSize.appBar),
            tooltip: 'Messages',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InboxScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(68),
          child: Padding(
            padding: EdgeInsets.fromLTRB(DSSpacing.lg, 0, DSSpacing.lg, DSSpacing.md),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search player or title…',
                prefixIcon: Icon(DSIcons.magnifyingGlass, color: Theme.of(context).colorScheme.onSurfaceVariant),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(DSIcons.clearRounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                      ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnim.value,
            child: Transform.translate(
              offset: _slideAnim.value * 30,
              child: child,
            ),
          );
        },
        child: Column(
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
                selectedDistance: _distanceFilter,
                onDistanceChanged: (d) => setState(() => _distanceFilter = d),
              ),

            _FilterBar(
              sport: _sport,
              position: _position,
              onSportChanged: (s) => setState(() {
                _sport = _sport == s ? null : s;
                _position = null;
              }),
              onPositionChanged: (p) => setState(() => _position = _position == p ? null : p),
            ),
            Expanded(
              child: StreamBuilder<List<Clip>>(
                stream: _buildStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface),
                    );
                  }
                  final clips = snapshot.data ?? [];
                  if (clips.isEmpty) {
                    return EmptyState(
                      icon: DSIcons.searchOffRounded,
                      title: 'No clips match your filters',
                      subtitle: 'Try adjusting your search or filters.',
                    );
                  }
                  return ReelsFeed(
                    clipsStream: Stream.value(clips),
                    onOpenProfile: (clip) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PlayerProfileViewScreen(playerId: clip.playerId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<Clip>> _buildStream() {
    final db = context.read<Database>();
    final locationProvider = context.read<LocationProvider>();
    return db.streamClips(limit: 100).map((clips) {
      var list = clips.where((c) {
        if (_sport != null && c.sport != _sport) return false;
        if (_position != null && c.position != _position) return false;
        if (_search.text.trim().isNotEmpty) {
          final q = _search.text.trim().toLowerCase();
          if (!c.playerName.toLowerCase().contains(q) &&
              !c.title.toLowerCase().contains(q)) {
            return false;
          }
        }
        if (_distanceFilter != null && locationProvider.hasLocation) {
          final coords = AppConstants.coordinatesForLocation(c.location);
          if (coords == null) return false;
          final dist = locationProvider.distanceTo(coords[0], coords[1]);
          if (dist == null || dist > _distanceFilter!) return false;
        }
        return true;
      }).toList();
      return list;
    });
  }
}

class _FilterBar extends StatefulWidget {
  final String? sport;
  final String? position;
  final ValueChanged<String> onSportChanged;
  final ValueChanged<String> onPositionChanged;

  const _FilterBar({
    required this.sport,
    required this.position,
    required this.onSportChanged,
    required this.onPositionChanged,
  });

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heightAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.fast,
    );
    _heightAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    if (widget.sport != null) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _FilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sport != null && oldWidget.sport == null) {
      _controller.forward();
    } else if (widget.sport == null && oldWidget.sport != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sport chips
        SizedBox(
          height: 56,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: DSSpacing.md),
            child: Row(
              children: [
                for (final s in AppConstants.sportList)
                  Padding(
                    padding: EdgeInsets.only(right: DSSpacing.sm),
                    child: FilterChip(
                      label: Text(s),
                      selected: widget.sport == s,
                      onSelected: (_) => widget.onSportChanged(s),
                      selectedColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10),
                      checkmarkColor: Theme.of(context).colorScheme.onSurface,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.sport == s
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      side: BorderSide(
                        color: widget.sport == s
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DSRadius.chip),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Position chips (animated)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SizeTransition(
              sizeFactor: _heightAnim,
              alignment: Alignment.topCenter,
              child: widget.sport != null
                  ? SizedBox(
                      height: 56,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: DSSpacing.md),
                        child: Row(
                          children: [
                            for (final p in AppConstants.positionsBySport[widget.sport] ?? const [])
                              Padding(
                                padding: EdgeInsets.only(right: DSSpacing.sm),
                                child: FilterChip(
                                  label: Text(p),
                                  selected: widget.position == p,
                                  onSelected: (_) => widget.onPositionChanged(p),
                                  selectedColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10),
                                  checkmarkColor: Theme.of(context).colorScheme.onSurface,
                                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                  labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: widget.position == p
                                        ? Theme.of(context).colorScheme.onSurface
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  side: BorderSide(
                                    color: widget.position == p
                                        ? Theme.of(context).colorScheme.onSurface
                                        : Theme.of(context).colorScheme.outlineVariant,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(DSRadius.chip),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
      ],
    );
  }
}

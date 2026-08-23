import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/scouting_report.dart';
import '../../models/user_profile.dart';
import '../../services/database.dart';
import '../../services/ai/scouting_report_service.dart';
import '../buttons/scoutx_button.dart';

/// Bottom sheet that shows (and lazily generates) an AI scouting report
/// for [player]. Results are cached in Firestore for 7 days.
class ScoutingReportSheet extends StatefulWidget {
  final UserProfile player;

  const ScoutingReportSheet({super.key, required this.player});

  static Future<void> show(BuildContext context, UserProfile player) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ScoutingReportSheet(player: player),
    );
  }

  @override
  State<ScoutingReportSheet> createState() => _ScoutingReportSheetState();
}

class _ScoutingReportSheetState extends State<ScoutingReportSheet> {
  final ScoutingReportService _service = ScoutingReportService();

  ScoutingReport? _report;
  String? _error;
  bool _loading = true;
  bool _fromCache = false;

  @override
  void initState() {
    super.initState();
    _load(forceRefresh: false);
  }

  Future<void> _load({required bool forceRefresh}) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final db = context.read<Database>();

    try {
      if (!forceRefresh) {
        final cached = await db.getScoutingReport(widget.player.uid);
        if (cached != null) {
          final report = ScoutingReport.fromMap(cached);
          if (report.isFresh) {
            if (!mounted) return;
            setState(() {
              _report = report;
              _fromCache = true;
              _loading = false;
            });
            return;
          }
        }
      }

      final clips = await db.fetchClipsForPlayer(widget.player.uid);
      final report = await _service.generate(
        player: widget.player,
        clips: clips,
      );

      await db.updateUserProfile(widget.player.uid, {
        'aiScoutingReport': report.toMap(),
      });

      if (!mounted) return;
      setState(() {
        _report = report;
        _fromCache = false;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      setState(() {
        _error = msg.contains('429') ||
                msg.contains('RESOURCE_EXHAUSTED') ||
                msg.contains('quota')
            ? 'The AI has hit its usage limit right now. Please try again in a little while.'
            : msg.contains('StateError')
                ? 'AI is not configured. Add a Gemini API key to enable scouting reports.'
                : 'Could not generate the report. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.psychology,
                          size: 20, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Scouting Report',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${widget.player.displayName} Ã‚Â· ${widget.player.sport ?? 'Athlete'}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _buildBody(context, controller),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ScrollController controller) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(height: 16),
            Text(
              'ScoutX AI is reviewing profile stats and highlight clipsÃ¢â‚¬Â¦',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    if (_error != null || _report == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(_error ?? 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              SXButton(
                label: 'Retry',
                variant: SXButtonVariant.secondary,
                onPressed: () => _load(forceRefresh: true),
              ),
            ],
          ),
        ),
      );
    }

    final r = _report!;
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _RatingBadge(rating: r.rating),
            const SizedBox(width: 16),
            Expanded(child: _VerdictBox(verdict: r.verdict)),
          ],
        ),
        const SizedBox(height: 18),
        _SectionTitle('Overall Assessment'),
        const SizedBox(height: 6),
        Text(
          r.summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 18),
        if (r.strengths.isNotEmpty) ...[
          _SectionTitle('Strengths'),
          const SizedBox(height: 6),
          ...r.strengths.map((s) => _Bullet(
                icon: Icons.check_circle_outline,
                color: Colors.green.shade700,
                text: s,
              )),
          const SizedBox(height: 14),
        ],
        if (r.improvements.isNotEmpty) ...[
          _SectionTitle('Areas To Improve'),
          const SizedBox(height: 6),
          ...r.improvements.map((s) => _Bullet(
                icon: Icons.trending_up,
                color: Colors.amber.shade800,
                text: s,
              )),
          const SizedBox(height: 14),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _fromCache
                      ? 'Cached report Ã‚Â· generated ${DateFormat('d MMM yyyy').format(r.generatedAt)}'
                      : 'Generated just now by ScoutX AI from public profile and clip data only.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _load(forceRefresh: true),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Regenerate Analysis'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    final clamped = rating.clamp(0.0, 10.0);
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            clamped.toStringAsFixed(1),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text('/ 10', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _VerdictBox extends StatelessWidget {
  final String verdict;

  const _VerdictBox({required this.verdict});

  @override
  Widget build(BuildContext context) {
    if (verdict.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SCOUT\'S VERDICT',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
          const SizedBox(height: 4),
          Text(verdict,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(height: 1.4)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _Bullet({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.4)),
          ),
        ],
      ),
    );
  }
}

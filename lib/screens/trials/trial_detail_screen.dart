import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/trial.dart';
import '../../models/trial_application.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../shared/widgets.dart'
    show DSColors, DSSpacing, DSIconSize, DSIcons, DSCard, EmptyState, DSButton, DSButtonVariant, TagChip, StaggeredList, InitialsAvatar, AnimatedPage;
import '../shared/player_profile_view_screen.dart';

/// Trial detail. Shows coach controls when the owner views it,
/// and apply/status UI when a player views it.
class TrialDetailScreen extends StatelessWidget {
  final Trial trial;

  const TrialDetailScreen({super.key, required this.trial});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.profile;
    final isOwner = me != null && me.uid == trial.coachId;

    return Scaffold(
      appBar: AppBar(title: const Text('Trial')),
      body: StreamBuilder<Trial>(
        stream: context.read<Database>().streamTrial(trial.id),
        builder: (context, snapshot) {
          final t = snapshot.data ?? trial;
          return AnimatedPage(
            child: ListView(
              padding: EdgeInsets.all(DSSpacing.md),
              children: [
                _InfoCard(trial: t),
                SizedBox(height: DSSpacing.md),
                if (isOwner) ...[
                  _OwnerPanel(trial: t),
                ] else ...[
                  _PlayerPanel(trial: t),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Trial trial;

  const _InfoCard({required this.trial});

  @override
  Widget build(BuildContext context) {
    final isOpen = trial.status == 'open';
    return DSCard(
      padding: EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trial.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TagChip(
                text: isOpen ? 'OPEN' : 'CLOSED',
                color: isOpen ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
              ),
            ],
          ),
          SizedBox(height: DSSpacing.md),
          Text(
            '${trial.teamName} Â· ${trial.coachName}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: DSSpacing.md),
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: [
              TagChip(text: trial.sport, color: Theme.of(context).colorScheme.primary),
              TagChip(text: trial.position, color: Theme.of(context).colorScheme.onSurface),
              TagChip(text: trial.skillLevel, color: DSColors.amber),
            ],
          ),
          if (trial.date != null || trial.location != null) ...[
            SizedBox(height: DSSpacing.md),
            Wrap(
              spacing: DSSpacing.lg,
              runSpacing: DSSpacing.xs,
              children: [
                if (trial.date != null)
                  _IconText(icon: DSIcons.calendar, text: trial.date!),
                if (trial.location != null)
                  _IconText(icon: DSIcons.mapPin, text: trial.location!),
              ],
            ),
          ],
          if (trial.description.isNotEmpty) ...[
            SizedBox(height: DSSpacing.md),
            Text(
              trial.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: DSIconSize.sm, color: Theme.of(context).colorScheme.onSurfaceVariant),
        SizedBox(width: DSSpacing.xs),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------------
// Coach view: applicants + final list
// -------------------------------------------------------------------------

class _OwnerPanel extends StatelessWidget {
  final Trial trial;

  const _OwnerPanel({required this.trial});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Applicants (${trial.selectedPlayerIds.length} finalized)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(height: DSSpacing.md),
        _ApplicantsList(trial: trial),
        SizedBox(height: DSSpacing.xl),
        _FinalListSection(trial: trial),
      ],
    );
  }
}

class _ApplicantsList extends StatelessWidget {
  final Trial trial;

  const _ApplicantsList({required this.trial});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TrialApplication>>(
      stream: context.read<Database>().streamApplicationsForTrial(trial.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface),
          );
        }
        final apps = snapshot.data ?? [];
        if (apps.isEmpty) {
          return EmptyState(
            icon: DSIcons.userPlus,
            title: 'No applications yet',
            subtitle: 'Players will appear here when they apply.',
          );
        }
        return StaggeredList(
          spacing: DSSpacing.md,
          children: apps.map((app) => _ApplicantCard(trial: trial, app: app)).toList(),
        );
      },
    );
  }
}

class _ApplicantCard extends StatefulWidget {
  final Trial trial;
  final TrialApplication app;

  const _ApplicantCard({required this.trial, required this.app});

  @override
  State<_ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<_ApplicantCard> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final inFinalList = widget.trial.selectedPlayerIds.contains(widget.app.playerId);
    final statusColor = switch (widget.app.status) {
      'accepted' => Theme.of(context).colorScheme.onSurface,
      'rejected' => Theme.of(context).colorScheme.error,
      _ => DSColors.amber,
    };

    return DSCard(
      padding: EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(name: widget.app.playerName, radius: 20),
              SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.app.playerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${widget.app.sport} Â· ${widget.app.position}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TagChip(text: widget.app.status, color: statusColor),
            ],
          ),
          if (widget.app.message.isNotEmpty) ...[
            SizedBox(height: DSSpacing.md),
            Text(
              widget.app.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
          SizedBox(height: DSSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DSButton(
                label: 'Profile',
                leadingIcon: DSIcons.eye,
                variant: DSButtonVariant.outlined,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlayerProfileViewScreen(
                        playerId: widget.app.playerId,
                      ),
                    ),
                  );
                },
              ),
              if (widget.app.status == 'pending') ...[
                DSButton(
                  label: 'Accept',
                  leadingIcon: DSIcons.check,
                  variant: DSButtonVariant.filled,
                  customColor: Theme.of(context).colorScheme.onSurface,
                  onPressed: _processing ? null : () => _updateStatus('accepted'),
                ),
                DSButton(
                  label: 'Reject',
                  leadingIcon: DSIcons.x,
                  variant: DSButtonVariant.filled,
                  customColor: Theme.of(context).colorScheme.error,
                  onPressed: _processing ? null : () => _updateStatus('rejected'),
                ),
              ],
              if (widget.app.status == 'accepted' && !inFinalList) ...[
                DSButton(
                  label: 'Add to final list',
                  leadingIcon: DSIcons.trophy,
                  variant: DSButtonVariant.tonal,
                  onPressed: _processing ? null : () => _addToFinalList(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _processing = true);
    try {
      await context.read<Database>().updateApplicationStatus(widget.app.id, status);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _addToFinalList() async {
    setState(() => _processing = true);
    try {
      await context.read<Database>().addPlayerToFinalList(widget.trial.id, widget.app.playerId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to final list: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }
}

class _FinalListSection extends StatelessWidget {
  final Trial trial;

  const _FinalListSection({required this.trial});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Final selected players (${trial.selectedPlayerIds.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(height: DSSpacing.xs),
        Text(
          'These are the players you\'ve finalized for the trial. '
          'Tap any entry to view that player\'s profile.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: DSSpacing.md),
        if (trial.selectedPlayerIds.isEmpty)
          EmptyState(
            icon: DSIcons.trophy,
            title: 'No players finalized yet',
            subtitle: 'Accept an applicant, then tap "Add to final list".',
          )
        else
          Column(
            children: trial.selectedPlayerIds.map((pid) => _FinalPlayerRow(trialId: trial.id, playerId: pid)).toList(),
          ),
        SizedBox(height: DSSpacing.xl),
        DSButton(
          label: trial.status == 'open' 
              ? 'Close trial (stop applications)' 
              : 'Reopen trial',
          leadingIcon: trial.status == 'open' ? DSIcons.circleMinus : DSIcons.arrowCounterClockwise,
          variant: DSButtonVariant.outlined,
          fullWidth: true,
          onPressed: () async {
            try {
              await context.read<Database>().updateTrialStatus(
                trial.id,
                trial.status == 'open' ? 'closed' : 'open',
              );
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update trial status: $e')),
                );
              }
            }
          },
        ),
      ],
    );
  }
}

class _FinalPlayerRow extends StatelessWidget {
  final String trialId;
  final String playerId;

  const _FinalPlayerRow({required this.trialId, required this.playerId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: context.read<Database>().getUserProfile(playerId),
      builder: (context, snapshot) {
        final p = snapshot.data;
        return DSCard(
          margin: EdgeInsets.only(bottom: DSSpacing.md),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PlayerProfileViewScreen(playerId: playerId),
              ),
            );
          },
          padding: EdgeInsets.all(DSSpacing.md),
          child: Row(
            children: [
              InitialsAvatar(name: p?.displayName ?? '?', radius: 20),
              SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p?.displayName ?? 'Player',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'ID: $playerId',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(DSIcons.eye, size: DSIconSize.md),
                    tooltip: 'View profile',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlayerProfileViewScreen(playerId: playerId),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(DSIcons.circleMinus, size: DSIconSize.md, color: Theme.of(context).colorScheme.error),
                    tooltip: 'Remove from final list',
                    onPressed: () async {
                      try {
                        await context.read<Database>().removePlayerFromFinalList(trialId, playerId);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to remove player: $e')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------------------
// Player view: apply or show status
// -------------------------------------------------------------------------

class _PlayerPanel extends StatelessWidget {
  final Trial trial;

  const _PlayerPanel({required this.trial});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.profile;
    final playerId = auth.user?.uid;
    if (me == null || playerId == null) return const SizedBox.shrink();

    final isFinal = trial.selectedPlayerIds.contains(playerId);

    return FutureBuilder<TrialApplication?>(
      future: context.read<Database>().getApplicationFor(trial.id, playerId),
      builder: (context, snap) {
        final app = snap.data;
        if (isFinal) {
          return DSCard(
            padding: EdgeInsets.all(DSSpacing.xl),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: DSColors.amber.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(DSIcons.trophy, color: DSColors.amber, size: 28),
                ),
                SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Text(
                    "You're in the final list! The coach will contact you about the trial details.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (app != null) {
          return _StatusCard(app: app);
        }
        if (trial.status == 'closed') {
          return EmptyState(
            icon: DSIcons.lock,
            title: 'This trial is closed',
            subtitle: 'Applications are no longer being accepted.',
          );
        }
        return DSCard(
          padding: EdgeInsets.all(DSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Interested in this trial?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: DSSpacing.sm),
              Text(
                'Apply and the coach can verify you and add you to their final list.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: DSSpacing.xl),
              DSButton(
                label: 'Apply for this trial',
                leadingIcon: DSIcons.send,
                fullWidth: true,
                onPressed: () => _showApplyDialog(context, trial),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showApplyDialog(BuildContext context, Trial trial) async {
    final controller = TextEditingController();
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Apply for trial'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Message to coach (optional)',
              alignLabelWithHint: true,
              hintText: 'Tell the coach about yourselfâ€¦',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            DSButton(
              label: 'Send application',
              onPressed: () => Navigator.of(context).pop(controller.text),
            ),
          ],
        ),
      );
      if (result == null) return;
      if (!context.mounted) return;
      final me = context.read<AuthProvider>().profile;
      if (me == null) return;
      final app = TrialApplication(
        id: '',
        trialId: trial.id,
        playerId: me.uid,
        playerName: me.displayName,
        sport: me.sport ?? 'Other',
        position: me.position ?? 'Any',
        message: result,
        appliedAt: DateTime.now(),
      );
      if (!context.mounted) return;
      await context.read<Database>().applyToTrial(
            app,
            coachId: trial.coachId,
            trialTitle: trial.title,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply: $e')),
        );
      }
    } finally {
      controller.dispose();
    }
  }
}

class _StatusCard extends StatelessWidget {
  final TrialApplication app;

  const _StatusCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final color = switch (app.status) {
      'accepted' => Theme.of(context).colorScheme.onSurface,
      'rejected' => Theme.of(context).colorScheme.error,
      _ => DSColors.amber,
    };
    final icon = switch (app.status) {
      'accepted' => DSIcons.checkCircle,
      'rejected' => DSIcons.xCircle,
      _ => DSIcons.hourglass,
    };
    final text = switch (app.status) {
      'accepted' =>
        'Application accepted! Waiting for the coach to finalize the list.',
      'rejected' => 'Sorry, your application was not selected this time.',
      _ => 'Application submitted. The coach will review it soon.',
    };
    return DSCard(
      padding: EdgeInsets.all(DSSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TagChip(text: app.status, color: color),
                SizedBox(height: DSSpacing.xs),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



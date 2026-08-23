import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/trial.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../shared/widgets.dart';
import '../trials/trial_detail_screen.dart';
import 'post_trial_screen.dart';

/// Coach side: their trials + post new.
class CoachTrialsScreen extends StatefulWidget {
  const CoachTrialsScreen({super.key});

  @override
  State<CoachTrialsScreen> createState() => _CoachTrialsScreenState();
}

class _CoachTrialsScreenState extends State<CoachTrialsScreen>
    with SingleTickerProviderStateMixin {
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trials'),
        actions: [
          IconButton(
            icon: Icon(DSIcons.addCircleRounded, size: DSIconSize.appBar),
            tooltip: 'Post a trial',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PostTrialScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 48,
        child: FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PostTrialScreen()),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            foregroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: Text('New', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.w700)),
        ),
      ),
      body: uid == null
          ? const SizedBox.shrink()
          : AnimatedBuilder(
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
              child: AnimatedPage(
                child: StreamBuilder<List<Trial>>(
                  stream: context.read<Database>().streamTrialsForCoach(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: DSColors.onSurface),
                            SizedBox(height: DSSpacing.md),
                            Text(
                              'Loading trials...',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: DSColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final trials = snapshot.data ?? [];
                    if (trials.isEmpty) {
                      return EmptyState(
                        icon: DSIcons.trophy,
                        title: 'No trials yet',
                        subtitle:
                            'Post a trial and players who match can apply. You review, accept and finalize your list.',
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.all(DSSpacing.md),
                      itemCount: trials.length,
                      itemBuilder: (context, index) {
                        final t = trials[index];
                        return StaggeredItem(
                          index: index,
                          delay: DSMotion.listItemStagger * index,
                          duration: DSMotion.fast,
                          child: _TrialCard(trial: t),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _TrialCard extends StatelessWidget {
  final Trial trial;

  const _TrialCard({required this.trial});

  @override
  Widget build(BuildContext context) {
    final isOpen = trial.status == 'open';
    return DSCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TrialDetailScreen(trial: trial)),
        );
      },
      padding: EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trial.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TagChip(
                text: isOpen ? 'OPEN' : 'CLOSED',
                color: isOpen ? DSColors.green : DSColors.onSurfaceDisabled,
              ),
            ],
          ),
          SizedBox(height: DSSpacing.sm),
          Text(
            '${trial.teamName} · ${trial.sport} · ${trial.position} · ${trial.skillLevel}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: DSColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: DSSpacing.md),
          Row(
            children: [
              Icon(DSIcons.users, size: DSIconSize.sm, color: DSColors.green),
              SizedBox(width: DSSpacing.xs),
              Text(
                '${trial.selectedPlayerIds.length} players finalized',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: DSColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



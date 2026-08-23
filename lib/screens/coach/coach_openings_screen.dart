import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/opening.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../shared/widgets.dart';
import 'post_opening_screen.dart';

/// Coach side: post availability / team openings + manage.
class CoachOpeningsScreen extends StatefulWidget {
  const CoachOpeningsScreen({super.key});

  @override
  State<CoachOpeningsScreen> createState() => _CoachOpeningsScreenState();
}

class _CoachOpeningsScreenState extends State<CoachOpeningsScreen>
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
        title: const Text('Team Openings'),
        actions: [
          IconButton(
            icon: Icon(DSIcons.addCircleRounded, size: DSIconSize.appBar),
            tooltip: 'Post an opening',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PostOpeningScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PostOpeningScreen()),
            );
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          foregroundColor: Theme.of(context).colorScheme.surface,
          child: const Icon(Icons.add, size: 28),
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
              child: StreamBuilder<List<Opening>>(
                stream: context.read<Database>().streamOpeningsForCoach(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface),
                          SizedBox(height: DSSpacing.md),
                          Text(
                            'Loading openings...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final openings = snapshot.data ?? [];
                  if (openings.isEmpty) {
                    return EmptyState(
                      icon: DSIcons.megaphone,
                      title: 'No openings yet',
                      subtitle:
                          'Post what your team needs (position, skill level) so the right players find you.',
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(DSSpacing.md),
                    itemCount: openings.length,
                    itemBuilder: (context, index) {
                      return StaggeredItem(
                        index: index,
                        delay: DSMotion.listItemStagger * index,
                        duration: DSMotion.fast,
                        child: _OpeningCard(opening: openings[index]),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _OpeningCard extends StatefulWidget {
  final Opening opening;

  const _OpeningCard({required this.opening});

  @override
  State<_OpeningCard> createState() => _OpeningCardState();
}

class _OpeningCardState extends State<_OpeningCard> {
  bool _loading = false;

  Future<void> _toggleStatus() async {
    setState(() => _loading = true);
    try {
      await context.read<Database>().setOpeningStatus(
        widget.opening.id,
        widget.opening.status == 'open' ? 'closed' : 'open',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Opening'),
        content: const Text('This action cannot be undone. Delete this opening?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      await context.read<Database>().deleteOpening(widget.opening.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = widget.opening.status == 'open';
    return DSCard(
      padding: EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.opening.position} wanted',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TagChip(
                text: isOpen ? 'OPEN' : 'CLOSED',
                color: isOpen
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF81C784)
                        : const Color(0xFF2E7D32))
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          SizedBox(height: DSSpacing.sm),
          Text(
            '${widget.opening.teamName} · ${widget.opening.sport} · ${widget.opening.skillLevel}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (widget.opening.description.isNotEmpty) ...[
            SizedBox(height: DSSpacing.md),
            Text(
              widget.opening.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ],
          SizedBox(height: DSSpacing.md),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: [
              DSButton(
                label: isOpen ? 'Close' : 'Reopen',
                leadingIcon: isOpen ? DSIcons.circleMinus : DSIcons.arrowCounterClockwise,
                variant: DSButtonVariant.outlined,
                customColor: isOpen ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface,
                loading: _loading,
                onPressed: _loading ? null : _toggleStatus,
              ),
              DSButton(
                label: 'Delete',
                leadingIcon: DSIcons.trash,
                variant: DSButtonVariant.outlined,
                customColor: Theme.of(context).colorScheme.error,
                loading: _loading,
                onPressed: _loading ? null : _delete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}



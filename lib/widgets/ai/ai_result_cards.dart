import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';
import '../shared/initials_avatar.dart';
import '../../services/ai/ai_message.dart';
import '../../models/trial.dart';
import '../../screens/shared/player_profile_view_screen.dart';
import '../../screens/trials/trial_detail_screen.dart';

class AIResultCard extends StatelessWidget {
  final AICardData card;
  const AIResultCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    switch (card.type) {
      case AICardType.athlete:
      case AICardType.profile:
        return _AthleteCard(card: card);
      case AICardType.trial:
        return _TrialCard(card: card);
      case AICardType.highlight:
        return _HighlightCard(card: card);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _AthleteCard extends StatelessWidget {
  final AICardData card;
  const _AthleteCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 4, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(name: card.title, size: AvatarSize.sm),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(card.subtitle,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          if (card.metadata.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: card.metadata.entries.map((e) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: DSColors.volt.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${e.key}: ${e.value}',
                      style:
                          const TextStyle(fontSize: 11, color: DSColors.volt)),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              _ActionButton(
                label: 'View Profile',
                icon: Icons.person_outline,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PlayerProfileViewScreen(playerId: card.id),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrialCard extends StatelessWidget {
  final AICardData card;
  const _TrialCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 4, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: DSColors.volt.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.emoji_events,
                    color: DSColors.volt, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(card.subtitle,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          if (card.detail != null && card.detail!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(card.detail!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 8),
          _ActionButton(
            label: 'View Trial',
            icon: Icons.emoji_events_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TrialDetailScreen(
                    trial: Trial(
                      id: card.id,
                      coachId: '',
                      coachName: card.subtitle,
                      teamName: '',
                      title: card.title,
                      sport: '',
                      position: '',
                      skillLevel: '',
                      createdAt: DateTime.now(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final AICardData card;
  const _HighlightCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 4, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: DSColors.volt.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.play_circle_outline,
                color: DSColors.volt, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(card.subtitle,
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: DSColors.volt.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: DSColors.volt),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DSColors.volt)),
            ],
          ),
        ),
      ),
    );
  }
}

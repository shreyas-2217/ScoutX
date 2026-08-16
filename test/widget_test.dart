import 'package:flutter_test/flutter_test.dart';

import 'package:scoutx/models/clip.dart';
import 'package:scoutx/models/trial.dart';

void main() {
  test('Clip serializes and deserializes', () {
    final clip = Clip(
      id: 'c1',
      playerId: 'p1',
      playerName: 'Aarav',
      videoUrl: 'https://x.com/a.mp4',
      title: 'Goal',
      sport: 'Football',
      position: 'Striker',
      likeCount: 5,
      createdAt: DateTime(2026, 1, 1),
    );
    final map = clip.toMap();
    final back = Clip.fromMap('c1', map);
    expect(back.playerName, 'Aarav');
    expect(back.likeCount, 5);
    expect(back.sport, 'Football');
  });

  test('Trial final player list persists', () {
    final trial = Trial(
      id: 't1',
      coachId: 'coach1',
      coachName: 'Coach',
      teamName: 'FC',
      title: 'Trials',
      sport: 'Football',
      position: 'Midfielder',
      skillLevel: 'Advanced',
      selectedPlayerIds: ['p1', 'p2'],
      createdAt: DateTime(2026, 1, 1),
    );
    final back = Trial.fromMap('t1', trial.toMap());
    expect(back.selectedPlayerIds, ['p1', 'p2']);
  });
}

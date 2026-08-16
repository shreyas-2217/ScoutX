import '../models/clip.dart';
import '../models/user_profile.dart';
import 'search_parser.dart';

class SearchResult {
  final Clip clip;
  final double score;
  final List<String> matchReasons;

  const SearchResult({
    required this.clip,
    required this.score,
    this.matchReasons = const [],
  });
}

class UserSearchResult {
  final UserProfile user;
  final double score;
  final List<String> matchReasons;

  const UserSearchResult({
    required this.user,
    required this.score,
    this.matchReasons = const [],
  });
}

class SearchService {
  static List<SearchResult> searchClips(
    List<Clip> clips,
    SearchParseResult parsed,
  ) {
    if (parsed.isEmpty) {
      return clips
          .map((c) => SearchResult(clip: c, score: 0))
          .toList();
    }

    final results = <SearchResult>[];

    for (final clip in clips) {
      double score = 0;
      final reasons = <String>[];

      if (parsed.sport != null) {
        if (clip.sport.toLowerCase() == parsed.sport!.toLowerCase()) {
          score += 30;
          reasons.add('Sport: ${clip.sport}');
        }
      }

      if (parsed.position != null) {
        if (clip.position.toLowerCase() == parsed.position!.toLowerCase()) {
          score += 25;
          reasons.add('Position: ${clip.position}');
        }
      }

      if (parsed.ageGroup != null) {
        if (clip.ageGroup?.toLowerCase() == parsed.ageGroup!.toLowerCase()) {
          score += 20;
          reasons.add('Age: ${clip.ageGroup}');
        }
      }

      if (parsed.location != null) {
        if (clip.location?.toLowerCase() ==
            parsed.location!.toLowerCase()) {
          score += 25;
          reasons.add('Location: ${clip.location}');
        }
      }

      if (parsed.highlightType != null) {
        if (clip.highlightType?.toLowerCase() ==
            parsed.highlightType!.toLowerCase()) {
          score += 20;
          reasons.add('Type: ${clip.highlightType}');
        }
      }

      if (parsed.skills.isNotEmpty && clip.skills.isNotEmpty) {
        final clipSkillsLower =
            clip.skills.map((s) => s.toLowerCase()).toSet();
        for (final skill in parsed.skills) {
          if (clipSkillsLower.contains(skill.toLowerCase())) {
            score += 15;
            reasons.add('Skill: $skill');
          }
        }
      }

      if (parsed.freeText.isNotEmpty) {
        final q = parsed.freeText.toLowerCase();
        if (clip.title.toLowerCase().contains(q)) {
          score += 10;
          reasons.add('Title match');
        }
        if (clip.description.toLowerCase().contains(q)) {
          score += 5;
          reasons.add('Description match');
        }
        if (clip.playerName.toLowerCase().contains(q)) {
          score += 12;
          reasons.add('Player: ${clip.playerName}');
        }
        for (final tag in clip.tags) {
          if (tag.toLowerCase().contains(q)) {
            score += 8;
            reasons.add('Tag: $tag');
          }
        }
        if (clip.searchableText?.toLowerCase().contains(q) ?? false) {
          score += 6;
        }
      }

      if (score > 0) {
        results.add(SearchResult(
          clip: clip,
          score: score,
          matchReasons: reasons,
        ));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  static List<UserSearchResult> searchUsers(
    List<UserProfile> users,
    SearchParseResult parsed,
  ) {
    if (parsed.isEmpty) {
      return users
          .map((u) => UserSearchResult(user: u, score: 0))
          .toList();
    }

    final results = <UserSearchResult>[];

    for (final user in users) {
      double score = 0;
      final reasons = <String>[];

      if (parsed.sport != null) {
        if (user.sport?.toLowerCase() == parsed.sport!.toLowerCase()) {
          score += 30;
          reasons.add('Sport: ${user.sport}');
        }
      }

      if (parsed.position != null) {
        if (user.position?.toLowerCase() == parsed.position!.toLowerCase()) {
          score += 25;
          reasons.add('Position: ${user.position}');
        }
      }

      if (parsed.location != null) {
        if (user.city?.toLowerCase() == parsed.location!.toLowerCase()) {
          score += 25;
          reasons.add('Location: ${user.city}');
        }
      }

      if (parsed.freeText.isNotEmpty) {
        final q = parsed.freeText.toLowerCase();
        if (user.displayName.toLowerCase().contains(q)) {
          score += 15;
          reasons.add('Name: ${user.displayName}');
        }
        if (user.bio?.toLowerCase().contains(q) ?? false) {
          score += 5;
          reasons.add('Bio match');
        }
        if (user.teamName?.toLowerCase().contains(q) ?? false) {
          score += 8;
          reasons.add('Team: ${user.teamName}');
        }
        if (user.clubName?.toLowerCase().contains(q) ?? false) {
          score += 8;
          reasons.add('Club: ${user.clubName}');
        }
      }

      if (score > 0) {
        results.add(UserSearchResult(
          user: user,
          score: score,
          matchReasons: reasons,
        ));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}

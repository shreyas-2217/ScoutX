import '../constants.dart';

class SearchParseResult {
  final String? sport;
  final String? position;
  final String? ageGroup;
  final String? highlightType;
  final String? location;
  final List<String> skills;
  final String freeText;

  const SearchParseResult({
    this.sport,
    this.position,
    this.ageGroup,
    this.highlightType,
    this.location,
    this.skills = const [],
    this.freeText = '',
  });

  bool get isEmpty =>
      sport == null &&
      position == null &&
      ageGroup == null &&
      highlightType == null &&
      location == null &&
      skills.isEmpty &&
      freeText.isEmpty;

  bool get hasStructured =>
      sport != null ||
      position != null ||
      ageGroup != null ||
      highlightType != null ||
      location != null ||
      skills.isNotEmpty;
}

class SearchParser {
  static final _allSportsLower =
      AppConstants.sportList.map((s) => s.toLowerCase()).toSet();

  static final _allPositionsLower = <String>{};
  static final _positionToCanonical = <String, String>{};

  static final _allSkillsLower = <String>{};
  static final _skillToCanonical = <String, String>{};

  static final _ageGroupsLower =
      AppConstants.ageGroups.map((a) => a.toLowerCase()).toSet();

  static final _highlightTypesLower =
      AppConstants.highlightTypesBySport.values.expand((h) => h).map((h) => h.toLowerCase()).toSet();

  static final _citiesLower =
      AppConstants.popularCities.map((c) => c.toLowerCase()).toSet();

  static bool _initialized = false;

  static void _init() {
    if (_initialized) return;
    _initialized = true;

    for (final entry in AppConstants.positionsBySport.entries) {
      for (final pos in entry.value) {
        final lower = pos.toLowerCase();
        _allPositionsLower.add(lower);
        _positionToCanonical[lower] = pos;
      }
    }

    for (final alias in AppConstants.positionAliases.entries) {
      _positionToCanonical[alias.key] = alias.value;
      _allPositionsLower.add(alias.key);
    }

    for (final entry in AppConstants.skillLibrary.entries) {
      for (final skill in entry.value) {
        final lower = skill.toLowerCase();
        _allSkillsLower.add(lower);
        _skillToCanonical[lower] = skill;
      }
    }
  }

  static SearchParseResult parse(String query) {
    _init();

    var normalized = query.trim().toLowerCase();
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    final tokens = normalized.split(' ');
    if (tokens.isEmpty || (tokens.length == 1 && tokens[0].isEmpty)) {
      return const SearchParseResult();
    }

    String? sport;
    String? position;
    String? ageGroup;
    String? highlightType;
    String? location;
    final skills = <String>[];

    final used = List<bool>.filled(tokens.length, false);

    // Pass 1: Multi-word matches (longest first)
    // Check multi-word skills
    for (final entry in AppConstants.skillLibrary.entries) {
      for (final skill in entry.value) {
        final skillLower = skill.toLowerCase();
        if (skillLower.contains(' ')) {
          final skillWords = skillLower.split(' ');
          for (int i = 0; i <= tokens.length - skillWords.length; i++) {
            bool match = true;
            for (int j = 0; j < skillWords.length; j++) {
              if (tokens[i + j] != skillWords[j]) {
                match = false;
                break;
              }
            }
            if (match && !used.sublist(i, i + skillWords.length).any((u) => u)) {
              skills.add(skill);
              for (int j = 0; j < skillWords.length; j++) {
                used[i + j] = true;
              }
            }
          }
        }
      }
    }

    // Check multi-word cities
    for (final city in AppConstants.popularCities) {
      final cityLower = city.toLowerCase();
      if (cityLower.contains(' ')) {
        final cityWords = cityLower.split(' ');
        for (int i = 0; i <= tokens.length - cityWords.length; i++) {
          bool match = true;
          for (int j = 0; j < cityWords.length; j++) {
            if (tokens[i + j] != cityWords[j]) {
              match = false;
              break;
            }
          }
          if (match && !used.sublist(i, i + cityWords.length).any((u) => u)) {
            location = city;
            for (int j = 0; j < cityWords.length; j++) {
              used[i + j] = true;
            }
          }
        }
      }
    }

    // Pass 2: Single-word matches
    for (int i = 0; i < tokens.length; i++) {
      if (used[i]) continue;
      final t = tokens[i];

      // Age group (U13, U15, U17, U18, U21, etc.)
      if (ageGroup == null && _ageGroupsLower.contains(t)) {
        ageGroup = AppConstants.ageGroups.firstWhere(
          (a) => a.toLowerCase() == t,
        );
        used[i] = true;
        continue;
      }

      // Sport
      if (sport == null && _allSportsLower.contains(t)) {
        sport = AppConstants.sportList.firstWhere(
          (s) => s.toLowerCase() == t,
        );
        used[i] = true;
        continue;
      }

      // Position (including aliases)
      if (position == null && _allPositionsLower.contains(t)) {
        position = _positionToCanonical[t] ?? t;
        used[i] = true;
        continue;
      }

      // Highlight type
      if (highlightType == null && _highlightTypesLower.contains(t)) {
        highlightType = AppConstants.highlightTypes.firstWhere(
          (h) => h.toLowerCase() == t,
        );
        used[i] = true;
        continue;
      }

      // Skill
      if (_allSkillsLower.contains(t)) {
        final canonical = _skillToCanonical[t] ?? t;
        if (!skills.contains(canonical)) {
          skills.add(canonical);
        }
        used[i] = true;
        continue;
      }

      // Location (single-word cities)
      if (location == null && _citiesLower.contains(t)) {
        location = AppConstants.popularCities.firstWhere(
          (c) => c.toLowerCase() == t,
        );
        used[i] = true;
        continue;
      }

      // Location aliases
      if (location == null && AppConstants.locationAliases.containsKey(t)) {
        final normalized = AppConstants.locationAliases[t]!;
        location = AppConstants.popularCities.firstWhere(
          (c) => c.toLowerCase() == normalized,
          orElse: () => t[0].toUpperCase() + t.substring(1),
        );
        used[i] = true;
        continue;
      }
    }

    // Remaining unmatched tokens → freeText
    final remainingTokens = <String>[];
    for (int i = 0; i < tokens.length; i++) {
      if (!used[i]) remainingTokens.add(tokens[i]);
    }
    final freeText = remainingTokens.join(' ');

    return SearchParseResult(
      sport: sport,
      position: position,
      ageGroup: ageGroup,
      highlightType: highlightType,
      location: location,
      skills: skills,
      freeText: freeText,
    );
  }

  static List<String> getSuggestions(String prefix) {
    _init();
    final p = prefix.trim().toLowerCase();
    if (p.isEmpty) return [];

    final suggestions = <String>[];

    for (final city in AppConstants.popularCities) {
      if (city.toLowerCase().startsWith(p) || city.toLowerCase().contains(p)) {
        suggestions.add(city);
      }
    }

    for (final sport in AppConstants.sportList) {
      if (sport.toLowerCase().startsWith(p)) {
        suggestions.add(sport);
      }
    }

    for (final entry in AppConstants.positionsBySport.entries) {
      for (final pos in entry.value) {
        if (pos.toLowerCase().startsWith(p)) {
          suggestions.add(pos);
        }
      }
    }

    for (final age in AppConstants.ageGroups) {
      if (age.toLowerCase().startsWith(p)) {
        suggestions.add(age);
      }
    }

    for (final entry in AppConstants.skillLibrary.entries) {
      for (final skill in entry.value) {
        if (skill.toLowerCase().startsWith(p)) {
          suggestions.add(skill);
        }
      }
    }

    final lowerSuggestions = <String>{};
    final unique = <String>[];
    for (final s in suggestions) {
      final lower = s.toLowerCase();
      if (!lowerSuggestions.contains(lower)) {
        lowerSuggestions.add(lower);
        unique.add(s);
      }
    }

    return unique.take(8).toList();
  }
}

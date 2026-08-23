/// An AI-generated scouting analysis attached to a player profile.
class ScoutingReport {
  final double rating;
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final String verdict;
  final DateTime generatedAt;

  const ScoutingReport({
    required this.rating,
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.verdict,
    required this.generatedAt,
  });

  bool get isFresh =>
      DateTime.now().difference(generatedAt) < const Duration(days: 7);

  Map<String, dynamic> toMap() => {
        'rating': rating,
        'summary': summary,
        'strengths': strengths,
        'improvements': improvements,
        'verdict': verdict,
        'generatedAt': generatedAt.toIso8601String(),
      };

  static List<String> _stringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return const [];
  }

  static DateTime _date(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory ScoutingReport.fromMap(Map<String, dynamic> map) => ScoutingReport(
        rating: (map['rating'] as num?)?.toDouble() ?? 0,
        summary: map['summary']?.toString() ?? '',
        strengths: _stringList(map['strengths']),
        improvements: _stringList(map['improvements']),
        verdict: map['verdict']?.toString() ?? '',
        generatedAt: _date(map['generatedAt']),
      );
}

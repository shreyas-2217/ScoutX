import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import 'ai_config.dart';
import '../../models/clip.dart';
import '../../models/scouting_report.dart';
import '../../models/user_profile.dart';

/// Generates AI scouting reports for player profiles.
///
/// One Gemini call per generation; results are cached on the user's Firestore
/// document (see Database.getScoutingReport / updateUserProfile) so repeat
/// views cost nothing.
class ScoutingReportService {
  static const _maxClipsInPrompt = 10;

  Future<ScoutingReport> generate({
    required UserProfile player,
    required List<Clip> clips,
  }) async {
    if (!AIConfig.hasAnyKey) {
      throw StateError('Gemini API key is not configured.');
    }

    final prompt = _buildPrompt(player, clips);
    Object? lastError;

    for (final key in AIConfig.geminiApiKeys.where((k) => k.isNotEmpty)) {
      try {
        final model = GenerativeModel(
          model: AIConfig.modelName,
          apiKey: key,
          generationConfig: GenerationConfig(temperature: 0.4),
        );
        final response = await model.generateContent([Content.text(prompt)]);
        return ScoutingReport.fromMap(_extractJson(response.text ?? ''));
      } catch (e) {
        lastError = e;
        if (!_isQuotaError(e)) rethrow;
      }
    }
    throw lastError ?? StateError('No Gemini API keys configured.');
  }

  bool _isQuotaError(Object e) {
    final s = e.toString();
    return s.contains('429') ||
        s.contains('RESOURCE_EXHAUSTED') ||
        s.contains('quota');
  }

  String _buildPrompt(UserProfile player, List<Clip> clips) {

    final clipLines = StringBuffer();
    final listed = clips.take(_maxClipsInPrompt).toList();
    if (listed.isEmpty) {
      clipLines.writeln('(No highlight clips uploaded yet.)');
    } else {
      for (final c in listed) {
        clipLines.writeln(
          '- "${c.title}" (${c.highlightType ?? 'clip'}) · ${c.likeCount} likes, '
          '${c.viewCount} views, ${c.commentCount} comments · '
          'skills: ${c.skills.isEmpty ? 'n/a' : c.skills.join(', ')}'
          '${c.description.isEmpty ? '' : ' · "${c.description}"'}',
        );
      }
    }

    final prompt = '''
You are an experienced sports scout writing a quick evaluation for coaches browsing ScoutX.

ATHLETE
- Name: ${player.displayName}
- Sport: ${player.sport ?? 'unknown'}
- Position: ${player.position ?? 'unknown'}
- Age group: ${player.ageGroup ?? 'unknown'}
- City: ${player.city ?? 'unknown'}
- Bio: ${player.bio?.isEmpty == true ? '(none)' : player.bio}
- Total clips: ${player.clipCount} | Followers: ${player.followerCount}

HIGHLIGHT CLIPS
$clipLines

Based ONLY on the information above, respond with ONLY a valid JSON object (no markdown fences, no extra text) in this exact shape:
{"rating": <overall ability score from 0.0 to 10.0, one decimal>,
 "summary": "<2-3 sentence overall assessment of the athlete's demonstrated level>",
 "strengths": ["<strength 1>", "<strength 2>", "<strength 3>"],
 "improvements": ["<area to improve 1>", "<area to improve 2>"],
 "verdict": "<1-2 sentence recommendation telling coaches whether and why to shortlist this player>"}

Rules:
- rating must reflect evidence available; do not invent match statistics.
- strengths/improvements must reference concrete skills or clip signals where possible.
- Keep every string under 25 words.''';

    return prompt;
  }

  Map<String, dynamic> _extractJson(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```(json)?\s*'), '');
      text = text.replaceFirst(RegExp(r'```\s*$'), '').trim();
    }
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end > start) {
      text = text.substring(start, end + 1);
    }
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    throw FormatException('AI returned an unreadable scouting report.');
  }
}

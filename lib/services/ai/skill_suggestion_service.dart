import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import 'ai_config.dart';
import '../../constants.dart';

/// Suggests highlight skills for an upload using one Gemini call.
///
/// User-triggered only (one shot per picked video) — never called
/// automatically, so free-tier quota impact is negligible.
class SkillSuggestionService {
  /// Returns up to [maxSuggestions] skills from [validSkills] that best match
  /// the clip's title/description/sport. Throws on failure — callers are
  /// expected to degrade silently.
  Future<List<String>> suggest({
    required String sport,
    required String title,
    String? description,
    List<String>? extraContext,
    int maxSuggestions = 5,
  }) async {
    if (!AIConfig.hasAnyKey) {
      throw StateError('Gemini API key is not configured.');
    }

    final validSkills = AppConstants.skillLibrary[sport] ?? const <String>[];
    if (validSkills.isEmpty) {
      throw StateError('No known skills for sport "$sport".');
    }

    final prompt = _buildPrompt(
      sport: sport,
      title: title,
      description: description,
      extraContext: extraContext,
      validSkills: validSkills,
      maxSuggestions: maxSuggestions,
    );

    Object? lastError;
    for (final key in AIConfig.geminiApiKeys.where((k) => k.isNotEmpty)) {
      try {
        final model = GenerativeModel(
          model: AIConfig.modelName,
          apiKey: key,
          generationConfig: GenerationConfig(
            temperature: 0.2,
            responseMimeType: 'application/json',
          ),
        );
        final response = await model.generateContent([Content.text(prompt)]);
        final parsed =
            _parseSkills(_extractJsonArray(response.text ?? ''), validSkills);
        return parsed.take(maxSuggestions).toList();
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

  String _buildPrompt({
    required String sport,
    required String title,
    String? description,
    List<String>? extraContext,
    required List<String> validSkills,
    required int maxSuggestions,
  }) {
    return '''
You tag sports highlight clips with the skills they demonstrate.

SPORT: $sport
CLIP TITLE: $title
DESCRIPTION: ${description == null || description.isEmpty ? '(none)' : description}
${extraContext != null && extraContext.isNotEmpty ? 'OTHER DETAILS: ${extraContext.join(', ')}' : ''}

Pick 3 to $maxSuggestions DISTINCT skills demonstrated or strongly implied by this clip.
- Lead with the single most obvious skill.
- Then add supporting skills: technique, variation, athletic quality, match situation — whatever fits.
- Prefer variety (e.g. a bowling action implies the delivery type, the skill executed, and the tactical intent).
- Return fewer than 3 ONLY if the clip information is too vague to justify more.
- You MUST choose ONLY from this list:
${validSkills.join(', ')}

Respond with ONLY a valid JSON array of strings, e.g. ["Skill A", "Skill B", "Skill C"].
If nothing clearly matches, respond with []''';
  }

  List<String> _extractJsonArray(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```(json)?\s*'), '');
      text = text.replaceFirst(RegExp(r'```\s*$'), '').trim();
    }
    final start = text.indexOf('[');
    final end = text.lastIndexOf(']');
    if (start != -1 && end > start) {
      text = text.substring(start, end + 1);
    }
    try {
      final decoded = jsonDecode(text);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    throw const FormatException('AI returned an unreadable skill list.');
  }

  /// Case-insensitive match against the canonical library entries so AI
  /// paraphrasing can never inject arbitrary tags into the app data. Falls
  /// back to substring containment both ways ("Fast bowling" → "Bowling").
  List<String> _parseSkills(List<String> raw, List<String> validSkills) {
    final result = <String>[];
    for (final candidate in raw) {
      final c = candidate.trim().toLowerCase();
      if (c.length < 3) continue;
      String? match;
      for (final v in validSkills) {
        if (v.toLowerCase() == c) {
          match = v;
          break;
        }
      }
      match ??= validSkills.firstWhereOrNull(
        (v) {
          final lv = v.toLowerCase();
          return lv.length >= 4 && (lv.contains(c) || c.contains(lv));
        },
      );
      if (match != null && !result.contains(match)) {
        result.add(match);
      }
    }
    return result;
  }
}

extension _FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

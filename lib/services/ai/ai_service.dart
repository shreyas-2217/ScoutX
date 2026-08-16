import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_config.dart';
import 'ai_tools.dart';
import 'ai_message.dart';

/// ScoutX AI Response - structured output from the AI
class ScoutXAIResponse {
  final String text;
  final List<AICardData> cards;
  final List<String> suggestions;
  final List<String> actions;

  const ScoutXAIResponse({
    required this.text,
    this.cards = const [],
    this.suggestions = const [],
    this.actions = const [],
  });
}

/// Core ScoutX AI Service using Google Gemini 3.5 Flash with function calling
class AIService {
  late final GenerativeModel _model;
  ChatSession? _chat;
  final List<Content> _history = [];

  AIService() {
    _model = GenerativeModel(
      model: AIConfig.modelName,
      apiKey: AIConfig.geminiApiKey,
      tools: [
        Tool(functionDeclarations: [
          _searchAthletesTool,
          _searchCoachesTool,
          _searchTrialsTool,
          _searchHighlightsTool,
          _getMyApplicationsTool,
          _getPopularHighlightsTool,
        ]),
      ],
      systemInstruction: Content.system(_systemPrompt),
    );
    _chat = _model.startChat(history: _history);
  }

  static const String _systemPrompt = '''
You are ScoutX AI, an intelligent sports scouting assistant built into the ScoutX platform.

PERSONALITY:
- Friendly, intelligent, sport-aware, and helpful
- Concise but warm — like a knowledgeable sports scout friend
- Use emojis occasionally but not excessively
- Be naturally conversational, not robotic

ROLE AWARENESS:
You know the user's role (player, coach, or viewer), their sport, position, and location from the conversation context.
Use this information directly — do NOT try to look up the user's own profile.

DATABASE ACCESS:
You have access to the ScoutX database through tools. Use them when the user asks about:
- Athletes/players on ScoutX → use searchAthletes
- Coaches on ScoutX → use searchCoaches
- Trials/opportunities → use searchTrials
- Highlights/clips → use searchHighlights or getPopularHighlights

IMPORTANT: When you call a tool, you MUST also provide a text response acknowledging what you're searching for. For example:
- "Let me search for football trials for you..."
- "I'll find some fast wingers on ScoutX..."
- "Checking out the popular highlights..."

NEVER invent ScoutX data. If the database returns no results, say so naturally and suggest alternatives.

NO-RESULT HANDLING:
Never say "no records found" or "query returned 0 results".
Instead say things like:
- "I couldn't find an exact match, but here are some close alternatives"
- "There aren't any [X] on ScoutX right now, but I found some [Y] that might interest you"
- Suggest broadening the search

RESPONSE STYLE:
- Start with a brief acknowledgment
- Provide the information concisely
- Keep responses under 200 words for text
- Use markdown formatting for clarity when listing items
- End with a helpful follow-up question or suggestion when appropriate

EXAMPLES:
- "Find football trials" → Call searchTrials(sport: "Football") and say "Let me find football trials for you..."
- "Show me fast wingers" → Call searchAthletes(sport: "Football", position: "Winger") and say "I'll search for fast wingers..."
- "Show popular highlights" → Call getPopularHighlights() and say "Here are the top highlights..."
- "Who are the best strikers?" → Call searchAthletes(sport: "Football", position: "Striker") and say "Let me find the best strikers..."

IMPORTANT RULES:
1. Never make up player names, statistics, or ScoutX data
2. Always use the database tools to get real data
3. When showing results, format them clearly with bullet points
4. Keep responses concise and actionable
5. If a user asks something ambiguous, ask a clarifying question
''';

  // Tool definitions
  static final _searchAthletesTool = FunctionDeclaration(
    'searchAthletes',
    'Search for athletes/players on ScoutX by sport, position, location, or age criteria',
    Schema.object(
      properties: {
        'sport': Schema.string(description: 'Sport name (e.g., Football, Basketball, Cricket)'),
        'position': Schema.string(description: 'Position (e.g., Winger, Striker, Point Guard)'),
        'location': Schema.string(description: 'City or location name'),
        'ageMax': Schema.integer(description: 'Maximum age'),
        'ageMin': Schema.integer(description: 'Minimum age'),
        'limit': Schema.integer(description: 'Max results to return (default 5)'),
      },
    ),
  );

  static final _searchCoachesTool = FunctionDeclaration(
    'searchCoaches',
    'Search for coaches on ScoutX by sport or location',
    Schema.object(
      properties: {
        'sport': Schema.string(description: 'Sport name'),
        'location': Schema.string(description: 'City or location name'),
        'limit': Schema.integer(description: 'Max results (default 5)'),
      },
    ),
  );

  static final _searchTrialsTool = FunctionDeclaration(
    'searchTrials',
    'Search for open trials/opportunities on ScoutX by sport, location, or skill level',
    Schema.object(
      properties: {
        'sport': Schema.string(description: 'Sport name'),
        'location': Schema.string(description: 'Location name'),
        'skillLevel': Schema.string(description: 'Skill level (Beginner, Intermediate, Advanced, Elite)'),
        'limit': Schema.integer(description: 'Max results (default 5)'),
      },
    ),
  );

  static final _searchHighlightsTool = FunctionDeclaration(
    'searchHighlights',
    'Search for highlight clips on ScoutX by sport or position',
    Schema.object(
      properties: {
        'sport': Schema.string(description: 'Sport name'),
        'position': Schema.string(description: 'Position name'),
        'limit': Schema.integer(description: 'Max results (default 5)'),
      },
    ),
  );

  static final _getMyApplicationsTool = FunctionDeclaration(
    'getMyApplications',
    'Get the current user\'s trial applications (only for the authenticated user)',
    Schema.object(
      properties: {
        'uid': Schema.string(description: 'The current user\'s ID'),
      },
      requiredProperties: ['uid'],
    ),
  );

  static final _getPopularHighlightsTool = FunctionDeclaration(
    'getPopularHighlights',
    'Get the most popular highlight clips on ScoutX, optionally filtered by sport',
    Schema.object(
      properties: {
        'sport': Schema.string(description: 'Optional sport filter'),
        'limit': Schema.integer(description: 'Max results (default 5)'),
      },
    ),
  );

  Stream<String> sendMessageStream(
    String message, {
    required String userRole,
    required String userId,
    String? userName,
    String? userSport,
    String? userPosition,
  }) async* {
    if (AIConfig.geminiApiKey == 'AIzaSyDemoKeyReplaceMe' || AIConfig.geminiApiKey.isEmpty) {
      yield '🤖 I\'m ScoutX AI! To enable me, add a real Gemini API key:\n\n'
          '1. Get a key at aistudio.google.com\n'
          '2. Run with: flutter run -d chrome --dart-define=GEMINI_API_KEY=your_key\n\n'
          'Once configured, I can help you find athletes, trials, highlights, and more! ⚽';
      return;
    }

    final roleContext = StringBuffer();
    roleContext.write('The current user is a $userRole (ID: $userId, Name: ${userName ?? "User"}');
    if (userSport != null && userSport.isNotEmpty) roleContext.write(', Sport: $userSport');
    if (userPosition != null && userPosition.isNotEmpty) roleContext.write(', Position: $userPosition');
    roleContext.write(').');

    final fullMessage = '${roleContext}\n\nUser message: $message';

    try {
      final response = _chat!.sendMessageStream(Content.text(fullMessage));
      String accumulatedText = '';
      bool hasFunctionCalls = false;

      await for (final chunk in response) {
        if (chunk.functionCalls.isNotEmpty) {
          hasFunctionCalls = true;
          for (final call in chunk.functionCalls) {
            final toolResult = await _executeTool(call.name, call.args as Map<String, dynamic>, userId);
            yield* toolResult;
          }
        }
        if (chunk.text != null) {
          accumulatedText += chunk.text!;
          yield chunk.text!;
        }
      }

      if (accumulatedText.isEmpty && !hasFunctionCalls) {
        yield "I'm not sure how to help with that. Could you rephrase your question?";
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('429') || errorStr.contains('RESOURCE_EXHAUSTED') || errorStr.contains('quota')) {
        yield '☕ I\'ve reached the current AI usage limit.\n\nYou can continue using ScoutX normally. AI chat will become available again when the limit resets.';
      } else if (errorStr.contains('404') || errorStr.contains('NOT_FOUND')) {
        yield '⚠️ The AI model is currently unavailable. Please try again later.';
      } else {
        yield '⚠️ Something went wrong. Please try again in a moment.';
      }
    }
  }

  /// Execute a tool and format results directly (no second Gemini call)
  Stream<String> _executeTool(String functionName, Map<String, dynamic> args, String userId) async* {
    List<Map<String, dynamic>> results = [];
    String toolLabel = '';

    switch (functionName) {
      case 'searchAthletes':
        toolLabel = 'athletes';
        results = await AITools.searchAthletes(
          sport: args['sport'] as String?,
          position: args['position'] as String?,
          location: args['location'] as String?,
          limit: args['limit'] as int? ?? 5,
        );
        break;
      case 'searchCoaches':
        toolLabel = 'coaches';
        results = await AITools.searchCoaches(
          sport: args['sport'] as String?,
          location: args['location'] as String?,
          limit: args['limit'] as int? ?? 5,
        );
        break;
      case 'searchTrials':
        toolLabel = 'trials';
        results = await AITools.searchTrials(
          sport: args['sport'] as String?,
          location: args['location'] as String?,
          skillLevel: args['skillLevel'] as String?,
          limit: args['limit'] as int? ?? 5,
        );
        break;
      case 'searchHighlights':
        toolLabel = 'highlights';
        results = await AITools.searchHighlights(
          sport: args['sport'] as String?,
          position: args['position'] as String?,
          limit: args['limit'] as int? ?? 5,
        );
        break;
      case 'getMyApplications':
        toolLabel = 'applications';
        results = await AITools.getMyApplications(userId);
        break;
      case 'getPopularHighlights':
        toolLabel = 'highlights';
        results = await AITools.getPopularHighlights(
          sport: args['sport'] as String?,
          limit: args['limit'] as int? ?? 5,
        );
        break;
      default:
        yield 'I don\'t know how to help with that.';
        return;
    }

    // Always yield a response - either results or a "no results" message
    yield _formatResults(functionName, toolLabel, results);
  }

  /// Format tool results into a user-friendly message
  String _formatResults(String toolName, String label, List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return _formatNoResults(toolName, label);
    }

    final buffer = StringBuffer();
    switch (toolName) {
      case 'searchAthletes':
        buffer.writeln('I found **${results.length} athlete${results.length == 1 ? '' : 's'}** on ScoutX:\n');
        for (final r in results) {
          final name = r['name'] ?? 'Unknown';
          final sport = r['sport'] ?? '';
          final position = r['position'] ?? '';
          final city = r['city'] ?? '';
          final clips = r['clipCount'] ?? 0;
          final followers = r['followerCount'] ?? 0;
          buffer.writeln('• **$name**');
          if (sport.isNotEmpty || position.isNotEmpty) {
            buffer.writeln('  ${[sport, position].where((e) => e.isNotEmpty).join(' • ')}');
          }
          if (city.isNotEmpty) buffer.writeln('  📍 $city');
          if (clips > 0 || followers > 0) {
            buffer.writeln('  🎬 $clips clips · 👥 $followers followers');
          }
          buffer.writeln('');
        }
        break;

      case 'searchCoaches':
        buffer.writeln('I found **${results.length} coach${results.length == 1 ? '' : 'es'}** on ScoutX:\n');
        for (final r in results) {
          final name = r['name'] ?? 'Unknown';
          final sport = r['sport'] ?? '';
          final team = r['teamName'] ?? '';
          final city = r['city'] ?? '';
          buffer.writeln('• **$name**');
          if (sport.isNotEmpty) buffer.writeln('  $sport');
          if (team.isNotEmpty) buffer.writeln('  🏟️ $team');
          if (city.isNotEmpty) buffer.writeln('  📍 $city');
          buffer.writeln('');
        }
        break;

      case 'searchTrials':
        buffer.writeln('I found **${results.length} open trial${results.length == 1 ? '' : 's'}** on ScoutX:\n');
        for (final r in results) {
          final title = r['title'] ?? 'Untitled';
          final sport = r['sport'] ?? '';
          final position = r['position'] ?? '';
          final location = r['location'] ?? '';
          final skill = r['skillLevel'] ?? '';
          final coach = r['coachName'] ?? '';
          buffer.writeln('• **$title**');
          if (sport.isNotEmpty || position.isNotEmpty) {
            buffer.writeln('  ${[sport, position].where((e) => e.isNotEmpty).join(' • ')}');
          }
          if (location.isNotEmpty) buffer.writeln('  📍 $location');
          if (skill.isNotEmpty) buffer.writeln('  📊 $skill');
          if (coach.isNotEmpty) buffer.writeln('  👤 $coach');
          buffer.writeln('');
        }
        break;

      case 'searchHighlights':
      case 'getPopularHighlights':
        buffer.writeln('I found **${results.length} highlight${results.length == 1 ? '' : 's'}** on ScoutX:\n');
        for (final r in results) {
          final title = r['title'] ?? 'Untitled';
          final playerName = r['playerName'] ?? 'Unknown';
          final sport = r['sport'] ?? '';
          final views = r['viewCount'] ?? 0;
          buffer.writeln('• **$title** by $playerName');
          if (sport.isNotEmpty) buffer.writeln('  $sport');
          buffer.writeln('  👁️ $views views');
          buffer.writeln('');
        }
        break;

      case 'getMyApplications':
        buffer.writeln('Your **${results.length} application${results.length == 1 ? '' : 's'}**:\n');
        for (final r in results) {
          final trial = r['trialId'] ?? 'Unknown';
          final status = r['status'] ?? 'pending';
          final sport = r['sport'] ?? '';
          buffer.writeln('• Trial: $trial');
          if (sport.isNotEmpty) buffer.writeln('  $sport');
          buffer.writeln('  Status: $status');
          buffer.writeln('');
        }
        break;

      default:
        buffer.writeln('Found ${results.length} result(s).');
    }

    buffer.writeln('Want me to search with different criteria?');
    return buffer.toString();
  }

  String _formatNoResults(String toolName, String label) {
    switch (toolName) {
      case 'searchAthletes':
        return '🔍 I couldn\'t find any athletes matching those criteria on ScoutX.\n\n'
            'Try broadening your search — maybe a different sport, position, or location?';
      case 'searchCoaches':
        return '🔍 I couldn\'t find any coaches matching those criteria on ScoutX.\n\n'
            'Try searching with different sport or location.';
      case 'searchTrials':
        return '🔍 I couldn\'t find any open trials matching those criteria on ScoutX.\n\n'
            'New trials are posted regularly — try checking back later or broadening your search!';
      case 'searchHighlights':
      case 'getPopularHighlights':
        return '🔍 I couldn\'t find any highlights matching those criteria on ScoutX.\n\n'
            'Try a different sport or check back later for new uploads!';
      case 'getMyApplications':
        return '📋 You don\'t have any trial applications yet.\n\n'
            'Browse available trials and apply to get started!';
      default:
        return '🔍 I couldn\'t find any $label matching your criteria.';
    }
  }

  void clearHistory() {
    _history.clear();
    _chat = _model.startChat(history: _history);
  }
}

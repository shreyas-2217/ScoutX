/// ScoutX AI Configuration
///
/// SECURITY NOTE: Keys are compiled into the client bundle. For a demo this is
/// acceptable; restrict keys by HTTP referrer in Google AI Studio for extra
/// safety.
///
/// QUOTA FAILOVER: Free-tier limits apply per Google project. Bake several
/// keys (different accounts/projects) via --dart-define at build time; at
/// runtime AIService automatically switches to the next key whenever one hits
/// its limit, so a single exhausted key never interrupts the app.
class AIConfig {
  static const List<String> geminiApiKeys = [
    String.fromEnvironment('GEMINI_API_KEY', defaultValue: ''),
    String.fromEnvironment('GEMINI_API_KEY_2', defaultValue: ''),
    String.fromEnvironment('GEMINI_API_KEY_3', defaultValue: ''),
  ];

  /// First configured key, for simple "is AI enabled?" checks.
  static String get geminiApiKey =>
      geminiApiKeys.firstWhere((k) => k.isNotEmpty, orElse: () => '');

  static bool get hasAnyKey => geminiApiKey.isNotEmpty;

  /// Index of the next usable key after [currentIndex], wrapping around to
  /// earlier keys so a key whose quota has reset becomes reachable again.
  /// Returns -1 when no other usable key exists.
  static int nextIndex(int currentIndex) {
    final n = geminiApiKeys.length;
    for (var step = 1; step <= n; step++) {
      final i = (currentIndex + step) % n;
      if (geminiApiKeys[i].isNotEmpty) return i;
    }
    return -1;
  }

  static const String modelName = 'gemini-3.5-flash';
  static const int maxHistoryLength = 10;
  static const int maxTokensPerResponse = 1024;
  static const int rateLimitMessagesPerSession = 50;
}

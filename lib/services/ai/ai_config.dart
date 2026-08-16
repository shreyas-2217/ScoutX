/// ScoutX AI Configuration
///
/// SECURITY NOTE: In production, this API key should be served from a secure
/// backend (Firebase Cloud Function, etc.). For this demo, it's configured
/// client-side with domain restrictions on the Google AI Studio key.
class AIConfig {
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyDemoKeyReplaceMe',
  );

  static const String modelName = 'gemini-3.5-flash';
  static const int maxHistoryLength = 10;
  static const int maxTokensPerResponse = 1024;
  static const int rateLimitMessagesPerSession = 50;
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/ai/ai_service.dart';
import '../services/ai/ai_message.dart';
import '../services/ai/ai_config.dart';
import '../models/user_profile.dart';

class AIProvider extends ChangeNotifier {
  AIService? _aiServiceInstance;
  AIService get _aiService {
    _aiServiceInstance ??= AIService();
    return _aiServiceInstance!;
  }

  final List<AIMessage> _messages = [];
  bool _isLoading = false;
  bool _isOpen = false;
  bool _isRateLimited = false;
  int _sessionMessageCount = 0;
  StreamSubscription<String>? _currentSubscription;

  List<AIMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isOpen => _isOpen;
  bool get isRateLimited => _isRateLimited;
  int get sessionMessageCount => _sessionMessageCount;

  void toggleOpen() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void open() {
    _isOpen = true;
    notifyListeners();
  }

  void close() {
    _isOpen = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text, {required UserProfile? profile}) async {
    if (text.trim().isEmpty || _isLoading) return;

    if (_sessionMessageCount >= AIConfig.rateLimitMessagesPerSession) {
      _isRateLimited = true;
      _messages.add(AIMessage.ai(
        '☕ I\'ve reached the current AI usage limit for this session.\n\n'
        'You can continue using ScoutX normally. Start a new conversation to continue chatting.',
        contentType: AIContentType.rateLimited,
      ));
      notifyListeners();
      return;
    }

    _messages.add(AIMessage.user(text.trim()));
    _sessionMessageCount++;
    notifyListeners();

    _isLoading = true;
    final thinkingMsg = AIMessage.thinking('Thinking...');
    _messages.add(thinkingMsg);
    notifyListeners();

    final role = profile?.role ?? 'viewer';
    final userId = profile?.uid ?? '';
    final userName = profile?.displayName ?? 'User';
    final userSport = profile?.sport;
    final userPosition = profile?.position;

    String accumulatedText = '';
    _currentSubscription?.cancel();

    final stream = _aiService.sendMessageStream(
      text,
      userRole: role,
      userId: userId,
      userName: userName,
      userSport: userSport,
      userPosition: userPosition,
    );

    _currentSubscription = stream.listen(
      (chunk) {
        accumulatedText += chunk;
        final idx = _messages.indexWhere((m) => m.id == thinkingMsg.id);
        if (idx != -1) {
          _messages[idx] = _messages[idx].copyWith(
            text: accumulatedText,
            contentType: AIContentType.text,
          );
          notifyListeners();
        }
      },
      onDone: () {
        _isLoading = false;
        final idx = _messages.indexWhere((m) => m.id == thinkingMsg.id);
        if (idx != -1 && accumulatedText.isEmpty) {
          _messages.removeAt(idx);
        }
        if (accumulatedText.contains('usage limit') || accumulatedText.contains('rate limit')) {
          _isRateLimited = true;
        }
        notifyListeners();
      },
      onError: (_) {
        final idx = _messages.indexWhere((m) => m.id == thinkingMsg.id);
        if (idx != -1) {
          _messages[idx] = _messages[idx].copyWith(
            text: 'Something went wrong. Please try again.',
            contentType: AIContentType.error,
          );
        }
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void clearConversation() {
    _messages.clear();
    _sessionMessageCount = 0;
    _isRateLimited = false;
    _aiService.clearHistory();
    notifyListeners();
  }

  @override
  void dispose() {
    _currentSubscription?.cancel();
    super.dispose();
  }
}

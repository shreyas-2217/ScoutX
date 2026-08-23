import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:scoutx/design_system.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../providers/ai_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ai/ai_message_bubble.dart';
import '../../widgets/ai/ai_suggestion_chips.dart';

class ScoutXAIScreen extends StatefulWidget {
  const ScoutXAIScreen({super.key});

  @override
  State<ScoutXAIScreen> createState() => _ScoutXAIScreenState();
}

class _ScoutXAIScreenState extends State<ScoutXAIScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _showSuggestions = true;

  // Voice
  final SpeechToText _speech = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speech.initialize(
        onError: (e) => debugPrint('speech error: $e'),
        onStatus: (s) {
          debugPrint('speech status: $s');
          if (s == 'done' || s == 'notListening') {
            if (mounted && _isListening) setState(() => _isListening = false);
          }
        },
      );
    } catch (e) {
      debugPrint('speech init failed: $e');
      _speechEnabled = false;
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }
    // need user gesture — re-init if not enabled
    if (!_speechEnabled) {
      try {
        _speechEnabled = await _speech.initialize();
      } catch (_) {
        _speechEnabled = false;
      }
      if (!_speechEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice not available on this browser/device')),
          );
        }
        return;
      }
    }
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (r) {
        if (!mounted) return;
        setState(() {
          _controller.text = r.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        cancelOnError: false,
        partialResults: true,
      ),
    );
  }

  @override
  void dispose() {
    try {
      _speech.cancel();
    } catch (_) {}
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    final aiProvider = context.read<AIProvider>();
    final profile = context.read<AuthProvider>().profile;

    aiProvider.sendMessage(text, profile: profile);
    _controller.clear();
    setState(() => _showSuggestions = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ai = context.watch<AIProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<AIProvider>().close(),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [DSColors.onSurface, DSColors.volt],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ScoutX AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text('Powered by Gemini', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          if (ai.isRateLimited)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 14, color: Colors.amber),
                  SizedBox(width: 4),
                  Text('Rate Limited', style: TextStyle(fontSize: 11, color: Colors.amber)),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New Conversation',
            onPressed: () {
              ai.clearConversation();
              setState(() => _showSuggestions = true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ai.messages.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: ai.messages.length,
                    itemBuilder: (context, index) {
                      final msg = ai.messages[index];
                      return AIMessageBubble(message: msg);
                    },
                  ),
          ),
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [DSColors.onSurface.withValues(alpha: 0.8), DSColors.volt],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            'ScoutX AI',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Your intelligent scouting assistant.\nAsk about athletes, trials, highlights, and more.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          if (_showSuggestions)
            AISuggestionChips(
              role: context.read<AuthProvider>().profile?.role ?? 'viewer',
              onSuggestionTap: _send,
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final theme = Theme.of(context);
    final ai = context.watch<AIProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isListening)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(duration: 600.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
                    const SizedBox(width: 8),
                    Text('Listening… speak now', style: theme.textTheme.labelSmall?.copyWith(color: Colors.red, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text('tap mic to stop', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red.withValues(alpha: 0.06) : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      border: _isListening ? Border.all(color: Colors.red.withValues(alpha: 0.25)) : null,
                    ),
                    child: TextField(
                      controller: _controller,
                      enabled: !ai.isLoading && !ai.isRateLimited,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: _send,
                      decoration: InputDecoration(
                        hintText: _isListening
                            ? 'Listening…'
                            : ai.isRateLimited
                                ? 'AI limit reached...'
                                : 'Ask ScoutX AI...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        hintStyle: TextStyle(color: _isListening ? Colors.red.withValues(alpha: 0.6) : Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Mic button
                GestureDetector(
                  onTap: ai.isLoading || ai.isRateLimited ? null : _toggleListening,
                  child: AnimatedContainer(
                    duration: DSMotion.fast,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(color: _isListening ? Colors.red : theme.colorScheme.outline.withValues(alpha: 0.2)),
                      boxShadow: _isListening ? [BoxShadow(color: Colors.red.withValues(alpha: 0.35), blurRadius: 12, spreadRadius: 1)] : null,
                    ),
                    child: Icon(
                      _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: _isListening ? Colors.white : theme.colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  )
                      .animate(target: _isListening ? 1 : 0)
                      .scale(duration: 200.ms, curve: Curves.easeOut)
                      .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.35)),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: ai.isLoading || ai.isRateLimited ? Colors.grey : DSColors.onSurface,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: ai.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: ai.isLoading || ai.isRateLimited ? null : () => _send(_controller.text),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

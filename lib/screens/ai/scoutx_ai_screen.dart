import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoutx/design_system.dart';
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

  @override
  void dispose() {
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
                  colors: [DSColors.voltDark, DSColors.volt],
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
          if (_showSuggestions && ai.messages.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AISuggestionChips(
                role: context.read<AuthProvider>().profile?.role ?? 'viewer',
                onSuggestionTap: _send,
              ),
            ),
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [DSColors.voltDark.withValues(alpha: 0.8), DSColors.volt],
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
          ],
        ),
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
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !ai.isLoading && !ai.isRateLimited,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: _send,
                  decoration: InputDecoration(
                    hintText: ai.isRateLimited ? 'AI limit reached...' : 'Ask ScoutX AI...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: ai.isLoading || ai.isRateLimited ? Colors.grey : DSColors.volt,
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
                onPressed: ai.isLoading || ai.isRateLimited
                    ? null
                    : () => _send(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

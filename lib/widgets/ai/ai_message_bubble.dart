import 'package:flutter/material.dart';
import 'ai_character.dart';
import 'ai_result_cards.dart';
import '../../services/ai/ai_message.dart';

class AIMessageBubble extends StatelessWidget {
  final AIMessage message;
  final void Function(String action)? onAction;

  const AIMessageBubble({super.key, required this.message, this.onAction});

  @override
  Widget build(BuildContext context) {
    if (message.type == AIMessageType.user) {
      return _UserBubble(message: message);
    }
    return _AIBubble(message: message, onAction: onAction);
  }
}

class _UserBubble extends StatelessWidget {
  final AIMessage message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(left: 48, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface,
          borderRadius: BorderRadius.circular(18).copyWith(bottomRight: const Radius.circular(4)),
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
        ),
      ),
    );
  }
}

class _AIBubble extends StatelessWidget {
  final AIMessage message;
  final void Function(String action)? onAction;
  const _AIBubble({required this.message, this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isThinking = message.contentType == AIContentType.thinking;
    final isError = message.contentType == AIContentType.error;
    final isRateLimited = message.contentType == AIContentType.rateLimited;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(right: 48, top: 4, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AICharacter(
                  state: isThinking
                      ? AICharacterState.thinking
                      : isError
                          ? AICharacterState.error
                          : AICharacterState.idle,
                  size: 32,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isRateLimited
                          ? Colors.amber.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18).copyWith(bottomLeft: const Radius.circular(4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isThinking) ...[
                          Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onSurface),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                message.text.isEmpty ? 'Thinking...' : message.text,
                                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                              ),
                            ],
                          ),
                        ] else ...[
                          _buildMarkdownText(
                            message.text,
                            TextStyle(
                              color: isError
                                  ? Theme.of(context).colorScheme.error
                                  : isRateLimited
                                      ? Colors.amber.shade800
                                      : theme.colorScheme.onSurface,
                              fontSize: 15,
                              height: 1.4,
                            ),
                            theme,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!isThinking && !isError && message.cards.isNotEmpty)
              ...message.cards.map((card) => AIResultCard(card: card)),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkdownText(String text, TextStyle style, ThemeData theme) {
    final spans = <TextSpan>[];
    final lines = text.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (i > 0) spans.add(const TextSpan(text: '\n'));

      final boldRegex = RegExp(r'\*\*(.*?)\*\*');
      var lastEnd = 0;
      for (final match in boldRegex.allMatches(line)) {
        if (match.start > lastEnd) {
          spans.add(TextSpan(text: line.substring(lastEnd, match.start), style: style));
        }
        spans.add(TextSpan(
          text: match.group(1),
          style: style.copyWith(fontWeight: FontWeight.w700),
        ));
        lastEnd = match.end;
      }
      if (lastEnd < line.length) {
        spans.add(TextSpan(text: line.substring(lastEnd), style: style));
      }
    }

    return RichText(text: TextSpan(children: spans));
  }
}

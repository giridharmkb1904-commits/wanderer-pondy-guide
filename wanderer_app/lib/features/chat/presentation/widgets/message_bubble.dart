import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/message_entity.dart';
import 'place_card.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  static final DateFormat _timeFmt = DateFormat('h:mm a');

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final timeLabel = _timeFmt.format(message.timestamp);
    final cards = message.cards;

    final bubble = Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isUser ? 64 : 16,
          right: isUser ? 16 : 64,
          top: 3,
          bottom: 3,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: isUser ? WandererColors.userBubble : WandererColors.guideBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(color: WandererColors.primary.withValues(alpha: 0.16)),
              ),
              child: Text(
                message.content,
                style: const TextStyle(
                  color: WandererColors.textPrimary,
                  fontSize: 15,
                  height: 1.4,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 6, right: 6),
              child: Text(
                timeLabel,
                style: TextStyle(
                  color: WandererColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bubble.animate().fadeIn(duration: 260.ms).slideY(
                begin: 0.15,
                end: 0,
                duration: 280.ms,
                curve: Curves.easeOutCubic,
              ),
          if (cards != null && cards.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...cards.map((c) => PlaceCard.fromJson(c)),
          ],
        ],
      ),
    );
  }
}

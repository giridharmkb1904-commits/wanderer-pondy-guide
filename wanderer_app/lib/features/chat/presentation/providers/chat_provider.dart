import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/brain/pondy_brain.dart';
import '../../domain/message_entity.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isConnected;
  final bool isTyping;

  const ChatState({
    this.messages = const [],
    this.isConnected = false,
    this.isTyping = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isConnected,
    bool? isTyping,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final PondyBrain _brain = PondyBrain.instance;
  final Random _rng = Random();
  Timer? _pending;

  ChatNotifier() : super(const ChatState());

  // Kept for API parity with earlier ws-backed flow.
  void connect(String sessionId) {
    state = state.copyWith(isConnected: true);
  }

  void sendMessage(String text) {
    final user = ChatMessage.user(text);
    state = state.copyWith(
      messages: [...state.messages, user],
      isTyping: true,
    );

    _pending?.cancel();
    final delay = 700 + _rng.nextInt(700);
    _pending = Timer(Duration(milliseconds: delay), () {
      try {
        final reply = _brain.answer(text);
        final msg = ChatMessage.assistant(reply.content, cards: reply.cards);
        state = state.copyWith(
          messages: [...state.messages, msg],
          isTyping: false,
        );
      } catch (_) {
        final fallback = ChatMessage.assistant(
          "I hit a snag. Try asking that another way?",
        );
        state = state.copyWith(
          messages: [...state.messages, fallback],
          isTyping: false,
        );
      }
    });
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/message_entity.dart';
import '../../../../core/network/websocket_client.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isConnected;
  final bool isTyping;

  const ChatState({this.messages = const [], this.isConnected = false, this.isTyping = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isConnected, bool? isTyping}) {
    return ChatState(
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final WsClient _ws = WsClient();
  StreamSubscription? _subscription;

  ChatNotifier() : super(const ChatState());

  void connect(String sessionId) {
    _ws.connect(sessionId);
    _subscription = _ws.messages.listen((msg) {
      if (msg['type'] == 'text') {
        final message = ChatMessage.assistant(msg['content'] as String);
        state = state.copyWith(messages: [...state.messages, message], isTyping: false);
      }
    });
    state = state.copyWith(isConnected: true);
  }

  void sendMessage(String text) {
    final message = ChatMessage.user(text);
    state = state.copyWith(messages: [...state.messages, message], isTyping: true);
    _ws.sendText(text);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _ws.dispose();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

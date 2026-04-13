import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/voice_button.dart';
import '../widgets/waveform_animation.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showTextInput = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).connect('dev-session');
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(text);
    _textController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: WandererColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [WandererColors.primary, WandererColors.primaryMuted]),
                    ),
                    child: const Icon(Icons.explore, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Wanderer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: WandererColors.textPrimary)),
                      Text(
                        chatState.isTyping ? 'Thinking...' : 'Your AI Guide',
                        style: TextStyle(fontSize: 12, color: chatState.isTyping ? WandererColors.primary : WandererColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Messages or empty state
            Expanded(
              child: chatState.messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WaveformAnimation(isActive: _isListening),
                          const SizedBox(height: 24),
                          const Text('Tap the mic to talk\nor type a message', textAlign: TextAlign.center, style: TextStyle(color: WandererColors.textMuted, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chatState.messages.length && chatState.isTyping) {
                          return const TypingIndicator();
                        }
                        return MessageBubble(message: chatState.messages[index]);
                      },
                    ),
            ),
            // Input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: WandererColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: _showTextInput
                  ? Row(
                      children: [
                        IconButton(icon: const Icon(Icons.mic, color: WandererColors.primary), onPressed: () => setState(() => _showTextInput = false)),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(color: WandererColors.textPrimary),
                            decoration: const InputDecoration(hintText: 'Ask your guide...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.send_rounded, color: WandererColors.primary), onPressed: _sendMessage),
                      ],
                    )
                  : Column(
                      children: [
                        VoiceButton(isListening: _isListening, onPressed: () => setState(() => _isListening = !_isListening)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => setState(() => _showTextInput = true),
                          child: const Text('or type a message', style: TextStyle(color: WandererColors.textMuted, fontSize: 13)),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

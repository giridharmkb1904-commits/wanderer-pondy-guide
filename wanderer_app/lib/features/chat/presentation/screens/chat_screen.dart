import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _inputFocus = FocusNode();
  final _showJumpButton = ValueNotifier<bool>(false);
  bool _canSend = false;

  static const _suggestions = [
    'Best cafés in White Town',
    'Auroville experiences',
    'Sunset spots near Rock Beach',
    'Where to try Chettinad food',
  ];

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final can = _textController.text.trim().isNotEmpty;
      if (can != _canSend) setState(() => _canSend = can);
    });
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).connect('dev-session');
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final distanceFromBottom = pos.maxScrollExtent - pos.pixels;
    _showJumpButton.value = distanceFromBottom > 200;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _sendMessage([String? override]) {
    final text = (override ?? _textController.text).trim();
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    ref.read(chatProvider.notifier).sendMessage(text);
    _textController.clear();
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _useSuggestion(String text) {
    _textController.text = text;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    _inputFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final hasMessages = chatState.messages.isNotEmpty;

    return Scaffold(
      backgroundColor: WandererColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _Header(isTyping: chatState.isTyping),
            Expanded(
              child: hasMessages
                  ? Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                          itemCount: chatState.messages.length +
                              (chatState.isTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == chatState.messages.length &&
                                chatState.isTyping) {
                              return const TypingIndicator();
                            }
                            return MessageBubble(
                                message: chatState.messages[index]);
                          },
                        ),
                        Positioned(
                          bottom: 12,
                          right: 16,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _showJumpButton,
                            builder: (context, show, _) {
                              return AnimatedOpacity(
                                opacity: show ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: IgnorePointer(
                                  ignoring: !show,
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Material(
                                      color: WandererColors.surface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(
                                          color: WandererColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: _scrollToBottom,
                                        borderRadius: BorderRadius.circular(20),
                                        child: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: WandererColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : _EmptyState(onSuggestion: _useSuggestion),
            ),
            _InputBar(
              controller: _textController,
              focusNode: _inputFocus,
              canSend: _canSend,
              onSubmit: () => _sendMessage(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _inputFocus.dispose();
    _showJumpButton.dispose();
    super.dispose();
  }
}

class _Header extends StatelessWidget {
  final bool isTyping;
  const _Header({required this.isTyping});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [WandererColors.primary, WandererColors.primaryMuted],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: WandererColors.primary.withValues(alpha: 0.35),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.explore, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wanderer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: WandererColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  isTyping ? 'Thinking...' : 'Your AI Guide',
                  key: ValueKey(isTyping),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isTyping ? WandererColors.primary : WandererColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: WandererColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: WandererColors.surfaceLight),
            ),
            child: const Icon(Icons.tune_rounded, color: WandererColors.textSecondary, size: 18),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onSuggestion;
  const _EmptyState({required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Center(
            child: _GlowOrb()
                .animate()
                .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Where shall we wander today?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: WandererColors.textPrimary,
              letterSpacing: -0.6,
              height: 1.15,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(
                begin: 0.12,
                end: 0,
                delay: 200.ms,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),
          const SizedBox(height: 10),
          Text(
            'Ask for cafés, hidden corners, or local wisdom.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: WandererColors.textSecondary.withValues(alpha: 0.85),
            ),
          ).animate().fadeIn(delay: 320.ms, duration: 400.ms),
          const SizedBox(height: 36),
          ...List.generate(_ChatScreenState._suggestions.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SuggestionChip(
                label: _ChatScreenState._suggestions[i],
                onTap: () => onSuggestion(_ChatScreenState._suggestions[i]),
              ),
            ).animate().fadeIn(delay: (420 + i * 70).ms, duration: 380.ms).slideY(
                  begin: 0.18,
                  end: 0,
                  delay: (420 + i * 70).ms,
                  duration: 380.ms,
                  curve: Curves.easeOutCubic,
                );
          }),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatefulWidget {
  @override
  State<_GlowOrb> createState() => _GlowOrbState();
}

class _GlowOrbState extends State<_GlowOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = Curves.easeInOut.transform(_c.value);
        return Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [WandererColors.primary, WandererColors.primaryMuted],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: WandererColors.primary.withValues(alpha: 0.28 + 0.14 * t),
                blurRadius: 34 + 14 * t,
                spreadRadius: 4 + 3 * t,
              ),
              BoxShadow(
                color: WandererColors.primaryMuted.withValues(alpha: 0.18 + 0.1 * t),
                blurRadius: 60 + 20 * t,
                spreadRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
        );
      },
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Semantics(
        button: true,
        label: 'Suggestion: $label',
        child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: WandererColors.primary.withValues(alpha: 0.08),
        highlightColor: WandererColors.primary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: WandererColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: WandererColors.surfaceLight),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: WandererColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.north_east_rounded,
                    size: 14, color: WandererColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: WandererColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: WandererColors.textMuted),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canSend;
  final VoidCallback onSubmit;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.canSend,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: WandererColors.background,
        border: Border(
          top: BorderSide(
            color: WandererColors.surfaceLight.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 52, maxHeight: 140),
              decoration: BoxDecoration(
                color: WandererColors.surface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: WandererColors.surfaceLight),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              alignment: Alignment.center,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: null,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSubmit(),
                cursorColor: WandererColors.primary,
                style: const TextStyle(
                  color: WandererColors.textPrimary,
                  fontSize: 15.5,
                  height: 1.35,
                ),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  hintText: 'Ask your guide...',
                  hintStyle: TextStyle(color: WandererColors.textMuted, fontSize: 15.5),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedScale(
            scale: canSend ? 1.0 : 0.94,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: Material(
              color: Colors.transparent,
              child: Semantics(
                button: true,
                label: canSend ? 'Send message' : 'Send message (disabled)',
                child: InkWell(
                onTap: canSend ? onSubmit : null,
                borderRadius: BorderRadius.circular(26),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: canSend
                        ? const LinearGradient(
                            colors: [WandererColors.primary, WandererColors.primaryMuted],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: canSend ? null : WandererColors.surfaceLight,
                    boxShadow: canSend
                        ? [
                            BoxShadow(
                              color: WandererColors.primary.withValues(alpha: 0.35),
                              blurRadius: 14,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: canSend ? Colors.white : WandererColors.textMuted,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
        ],  // Row children
      ),
    );
  }
}

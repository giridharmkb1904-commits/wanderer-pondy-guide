import 'package:flutter_test/flutter_test.dart';
import 'package:wanderer_app/features/chat/domain/message_entity.dart';

void main() {
  group('ChatMessage', () {
    test('creates user message', () {
      final msg = ChatMessage.user('Hello');
      expect(msg.role, MessageRole.user);
      expect(msg.content, 'Hello');
      expect(msg.cards, isNull);
    });

    test('creates assistant message', () {
      final msg = ChatMessage.assistant('Welcome to Pondicherry!');
      expect(msg.role, MessageRole.assistant);
      expect(msg.content, 'Welcome to Pondicherry!');
    });

    test('creates assistant message with cards', () {
      final msg = ChatMessage.assistant(
        'Here are some restaurants',
        cards: [{'type': 'place', 'name': 'Le Cafe'}],
      );
      expect(msg.cards, isNotNull);
      expect(msg.cards!.length, 1);
    });
  });
}

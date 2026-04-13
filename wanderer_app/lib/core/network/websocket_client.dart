import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/env_config.dart';

class WsClient {
  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  void connect(String sessionId) {
    final uri = Uri.parse('${EnvConfig.wsBaseUrl}/api/v1/chat/ws/$sessionId');
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (data) {
        final decoded = jsonDecode(data as String) as Map<String, dynamic>;
        _messageController.add(decoded);
      },
      onError: (error) => _messageController.addError(error),
      onDone: () => _messageController.add({'type': 'disconnected'}),
    );
  }

  void sendText(String message) {
    _channel?.sink.add(jsonEncode({'type': 'text', 'content': message}));
  }

  void sendPing() {
    _channel?.sink.add(jsonEncode({'type': 'ping'}));
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}

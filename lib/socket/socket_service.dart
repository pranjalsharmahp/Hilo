// lib/socket/socket_service.dart
import 'dart:convert';
import 'package:hilo/crud/local_database_service.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  void Function(dynamic data)? onMessageReceived;
  // Singleton pattern
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  SocketService._internal();

  late IO.Socket socket;
  bool _connected = false;

  void initSocket(String myEmail) {
    if (_connected) return; // prevent multiple inits

    socket = IO.io('https://hilo-backend-ozkp.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'email': myEmail},
    });

    socket.connect();

    socket.onConnect((_) {
      print('Socket connected');
      socket.emit('joinRoom', myEmail);
      _connected = true;
    });

    socket.on('messageReceived', (data) async {
      try {
        print('TOP OF HANDLER'); // will always run

        await LocalDatabaseService().insertMessage({
          'sender_email': data['sender_email'],
          'receiver_email': data['receiver_email'],
          'content': data['content'],
          'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
        });
        print('AFTER insertMessage');

        await LocalDatabaseService().upsertConversation({
          'user1_email': data['sender_email'],
          'user2_email': data['receiver_email'],
          'last_message': data['content'],
          'last_sender_email': data['sender_email'],
          'last_updated': data['timestamp'] ?? DateTime.now().toIso8601String(),
        });
        print('AFTER upsertConversation');

        print('Message received: $data');
        if (onMessageReceived != null) {
          onMessageReceived!(data);
        }
      } catch (e, stack) {
        print('!!! ERROR in messageReceived handler: $e');
        print(stack);
      }
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
      _connected = false;
    });

    socket.onConnectError((err) {
      print('Connection error: $err');
    });

    socket.onError((err) {
      print('General error: $err');
    });
  }

  Future<void> sendMessage(
    String senderEmail,
    String receiverEmail,
    String message,
  ) async {
    if (!_connected) {
      print('Socket is not connected yet.');
      return;
    }

    socket.emit('sendMessage', {
      'sender_email': senderEmail,
      'receiver_email': receiverEmail,
      'content': message,
    });

    print('Socket message emit sent.');

    try {
      final response = await http.post(
        Uri.parse('https://hilo-backend-ozkp.onrender.com/conversations/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "user1_email": senderEmail,
          "user2_email": receiverEmail,
          "last_message": message,
          "last_sender_email": senderEmail,
        }),
      );

      if (response.statusCode == 201) {
        print('Conversation updated on backend.');
        await LocalDatabaseService().insertMessage({
          'sender_email': senderEmail,
          'receiver_email': receiverEmail,
          'content': message,
          'timestamp': DateTime.now().toIso8601String(),
          'isSeen': 1,
          'type': 'TEXT',
        });
        await LocalDatabaseService().upsertConversation({
          'user1_email': senderEmail, // or sorted by alpha for uniqness
          'user2_email': receiverEmail,
          'last_message': message,
          'last_sender_email': senderEmail,
          'last_updated': DateTime.now().toIso8601String(),
        });
      } else {
        print('Failed to update conversation: ${response.body}');
      }
    } catch (e) {
      print('HTTP POST error: $e');
    }
  }

  void disconnect() {
    if (_connected) {
      socket.disconnect();
      _connected = false;
    }
  }
}

// lib/socket/socket_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
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

    socket.on('messageReceived', (data) {
      print('Message received: $data');
      // Add event notification logic here (e.g., notify listeners)
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

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends StatefulWidget {
  const SocketService({super.key});

  @override
  State<SocketService> createState() => _SocketServiceState();
}

class _SocketServiceState extends State<SocketService> {
  late IO.Socket socket;

  void initSocket(String myEmail) {
    socket = IO.io('https://hilo-backend-ozkp.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'email': myEmail},
    });
    socket.connect();
    socket.onConnect((_) {
      print('Socket connected');
      socket.emit('joinRoom', myEmail);
    });
    socket.on('receiveMessage', (data) {
      print('Message received: $data');
    });
    socket.on('connect_error', (err) {
      print('❌ Connection Error: $err');
    });

    socket.on('error', (err) {
      print('❌ General Error: $err');
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });
  }

  void sendMessage(String senderEmail, String receiverEmail, String message) {
    if (socket.connected) {
      socket.emit('sendMessage', {
        'sender_email': senderEmail,
        'receiver_email': receiverEmail,
        'content': message,
      });
      print('Message sent: $message');
    } else {
      print('Socket is not connected');
    }
  }

  @override
  void initState() {
    initSocket('myEmail');

    super.initState();
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Socket Service'),
      ),
    );
  }
}

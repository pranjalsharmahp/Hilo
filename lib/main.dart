import 'package:flutter/material.dart';
import 'package:hilo/socket/socket_service.dart';
import 'package:hilo/views/inbox_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize the singleton socket service and connect before running the app
  SocketService().initSocket('pranjal@gmail.com');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hilo Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const InboxScreen(userEmail: 'pranjal@gmail.com'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hilo/crud/local_database_service.dart';
import 'package:hilo/features/inbox/bloc/inbox_bloc.dart';
import 'package:hilo/views/chat_view.dart';
import 'package:hilo/socket/socket_service.dart';
import 'package:hilo/views/inbox_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hilo/views/login/bloc/login_bloc.dart';
import 'package:hilo/views/login_view.dart';
import 'package:hilo/views/register/bloc/register_bloc.dart';
import 'package:hilo/views/login/register_view.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final currentUserEmail = 'prerna@gmail.com';
  await LocalDatabaseService().initialLocalSync(currentUserEmail);
  // Initialize the singleton socket service and connect before running the app
  SocketService().initSocket(currentUserEmail);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginBloc()),
        BlocProvider(create: (_) => RegisterBloc()),
        BlocProvider(create: (_) => InboxBloc()),
      ],
      child: MyApp(),
    ),
  );
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
      home: InboxScreen(userEmail: 'pranjal@gmail.com'),
    );
  }
}

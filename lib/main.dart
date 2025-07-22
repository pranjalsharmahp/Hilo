import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hilo/crud/local_database_service.dart';
import 'package:hilo/delete_view.dart';
import 'package:hilo/features/auth/bloc/auth_bloc.dart';
import 'package:hilo/features/auth/bloc/auth_event.dart';
import 'package:hilo/features/auth/bloc/auth_state.dart';
import 'package:hilo/features/auth/firebase_auth_provider.dart';
import 'package:hilo/features/inbox/bloc/inbox_bloc.dart';
import 'package:hilo/views/chat_view.dart';
import 'package:hilo/socket/socket_service.dart';
import 'package:hilo/views/email_verification_view.dart';
import 'package:hilo/views/inbox_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hilo/views/login/bloc/login_bloc.dart';
import 'package:hilo/views/login/login_view.dart';
import 'package:hilo/views/profile_view.dart';
import 'package:hilo/views/register/bloc/register_bloc.dart';
import 'package:hilo/views/register/register_view.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // await LocalDatabaseService().initialLocalSync(currentUserEmail);
  // // Initialize the singleton socket service and connect before running the app
  // SocketService().initSocket(currentUserEmail);

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 143, 92, 230),
        ),
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return InboxScreen(userEmail: state.user.email);
        } else if (state is AuthStateNeedsVerification) {
          return const EmailVerificationView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Center(child: Text('Unknown state'));
        }
      },
    );
  }
}

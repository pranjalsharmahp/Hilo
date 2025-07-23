import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hilo/dialogs/error_dialog.dart';
import 'package:hilo/features/auth/auth_exceptions.dart';
import 'package:hilo/features/auth/bloc/auth_bloc.dart';
import 'package:hilo/features/auth/bloc/auth_event.dart';
import 'package:hilo/features/auth/bloc/auth_state.dart';
import 'package:hilo/features/inbox/bloc/inbox_bloc.dart';
import 'package:hilo/features/inbox/bloc/inbox_event.dart';
import 'dart:developer' as devtools;

import 'package:hilo/views/inbox_view.dart';
import 'package:hilo/views/login/bloc/login_bloc.dart';
import 'package:hilo/views/login/bloc/login_event.dart';
import 'package:hilo/views/login/bloc/login_state.dart';
import 'package:hilo/views/register/register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _isLoading = false; // <-- loading state

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateLoggedOut) {
            if (state.exception is UserNotFoundAuthException) {
              await showErrorDialog(
                context,
                'User not found. Please register.',
              );
            } else if (state.exception is InvalidCredentialsAuthException) {
              await showErrorDialog(
                context,
                'Invalid credentials. Please try again.',
              );
            } else if (state.exception is GenericAuthException) {
              await showErrorDialog(
                context,
                'Authentication failed. Please try again.',
              );
            }
          }
        },
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please login to your account',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () async {
                                  final email = _email.text;
                                  final password = _password.text;
                                  try {
                                    context.read<AuthBloc>().add(
                                      AuthEventLogIn(
                                        email: email,
                                        password: password,
                                      ),
                                    );
                                    context.read<InboxBloc>().add(
                                      LoadInbox(email),
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    devtools.log('Login error: $e');
                                    await showErrorDialog(
                                      context,
                                      'Login failed. Please try again.',
                                    );
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Login', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            const AuthEventShouldRegister(),
                          );
                        },
                        child: Text('Don\'t have an account? Register'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

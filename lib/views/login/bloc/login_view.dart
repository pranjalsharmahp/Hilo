import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hilo/dialogs/error_dialog.dart';
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
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) async {
          if (state is LoginLoading) {
            // Show loading indicator
          } else if (state is LoginSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => InboxView(userEmail: state.email),
              ),
            );
          } else if (state is LoginFailure) {
            await showErrorDialog(context, state.error);
          }
        },
        child: Center(
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
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      try {
                        context.read<LoginBloc>().add(
                          LoginSubmitted(email: email, password: password),
                        );
                        context.read<InboxBloc>().add(LoadInbox(email));
                      } on PlatformException catch (e) {
                        devtools.log('Login error: $e');
                        await showErrorDialog(
                          context,
                          'Login failed. Please try again.',
                        );
                      } catch (e) {
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
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => RegisterView()),
                      );
                    },
                    child: Text('Don\'t have an account? Register'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

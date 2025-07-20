import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hilo/views/login/bloc/login_event.dart';
import 'package:hilo/views/login/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        // Simulate a login process

        final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        final userEmail = userCred.user?.email ?? '';

        emit(LoginSuccess(email: userEmail));
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'user-not-found':
            message = 'No account found for that email.';
            break;
          case 'invalid-email':
            message = 'The email address is invalid.';
            break;
          case 'wrong-password':
            message = 'Incorrect password.';
            break;
          case 'invalid-credential':
            message = 'Invalid credentials provided.';
            break;
          default:
            message = e.message ?? 'Login failed.';
        }
        emit(LoginFailure(error: message));
      } catch (error) {
        emit(LoginFailure(error: error.toString()));
      }
    });
  }
}

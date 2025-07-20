import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hilo/socket/socket_service.dart';
import 'package:hilo/views/register/bloc/register_event.dart';
import 'package:hilo/views/register/bloc/register_state.dart';
import 'package:http/http.dart' as http;

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterSubmitted>((event, emit) async {
      emit(RegisterLoading());
      try {
        final userCred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: event.email,
              password: event.password,
            );
        final statusCode = await SocketService().registerUser(
          event.email,

          event.name,
        );
        if (statusCode == 201) {
          emit(RegisterSuccess(email: userCred.user!.email!));
        } else if (statusCode == 409) {
          emit(RegisterFailure(error: 'Email already exists in database.'));
        } else {
          emit(RegisterFailure(error: 'Failed to register user.'));
        }
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'email-already-in-use':
            message = 'That email is already registered.';
            break;
          case 'invalid-email':
            message = 'The email address is invalid.';
            break;
          case 'weak-password':
            message = 'The password is too weak.';
            break;
          default:
            message = e.message ?? 'Registration failed.';
        }
        emit(RegisterFailure(error: message));
      } catch (e) {
        emit(RegisterFailure(error: e.toString()));
      }
    });
  }
}

import 'package:bloc/bloc.dart';
import 'package:hilo/features/auth/auth_exceptions.dart';
import 'package:hilo/features/auth/auth_provider.dart';
import 'package:hilo/features/auth/bloc/auth_event.dart';
import 'package:hilo/features/auth/bloc/auth_state.dart';
import 'package:hilo/socket/socket_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    on<AuthEventInitialize>((event, emit) async {
      //send email verification
      on<AuthEventSendEmailVerification>((event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      });
      on<AuthEventShouldRegister>((event, emit) {
        emit(AuthStateNeedsRegistering());
      });

      //register
      on<AuthEventRegister>((event, emit) async {
        final email = event.email;
        final password = event.password;
        try {
          await provider.register(email: email, password: password);
          await provider.sendEmailVerification();
          final statusCode = await SocketService().registerUser(
            event.email,

            event.name,
          );
          if (statusCode == 201) {
            emit(AuthStateNeedsVerification());
          } else if (statusCode == 409) {
            emit(AuthStateRegistering(FailedToRegisterToDatabase()));
          } else {
            emit(AuthStateRegistering(FailedToRegisterToDatabase()));
          }
          emit(const AuthStateNeedsVerification());
        } on Exception catch (e) {
          emit(AuthStateRegistering(e));
        }
      });
      //initialize
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });
    //login
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(exception: null));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        if (!user!.isEmailVerified) {
          emit(const AuthStateNeedsVerification());
          emit(const AuthStateLoggedOut(exception: null));
        } else {
          emit(const AuthStateLoggedOut(exception: null));
          emit(AuthStateLoggedIn(user));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e));
      }
    });
    //logOut
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null));
      } on Exception catch (e) {
        print(e.toString());
        emit(AuthStateLoggedOut(exception: e));
      }
    });
  }
}

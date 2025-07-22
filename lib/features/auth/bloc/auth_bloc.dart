import 'package:bloc/bloc.dart';
import 'package:hilo/features/auth/auth_provider.dart';
import 'package:hilo/features/auth/bloc/auth_event.dart';
import 'package:hilo/features/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    on<AuthEventInitialize>((event, emit) async {
      //send email verification
      on<AuthEventSendEmailVerification>((event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      });

      //register
      on<AuthEventRegister>((event, emit) async {
        final email = event.email;
        final password = event.password;
        try {
          await provider.register(email: email, password: password);
          await provider.sendEmailVerification();
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
          emit(const AuthStateLoggedOut(exception: null));
          emit(const AuthStateNeedsVerification());
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
        emit(AuthStateLoggedOut(exception: e));
      }
    });
  }
}

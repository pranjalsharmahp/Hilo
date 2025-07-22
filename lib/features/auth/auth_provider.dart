import 'package:hilo/features/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();

  AuthUser? get currentUser;

  Future<AuthUser?> logIn({required String email, required String password});

  Future<AuthUser?> register({required String email, required String password});

  Future<void> sendEmailVerification();

  Future<void> logOut();
  Future<void> reloadUser();
}

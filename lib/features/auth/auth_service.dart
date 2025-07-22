import 'package:hilo/features/auth/auth_provider.dart';
import 'package:hilo/features/auth/auth_user.dart';
import 'package:hilo/features/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider authProvider;
  AuthService(this.authProvider);

  factory AuthService.firebase() {
    return AuthService(FirebaseAuthProvider());
  }
  @override
  Future<void> initialize() async {
    await authProvider.initialize();
  }

  @override
  AuthUser? get currentUser {
    return authProvider.currentUser;
  }

  @override
  Future<AuthUser?> logIn({
    required String email,
    required String password,
  }) async {
    return await authProvider.logIn(email: email, password: password);
  }

  @override
  Future<AuthUser?> register({
    required String email,
    required String password,
  }) async {
    // Register a new user with email and password
    return await authProvider.register(email: email, password: password);
  }

  @override
  Future<void> sendEmailVerification() async {
    await authProvider.sendEmailVerification();
  }

  @override
  Future<void> logOut() async {
    // Log out the current user
    await authProvider.logOut();
  }

  @override
  Future<void> reloadUser() async {
    authProvider.reloadUser();
  }
}

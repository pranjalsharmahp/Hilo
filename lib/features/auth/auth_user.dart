import 'package:firebase_auth/firebase_auth.dart' show User;

class AuthUser {
  final String email;
  final String? id;
  final bool isEmailVerified;

  AuthUser({
    required this.email,
    required this.id,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(User user) {
    return AuthUser(
      email: user.email!,
      id: user.uid,
      isEmailVerified: user.emailVerified,
    );
  }
}

class User {
  final String email;
  final String name;
  final String? profilePictureUrl;
  final String? bio;

  User(
    this.profilePictureUrl,
    this.bio, {
    required this.email,
    required this.name,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    final profilePictureUrl = json['profile_url'] ?? '';
    final bio = json['bio'] ?? '';

    return User(
      profilePictureUrl,
      bio,
      email: json['email'],
      name: json['name'],
    );
  }
}

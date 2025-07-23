class Person {
  final String name;
  final String email;
  final String bio;
  final String? profilePictureUrl;
  Person(
    this.profilePictureUrl, {
    required this.name,
    required this.email,
    required this.bio,
  });

  // From JSON
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      json['profile_url'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'bio': bio};
  }
}

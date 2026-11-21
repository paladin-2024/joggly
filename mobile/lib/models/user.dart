class AuthenticatedUser {
  final String id;
  final String email;
  final String displayName;

  AuthenticatedUser({required this.id, required this.email, required this.displayName});

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) => AuthenticatedUser(
        id: json['userId'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
      );
}

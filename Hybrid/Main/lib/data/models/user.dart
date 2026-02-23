class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String,
    role: json['role'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'createdAt': createdAt.toIso8601String(),
  };
}

class AuthResult {
  final String token;
  final User user;

  const AuthResult({
    required this.token,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
    token: json['token'] as String,
    user: User.fromJson(json['user'] as Map<String, dynamic>),
  );
}

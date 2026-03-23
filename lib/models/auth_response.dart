import 'package:equatable/equatable.dart';

class AuthResponse extends Equatable {
  final String token;
  final String refreshToken;
  final String email;
  final String role;
  final int userId;
  final DateTime expiresAt;

  const AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.email,
    required this.role,
    required this.userId,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      userId: json['userId'] ?? 0,
      expiresAt: DateTime.tryParse(json['expiresAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [token, refreshToken, email, role, userId, expiresAt];
}

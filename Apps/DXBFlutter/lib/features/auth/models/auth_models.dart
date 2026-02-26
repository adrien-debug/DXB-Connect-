class UserInfo {
  final String id;
  final String email;
  final String? name;

  const UserInfo({required this.id, required this.email, this.name});

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
      };
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserInfo user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      );
}

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

enum UserType { motorista, colaborador }

UserType _parseUserType(String? type) {
  if (type == null) return UserType.colaborador;
  final normalized = type.toLowerCase();
  if (normalized.contains('driver') || normalized.contains('motorista')) {
    return UserType.motorista;
  }
  return UserType.colaborador;
}

class User {
  final String id;
  final String name;
  final String? email;
  final UserType userType;
  final String? accessToken;
  final String? refreshToken;
  final bool mustChangePassword;

  User({
    required this.id,
    required this.name,
    this.email,
    required this.userType,
    this.accessToken,
    this.refreshToken,
    this.mustChangePassword = false,
  });

  factory User.fromAuthResponse(Map<String, dynamic> json) {
    final person = (json['person'] ?? json['user']) as Map<String, dynamic>?;
    final personType = person?['type'] as String? ?? person?['userType'] as String?;

    return User(
      id: (person?['id'] ?? json['id']).toString(),
      name: person?['name'] as String? ?? json['name'] as String? ?? '',
      email: person?['email'] as String?,
      userType: _parseUserType(personType),
      accessToken: json['access_token'] as String? ?? json['access'] as String?,
      refreshToken: json['refresh_token'] as String? ?? json['refresh'] as String?,
      mustChangePassword: json['must_change_password'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': userType == UserType.motorista ? 'DRIVER' : 'COLLABORATOR',
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'must_change_password': mustChangePassword,
    };
  }
}
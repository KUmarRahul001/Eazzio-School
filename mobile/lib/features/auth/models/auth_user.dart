enum UserRole {
  student,
  teacher,
  principal,
  admin,
  accountant,
  unknown;

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.unknown;
    switch (role.toUpperCase()) {
      case 'STUDENT':
        return UserRole.student;
      case 'TEACHER':
        return UserRole.teacher;
      case 'PRINCIPAL':
        return UserRole.principal;
      case 'ADMIN':
        return UserRole.admin;
      case 'ACCOUNTANT':
        return UserRole.accountant;
      default:
        return UserRole.unknown;
    }
  }

  String toServerString() {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.principal:
        return 'principal';
      case UserRole.admin:
        return 'admin';
      case UserRole.accountant:
        return 'accountant';
      case UserRole.unknown:
        return '';
    }
  }
}

class AuthUser {
  final int userId;
  final String name;
  final String loginId;
  final UserRole role;
  final int schoolId;

  AuthUser({
    required this.userId,
    required this.name,
    required this.loginId,
    required this.role,
    required this.schoolId,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId'].toString()) ?? 0,
      name: json['name'] ?? '',
      loginId: json['loginId'] ?? '',
      role: UserRole.fromString(json['role']),
      schoolId: json['schoolId'] is int
          ? json['schoolId']
          : int.tryParse(json['schoolId'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'loginId': loginId,
      'role': role.name.toUpperCase(),
      'schoolId': schoolId,
    };
  }
}

class LoginResponse {
  final bool success;
  final String? token;
  final AuthUser? user;
  final String? error;

  LoginResponse({
    required this.success,
    this.token,
    this.user,
    this.error,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] == true;
    if (success && json['data'] != null) {
      final data = json['data'];
      return LoginResponse(
        success: true,
        token: data['token'],
        user: data['user'] != null ? AuthUser.fromJson(data['user']) : null,
      );
    }
    return LoginResponse(
      success: false,
      error: json['error'] ?? 'Login failed',
    );
  }
}

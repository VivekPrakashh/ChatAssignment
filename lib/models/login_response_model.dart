class LoginResponseModel {
  final bool encrypted;
  final LoginData data;

  LoginResponseModel({required this.encrypted, required this.data});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      encrypted: json['encrypted'] ?? false,
      data: LoginData.fromJson(json['data']),
    );
  }
}

class LoginData {
  final String token;
  final LoginUser user;

  LoginData({required this.token, required this.user});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] ?? '',
      user: LoginUser.fromJson(json['user']),
    );
  }
}

class LoginUser {
  final String id;
  final String role;
  final String name;
  final String? email;

  LoginUser({
    required this.id,
    required this.role,
    required this.name,
    this.email,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      id: json['_id'] ?? '',
      role: json['role'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
    );
  }
}

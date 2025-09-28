import 'dart:convert';

/// Represents the Level object
class Level {
  final String levelId;

  Level({required this.levelId});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(levelId: json['levelId'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'levelId': levelId};
  }

  /// Convert from JSON string
  static Level fromJsonString(String jsonString) {
    return Level.fromJson(jsonDecode(jsonString));
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }
}

/// Represents a User as defined in your Spring Boot backend.
class UserModel {
  final String userId;
  final String names;
  final String email;
  final String password;
  final String phone;
  final int nationalId;
  final String role;
  final Level? level;

  UserModel({
    required this.userId,
    required this.names,
    required this.email,
    required this.password,
    required this.phone,
    required this.nationalId,
    required this.role,
    this.level,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? '',
      names: json['names'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['phone'] ?? '',
      nationalId: json['nationalId'] ?? 0,
      role: json['role'] ?? '',
      level: json['level'] != null ? Level.fromJson(json['level']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'names': names,
      'email': email,
      'password': password,
      'phone': phone,
      'nationalId': nationalId,
      'role': role,
      'level': level?.toJson(),
    };
  }

  /// Convert from JSON string
  static UserModel fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }
}

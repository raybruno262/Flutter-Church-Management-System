import 'dart:convert';
import 'dart:typed_data';
import 'level_model.dart';

class UserModel {
  final String? userId;
  final String names;
  final String email;
  final String password;
  final String phone;
  final int nationalId;
  final String role;
  final Uint8List profilePic;
  final bool isActive;
  final Level level;

  UserModel({
    this.userId,
    required this.names,
    required this.email,
    required this.password,
    required this.phone,
    required this.nationalId,
    required this.role,
    required this.profilePic,
    required this.isActive,
    required this.level,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      names: json['names'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['phone'] ?? '',
      nationalId: json['nationalId'] is int
          ? json['nationalId']
          : int.tryParse(json['nationalId'].toString()),
      role: json['role'] ?? '',

      profilePic: base64Decode(json['profilePic']),

      isActive: json['isActive'] is bool
          ? json['isActive']
          : json['isActive'].toString().toLowerCase() == 'true',

      level: Level.fromJson(json['level']),
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
      'profilePic': base64Encode(profilePic),
      'isActive': isActive,
      'level': level.toJson(),
    };
  }

  static UserModel fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

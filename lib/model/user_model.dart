import 'dart:convert';
import 'dart:typed_data';
import 'level_model.dart';

class UserModel {
  final String? userId;
  final String names;
  final String email;
  final String password;
  final String phone;
  final int? nationalId;
  final String role;
  final Uint8List? profilePic;
  final bool isActive;
  final Level? level;

  UserModel({
    this.userId,
    required this.names,
    required this.email,
    required this.password,
    required this.phone,
    required this.nationalId,
    required this.role,
    this.profilePic,
    required this.isActive,
    this.level,
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
      profilePic: json['profilePic'] != null
          ? base64Decode(json['profilePic'])
          : null,
      isActive: json['isActive'] is bool
          ? json['isActive']
          : json['isActive'].toString().toLowerCase() == 'true',
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
      'profilePic': profilePic != null ? base64Encode(profilePic!) : null,
      'isActive': isActive,
      'level': level?.toJson(),
    };
  }

  static UserModel fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

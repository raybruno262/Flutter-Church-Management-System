import 'dart:convert';

import 'followup_model.dart';
import 'level_model.dart';

class Visitor {
  final String? visitorId;
  final String names;
  final String phone;
  final String gender;
  final String email;
  final String address;
  final String? visitDate; // formatted as MM/dd/yyyy
  final String status; // new, follow-up, converted, dropped
  final FollowUp? followUp;
  final Level? level;

  Visitor({
    this.visitorId,
    required this.names,
    required this.phone,
    required this.gender,
    required this.email,
    required this.address,
    this.visitDate,
    required this.status,
    this.followUp,
    this.level,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      visitorId: json['visitorId'],
      names: json['names'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      visitDate: json['visitDate'],
      status: json['status'] ?? '',
      followUp: json['followUp'] != null
          ? FollowUp.fromJson(json['followUp'])
          : null,
      level: json['level'] != null ? Level.fromJson(json['level']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitorId': visitorId,
      'names': names,
      'phone': phone,
      'gender': gender,
      'email': email,
      'address': address,
      'visitDate': visitDate,
      'status': status,
      'followUp': followUp?.toJson(),
      'level': level?.toJson(),
    };
  }

  static Visitor fromJsonString(String jsonString) {
    return Visitor.fromJson(jsonDecode(jsonString));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

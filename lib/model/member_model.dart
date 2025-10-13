import 'dart:convert';
import 'dart:typed_data';

import 'department_model.dart';
import 'level_model.dart';
import 'baptismInformation_model.dart';

class Member {
  final String? memberId;
  final String names;
  final String? dateOfBirth;
  final String phone;
  final String gender;
  final String maritalStatus;
  final String email;
  final String status;
  final String address;
  final String? membershipDate;
  final BaptismInformation? baptismInformation;
  final Uint8List? profilePic;
  final Department? department;
  final Level? level;

  Member({
    this.memberId,
    required this.names,
    this.dateOfBirth,
    required this.phone,
    required this.gender,
    required this.maritalStatus,
    required this.email,
    required this.status,
    required this.address,
    this.membershipDate,
    this.baptismInformation,
    this.profilePic,
    this.department,
    this.level,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: json['memberId'] ?? '',
      names: json['names'] ?? '',
      dateOfBirth: json['dateOfBirth'],
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      maritalStatus: json['maritalStatus'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? '',
      address: json['address'] ?? '',
      membershipDate: json['membershipDate'],
      baptismInformation: json['baptismInformation'] != null
          ? BaptismInformation.fromJson(json['baptismInformation'])
          : null,
      profilePic: json['profilePic'] != null
          ? base64Decode(json['profilePic'])
          : null,
      department: json['department'] != null
          ? Department.fromJson(json['department'])
          : null,
      level: json['level'] != null ? Level.fromJson(json['level']) : null,
    );
  }

  get tags => null;

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'names': names,
      'dateOfBirth': dateOfBirth,
      'phone': phone,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'email': email,
      'status': status,
      'address': address,
      'membershipDate': membershipDate,
      'baptismInformation': baptismInformation?.toJson(),
      'profilePic': profilePic != null ? base64Encode(profilePic!) : null,
      'department': department?.toJson(),
      'level': level?.toJson(),
    };
  }

  static Member fromJsonString(String jsonString) {
    return Member.fromJson(jsonDecode(jsonString));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

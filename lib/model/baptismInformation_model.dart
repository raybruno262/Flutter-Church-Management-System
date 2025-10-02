import 'dart:convert';

import 'level_model.dart';

class BaptismInformation {
  final bool baptized;
  final bool sameReligion;
  final Level? baptismCell;
  final String? otherChurchName;
  final String? otherChurchAddress;

  BaptismInformation({
    required this.baptized,
    required this.sameReligion,
    this.baptismCell,
    this.otherChurchName,
    this.otherChurchAddress,
  });

  factory BaptismInformation.fromJson(Map<String, dynamic> json) {
    return BaptismInformation(
      baptized: json['baptized'] ?? false,
      sameReligion: json['sameReligion'] ?? false,
      baptismCell: json['baptismCell'] != null
          ? Level.fromJson(json['baptismCell'])
          : null,
      otherChurchName: json['otherChurchName'],
      otherChurchAddress: json['otherChurchAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baptized': baptized,
      'sameReligion': sameReligion,
      'baptismCell': baptismCell?.toJson(),
      'otherChurchName': otherChurchName,
      'otherChurchAddress': otherChurchAddress,
    };
  }

  static BaptismInformation fromJsonString(String jsonString) {
    return BaptismInformation.fromJson(jsonDecode(jsonString));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

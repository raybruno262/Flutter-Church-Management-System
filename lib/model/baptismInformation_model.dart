import 'dart:convert';

import 'level_model.dart';

class BaptismInformation {
  final bool baptized;
  final bool sameReligion;
  final Level? baptismChapel;
  final String? otherChurchName;
  final String? otherChurchAddress;

  BaptismInformation({
    required this.baptized,
    required this.sameReligion,
    this.baptismChapel,
    this.otherChurchName,
    this.otherChurchAddress,
  });

  factory BaptismInformation.fromJson(Map<String, dynamic> json) {
    return BaptismInformation(
      baptized: json['baptized'] ?? false,
      sameReligion: json['sameReligion'] ?? false,
      baptismChapel: json['baptismChapel'] != null
          ? Level.fromJson(json['baptismChapel'])
          : null,
      otherChurchName: json['otherChurchName'],
      otherChurchAddress: json['otherChurchAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baptized': baptized,
      'sameReligion': sameReligion,
      'baptismChapel': baptismChapel?.toJson(),
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

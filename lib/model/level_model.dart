import 'dart:convert';

class Level {
  final String? levelId;
  final String? name;
  final String? address;
  final String? levelType;
  final Level? parent;
  final bool? isActive;

  Level({
    this.levelId,
    this.name,
    this.address,
    this.levelType,
    this.parent,
    this.isActive,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      levelId: json['levelId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      levelType: json['levelType'] ?? '',
      parent: json['parent'] != null ? Level.fromJson(json['parent']) : null,
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'name': name,
      'address': address,
      'levelType': levelType,
      'parent': parent?.toJson(),
      'isActive': isActive,
    };
  }

  static Level fromJsonString(String jsonString) {
    return Level.fromJson(jsonDecode(jsonString));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

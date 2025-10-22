import 'dart:convert';

class EquipmentCategory {
  final String? equipmentCategoryId;
  final String name;

  EquipmentCategory({this.equipmentCategoryId, required this.name});

  factory EquipmentCategory.fromJson(Map<String, dynamic> json) {
    return EquipmentCategory(
      equipmentCategoryId: json['equipmentCategoryId'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'equipmentCategoryId': equipmentCategoryId, 'name': name};
  }

  static EquipmentCategory fromJsonString(String jsonString) {
    return EquipmentCategory.fromJson(jsonDecode(jsonString));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

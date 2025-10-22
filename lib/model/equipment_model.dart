import 'dart:convert';

import 'package:flutter_churchcrm_system/model/equipmentCategory_model.dart';
import 'package:flutter_churchcrm_system/model/level_model.dart';

class Equipment {
  final String? equipmentId;
  final String name;
  final EquipmentCategory equipmentCategory;
  final String purchaseDate;
  final double purchasePrice;
  final String condition; // Excellent, Good, Needs Repair, Out of Service
  final String? location; // where it is going to be used
  final String? description;
  final Level? level;

  Equipment({
    this.equipmentId,
    required this.name,
    required this.equipmentCategory,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.condition,
    this.location,
    this.description,
    this.level,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      equipmentId: json['equipmentId'],
      name: json['name'] ?? '',
      equipmentCategory: json['equipmentCategory'] != null
          ? EquipmentCategory.fromJson(json['equipmentCategory'])
          : EquipmentCategory(equipmentCategoryId: '', name: ''),
      purchaseDate: json['purchaseDate'] ?? '',
      purchasePrice: (json['purchasePrice'] ?? 0.0).toDouble(),
      condition: json['condition'] ?? '',
      location: json['location'] ?? '',
      description: json['description'],

      level: json['level'] != null ? Level.fromJson(json['level']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipmentId': equipmentId,
      'name': name,
      'equipmentCategory': equipmentCategory.toJson(),
      'purchaseDate': purchaseDate,
      'purchasePrice': purchasePrice,
      'condition': condition,
      'location': location,
      'description': description,
      'level': level?.toJson(),
    };
  }

  static Equipment fromJsonString(String jsonString) {
    return Equipment.fromJson(jsonDecode(jsonString));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

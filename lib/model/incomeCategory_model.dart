import 'dart:convert';

class IncomeCategory {
  final String? incomeCategoryId;
  final String name;

  IncomeCategory({this.incomeCategoryId, required this.name});

  factory IncomeCategory.fromJson(Map<String, dynamic> json) {
    return IncomeCategory(
      incomeCategoryId: json['incomeCategoryId'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'incomeCategoryId': incomeCategoryId, 'name': name};
  }

  static IncomeCategory fromJsonString(String jsonString) {
    return IncomeCategory.fromJson(jsonDecode(jsonString));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

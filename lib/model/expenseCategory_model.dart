import 'dart:convert';

class ExpenseCategory {
  final String? expenseCategoryId;
  final String name;

  ExpenseCategory({this.expenseCategoryId, required this.name});

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      expenseCategoryId: json['expenseCategoryId'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'expenseCategoryId': expenseCategoryId, 'name': name};
  }

  static ExpenseCategory fromJsonString(String jsonString) {
    return ExpenseCategory.fromJson(jsonDecode(jsonString));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

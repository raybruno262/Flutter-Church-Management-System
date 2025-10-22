import 'dart:convert';
import 'package:flutter_churchcrm_system/model/level_model.dart';

import 'incomeCategory_model.dart';
import 'expenseCategory_model.dart';

class Finance {
  final String? financeId;
  final dynamic category; // Can be IncomeCategory or ExpenseCategory
  final String transactionDate;
  final double amount;
  final String transactionType; // "income" or "expense"
  final String? description;
  final Level? level;

  Finance({
    this.financeId,
    required this.category,
    required this.transactionDate,
    required this.amount,
    required this.transactionType,
    this.description,
    this.level,
  });

  factory Finance.fromJson(Map<String, dynamic> json) {
    final type = json['transactionType'] ?? '';
    final categoryJson = json['category'];

    return Finance(
      financeId: json['financeId'],
      category: type == 'income'
          ? IncomeCategory.fromJson(categoryJson)
          : ExpenseCategory.fromJson(categoryJson),
      transactionDate: json['transactionDate'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      transactionType: type,
      description: json['description'] ?? '',
      level: json['level'] != null ? Level.fromJson(json['level']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'financeId': financeId,
      'category': category?.toJson(),
      'transactionDate': transactionDate,
      'amount': amount,
      'transactionType': transactionType,
      'description': description,
      'level': level?.toJson(),
    };
  }

  static Finance fromJsonString(String jsonString) {
    return Finance.fromJson(jsonDecode(jsonString));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

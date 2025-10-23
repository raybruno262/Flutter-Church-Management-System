import 'dart:convert';
import 'package:flutter_churchcrm_system/model/level_model.dart';

import 'incomeCategory_model.dart';
import 'expenseCategory_model.dart';

class Finance {
  final String? financeId;
  final IncomeCategory? incomeCategory;
  final ExpenseCategory? expenseCategory;
  final String transactionDate;
  final double amount;
  final String? transactionType; // "income" or "expense"
  final String? description;
  final Level? level;

  Finance({
    this.financeId,

    required this.transactionDate,
    required this.amount,
    this.incomeCategory,
    this.expenseCategory,
    this.transactionType,
    this.description,
    this.level,
  });

  factory Finance.fromJson(Map<String, dynamic> json) {
    final type = json['transactionType'] ?? '';
    final categoryJson = json['category'];

    return Finance(
      financeId: json['financeId'],

      transactionDate: json['transactionDate'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      transactionType: type,
      incomeCategory: json['incomeCategory'] != null
          ? IncomeCategory.fromJson(json['incomeCategory'])
          : null,
      expenseCategory: json['expenseCategory'] != null
          ? ExpenseCategory.fromJson(json['expenseCategory'])
          : null,
      description: json['description'] ?? '',
      level: json['level'] != null ? Level.fromJson(json['level']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'financeId': financeId,

      'transactionDate': transactionDate,
      'amount': amount,
      'transactionType': transactionType,
      'description': description,
      'incomeCategory': incomeCategory?.toJson(),
      'expenseCategory': expenseCategory?.toJson(),
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

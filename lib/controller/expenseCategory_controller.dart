import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_churchcrm_system/constants.dart';
import '../model/expenseCategory_model.dart';

class ExpenseCategoryController {
  final String baseUrl = '$baseHost/api/expenseCategory';

  // Create expense category
  Future<String> createExpenseCategory(ExpenseCategory category) async {
    try {
      final url = Uri.parse('$baseUrl/createExpenseCategory');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(category.toJson()),
      );
      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Update expense category
  Future<String> updateExpenseCategory(
    String expenseCategoryId,
    ExpenseCategory updatedCategory,
  ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/updateExpenseCategory/$expenseCategoryId',
      );
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedCategory.toJson()),
      );
      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Get all expense categories
  Future<List<ExpenseCategory>> getAllExpenseCategories() async {
    try {
      final url = Uri.parse('$baseUrl/allExpenseCategories');
      final response = await http.get(url);
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ExpenseCategory.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get expense category count
  Future<int> getExpenseCategoryCount() async {
    try {
      final url = Uri.parse('$baseUrl/count');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final int count = int.tryParse(response.body) ?? 0;
        return count;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  // Get paginated expense categories
  Future<List<ExpenseCategory>> getPaginatedExpenseCategories({
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/getPaginatedExpenseCategories?page=$page&size=$size',
      );
      final response = await http.get(url);
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => ExpenseCategory.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}

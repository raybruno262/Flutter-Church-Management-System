import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_churchcrm_system/constants.dart';
import '../model/incomeCategory_model.dart';

class IncomeCategoryController {
  final String baseUrl = '$baseHost/api/incomeCategory';

  // Create income category
  Future<String> createIncomeCategory(IncomeCategory category) async {
    try {
      final url = Uri.parse('$baseUrl/createIncomeCategory');
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

  // Update income category
  Future<String> updateIncomeCategory(
    String categoryId,
    IncomeCategory updatedCategory,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/updateIncomeCategory/$categoryId');
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

  // Get all income categories
  Future<List<IncomeCategory>> getAllIncomeCategories() async {
    try {
      final url = Uri.parse('$baseUrl/allIncomeCategories');
      final response = await http.get(url);
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => IncomeCategory.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get income category count
  Future<int> getIncomeCategoryCount() async {
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

  // Get paginated income categories
  Future<List<IncomeCategory>> getPaginatedIncomeCategories({
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/getPaginatedIncomeCategories?page=$page&size=$size',
      );
      final response = await http.get(url);
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => IncomeCategory.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}

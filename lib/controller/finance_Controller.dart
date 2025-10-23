import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_churchcrm_system/constants.dart';
import '../model/finance_model.dart';

class FinanceController {
  final String baseUrl = '$baseHost/api/finance';

  // Create finance record
  Future<String> createFinance(
    Finance finance, {

    required String userId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/createFinance/$userId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(finance.toJson()),
      );

      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Update finance record
  Future<String> updateFinance(
    String financeId,
    Finance updatedFinance,
    String userId,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/updateFinance/$financeId/$userId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedFinance.toJson()),
      );

      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Get all finance records
  Future<List<Finance>> getAllFinance() async {
    try {
      final url = Uri.parse('$baseUrl/allFinance');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Finance.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get paginated finance records
  Future<List<Finance>> getPaginatedFinance({
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/paginatedFinance?page=$page&size=$size');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> content = data['content'] ?? [];
        return content.map((json) => Finance.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get scoped paginated finance records
  Future<List<Finance>> getScopedPaginatedFinance({
    required String userId,
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/scopedPaginatedFinance?userId=$userId&page=$page&size=$size',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> content = data['content'] ?? [];
        return content.map((json) => Finance.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get finance by ID
  Future<Finance?> getFinanceById(String financeId) async {
    try {
      final url = Uri.parse('$baseUrl/$financeId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Finance.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching finance by ID: $e');
      return null;
    }
  }

  // Get finance statistics
  Future<Map<String, double>> getFinanceStats(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/stats?userId=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return {
          'totalIncome': (data['totalIncome'] ?? 0.0).toDouble(),
          'totalExpenses': (data['totalExpenses'] ?? 0.0).toDouble(),
          'currentBalance': (data['currentBalance'] ?? 0.0).toDouble(),
        };
      } else {
        return {
          'totalIncome': 0.0,
          'totalExpenses': 0.0,
          'currentBalance': 0.0,
        };
      }
    } catch (e) {
      return {'totalIncome': 0.0, 'totalExpenses': 0.0, 'currentBalance': 0.0};
    }
  }
}

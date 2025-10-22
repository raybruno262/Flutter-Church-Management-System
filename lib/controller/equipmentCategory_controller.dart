import 'dart:convert';
import 'package:flutter_churchcrm_system/model/equipmentCategory_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_churchcrm_system/constants.dart';

class EquipmentCategoryController {
  final String baseUrl = '$baseHost/api/equipmentCategory';

  // Create equipment category
  Future<String> createEquipmentCategory(EquipmentCategory category) async {
    try {
      final url = Uri.parse('$baseUrl/createEquipmentCategory');
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

  // Update equipment category
  Future<String> updateEquipmentCategory(
    String equipmentCategoryId,
    EquipmentCategory updatedCategory,
  ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/updateEquipmentCategory/$equipmentCategoryId',
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

  // Get all equipment categories
  Future<List<EquipmentCategory>> getAllEquipmentCategories() async {
    try {
      final url = Uri.parse('$baseUrl/allEquipmentCategories');
      final response = await http.get(url);
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => EquipmentCategory.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get equipment category count
  Future<int> getEquipmentCategoryCount() async {
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

  // Get paginated equipment categories
  Future<List<EquipmentCategory>> getPaginatedEquipmentCategories({
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/getPaginatedEquipmentCategories?page=$page&size=$size',
      );
      final response = await http.get(url);
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => EquipmentCategory.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}

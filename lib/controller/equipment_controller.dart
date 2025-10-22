import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_churchcrm_system/constants.dart';
import '../model/equipment_model.dart';

class EquipmentController {
  final String baseUrl = '$baseHost/api/equipment';

  // Create equipment
  Future<String> createEquipment(Equipment equipment, String userId) async {
    try {
      final url = Uri.parse('$baseUrl/createEquipment/$userId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(equipment.toJson()),
      );

      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Update equipment record
  Future<String> updateEquipment(
    String equipmentId,
    Equipment updatedEquipment,
    String userId,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/updateEquipment/$equipmentId/$userId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedEquipment.toJson()),
      );

      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Get all equipment records
  Future<List<Equipment>> getAllEquipment() async {
    try {
      final url = Uri.parse('$baseUrl/allEquipment');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Equipment.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get paginated equipment records
  Future<List<Equipment>> getPaginatedEquipment({
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/paginatedEquipment?page=$page&size=$size',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> content = data['content'] ?? [];
        return content.map((json) => Equipment.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get scoped paginated equipment records
  Future<List<Equipment>> getScopedPaginatedEquipment({
    required String userId,
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/scopedPaginatedEquipment?userId=$userId&page=$page&size=$size',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> content = data['content'] ?? [];
        return content.map((json) => Equipment.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get equipment by ID
  Future<Equipment?> getEquipmentById(String equipmentId) async {
    try {
      final url = Uri.parse('$baseUrl/$equipmentId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Equipment.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching equipment by ID: $e');
      return null;
    }
  }

  // Get equipment statistics
  Future<Map<String, int>> getEquipmentStats(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/stats?userId=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return {
          'totalEquipment': data['totalEquipment'] ?? 0,
          'excellentCount': data['excellentCount'] ?? 0,
          'goodCount': data['goodCount'] ?? 0,
          'needsRepairCount': data['needsRepairCount'] ?? 0,
          'outOfServiceCount': data['outOfServiceCount'] ?? 0,
        };
      } else {
        return {
          'totalEquipment': 0,
          'excellentCount': 0,
          'goodCount': 0,
          'needsRepairCount': 0,
          'outOfServiceCount': 0,
        };
      }
    } catch (e) {
      return {
        'totalEquipment': 0,
        'excellentCount': 0,
        'goodCount': 0,
        'needsRepairCount': 0,
        'outOfServiceCount': 0,
      };
    }
  }
}

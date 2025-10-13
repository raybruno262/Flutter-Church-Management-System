import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_churchcrm_system/constants.dart';
import '../model/level_model.dart';

class LevelController {
  final String baseUrl = '$baseHost/api/levels';

  // Create all levels (some fields optional)
  Future<String> createAllLevels({
    required String userId,
    required Map<String, String> payload,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/createAllLevels/$userId');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      return response.body;
    } catch (e) {
      print('Network error: $e');
      return 'Status 7000';
    }
  }

  //  Add one level under a parent
  Future<String> addOneLevel({
    required String levelName,
    required String levelAddress,
    required String parentId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/addOneLevel');
      final response = await http.post(
        url,
        body: {
          'levelName': levelName,
          'levelAddress': levelAddress,
          'parentId': parentId,
        },
      );
      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Update level (name, address, parent, isActive)
  Future<String> updateLevel(String levelId, Level updatedData) async {
    try {
      final url = Uri.parse('$baseUrl/updateLevel/$levelId');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData.toJson()),
      );
      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Get all levels
  Future<List<Level>> getAllLevels() async {
    try {
      final url = Uri.parse('$baseUrl/getAllLevels');
      final response = await http.get(url);
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Level.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  //get all cells
  Future<List<Level>> getAllCells() async {
    try {
      final url = Uri.parse('$baseUrl/allCells');
      final response = await http.get(url);
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Level.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  //  Paginated
  Future<List<Level>> getPaginatedLevels({int page = 0, int size = 5}) async {
    try {
      final url = Uri.parse('$baseUrl/paginatedLevels?page=$page&size=$size');
      final response = await http.get(url);
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => Level.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  //  Descendants
  Future<List<Level>> getAllDescendants(String parentId) async {
    try {
      final url = Uri.parse('$baseUrl/getAllDescendants?parentId=$parentId');
      final response = await http.get(url);
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Level.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  //  Single level
  Future<Level?> getLevelById(String levelId) async {
    try {
      final url = Uri.parse('$baseUrl/getLevelById?levelId=$levelId');
      final response = await http.get(url);
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final data = jsonDecode(response.body);
        return Level.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // get level counts per leveltype
  Future<Map<String, int>> getLevelCounts() async {
    try {
      final url = Uri.parse('$baseHost/api/levels/levelCounts');
      final response = await http.get(url);
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'regions': data['regions'] ?? 0,
        'parishes': data['parishes'] ?? 0,
        'chapels': data['chapels'] ?? 0,
        'cells': data['cells'] ?? 0,
      };
    } catch (e) {
      return {'regions': 0, 'parishes': 0, 'chapels': 0, 'cells': 0};
    }
  }
}

import 'dart:convert';
import 'package:flutter_churchcrm_system/model/levelType_model.dart';
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
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: payload,
      );
      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  //  Add one level under a parent
  Future<String> addOneLevel({
    required String userId,
    required String levelName,
    required String levelAddress,
    required String parentId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/addOneLevel/$userId');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
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

  //  Add cell  level under a parent
  Future<String> addCellLevel({
    required String levelName,
    required String levelAddress,
    required String userId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/addCellLevel/$userId');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'levelName': levelName, 'levelAddress': levelAddress},
      );
      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // get parent level by level type
  Future<List<Level>> getLevelsByType(LevelType type) async {
    final url = Uri.parse('$baseUrl/byType/${type.name}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Level.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load levels');
    }
  }

  // Update level (name, address, parent, isActive)
  Future<String> updateLevel({
    required String levelId,
    required String userId,
    required Level updatedData,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/updateLevel/$levelId/$userId');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData.toJson()),
      );

      final result = response.body;

      if (result.startsWith('Status 8000')) {
        final parts = result.split(':');
        return parts.length > 1
            ? parts.sublist(1).join(':').trim()
            : 'Blocked by inactive ancestor or parent.';
      }

      return result;
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

  //get all chapels
  Future<List<Level>> getAllChapels() async {
    try {
      final url = Uri.parse('$baseUrl/allChapels');
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
  Future<Map<String, Map<String, int>>> getLevelCounts() async {
    try {
      final url = Uri.parse('$baseHost/api/levels/levelCounts');
      final response = await http.get(url);
      final Map<String, dynamic> data = jsonDecode(response.body);

      return {
        'regions': {
          'total': data['regions']['total'] ?? 0,
          'active': data['regions']['active'] ?? 0,
          'inactive': data['regions']['inactive'] ?? 0,
        },
        'parishes': {
          'total': data['parishes']['total'] ?? 0,
          'active': data['parishes']['active'] ?? 0,
          'inactive': data['parishes']['inactive'] ?? 0,
        },
        'chapels': {
          'total': data['chapels']['total'] ?? 0,
          'active': data['chapels']['active'] ?? 0,
          'inactive': data['chapels']['inactive'] ?? 0,
        },
        'cells': {
          'total': data['cells']['total'] ?? 0,
          'active': data['cells']['active'] ?? 0,
          'inactive': data['cells']['inactive'] ?? 0,
        },
      };
    } catch (e) {
      return {
        'regions': {'total': 0, 'active': 0, 'inactive': 0},
        'parishes': {'total': 0, 'active': 0, 'inactive': 0},
        'chapels': {'total': 0, 'active': 0, 'inactive': 0},
        'cells': {'total': 0, 'active': 0, 'inactive': 0},
      };
    }
  }
}

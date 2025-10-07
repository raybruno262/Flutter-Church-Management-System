import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_churchcrm_system/constants.dart';
import '../model/level_model.dart';

class LevelController {
  final String baseUrl = '$baseHost/api/levels';

  // Create all levels (some fields optional)
  Future<String> createAllLevels({
    String? headquarterName,
    String? headquarterAddress,
    String? regionName,
    String? regionAddress,
    String? parishName,
    String? parishAddress,
    String? chapelName,
    String? chapelAddress,
    String? cellName,
    String? cellAddress,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/createAllLevels');
      final response = await http.post(
        url,
        body: {
          if (headquarterName != null) 'headquarterName': headquarterName,
          if (headquarterAddress != null)
            'headquarterAddress': headquarterAddress,
          if (regionName != null) 'regionName': regionName,
          if (regionAddress != null) 'regionAddress': regionAddress,
          if (parishName != null) 'parishName': parishName,
          if (parishAddress != null) 'parishAddress': parishAddress,
          if (chapelName != null) 'chapelName': chapelName,
          if (chapelAddress != null) 'chapelAddress': chapelAddress,
          if (cellName != null) 'cellName': cellName,
          if (cellAddress != null) 'cellAddress': cellAddress,
        },
      );
      return response.body;
    } catch (e) {
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

  Future<List<Level>> getAllActiveLevels() async {
    try {
      final url = Uri.parse('$baseUrl/getAllActiveLevels');
      final response = await http.get(url);
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Level.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Level>> getAllInactiveLevels() async {
    try {
      final url = Uri.parse('$baseUrl/getAllInactiveLevels');
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

  Future<List<Level>> getPaginatedActiveLevels({
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/getPaginatedActiveLevels?page=$page&size=$size',
      );
      final response = await http.get(url);
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => Level.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Level>> getPaginatedInactiveLevels({
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/getPaginatedInactiveLevels?page=$page&size=$size',
      );
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

  Future<List<Level>> getActiveDescendants(String parentId) async {
    try {
      final url = Uri.parse('$baseUrl/getActiveDescendants?parentId=$parentId');
      final response = await http.get(url);
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Level.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Level>> getInactiveDescendants(String parentId) async {
    try {
      final url = Uri.parse(
        '$baseUrl/getInactiveDescendants?parentId=$parentId',
      );
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
}

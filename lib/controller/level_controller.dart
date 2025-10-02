import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_churchcrm_system/constants.dart';
import '../model/level_model.dart';

class LevelController {
  final String baseUrl = '$baseHost/api/levels';

  // Create all levels at once
  Future<String> createAllLevels({
    required String headquarterName,
    required String headquarterAddress,
    required String regionName,
    required String regionAddress,
    required String parishName,
    required String parishAddress,
    required String chapelName,
    required String chapelAddress,
    required String cellName,
    required String cellAddress,
  }) async {
    final url = Uri.parse('$baseUrl/createAllLevels');
    final response = await http.post(
      url,
      body: {
        'headquarterName': headquarterName,
        'headquarterAddress': headquarterAddress,
        'regionName': regionName,
        'regionAddress': regionAddress,
        'parishName': parishName,
        'parishAddress': parishAddress,
        'chapelName': chapelName,
        'chapelAddress': chapelAddress,
        'cellName': cellName,
        'cellAddress': cellAddress,
      },
    );
    return response.body;
  }

  // Add one level under a parent
  Future<String> addOneLevel({
    required String levelName,
    required String levelAddress,
    required String parentId,
  }) async {
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
  }

  // Get all levels
  Future<List<Level>> getAllLevels() async {
    final url = Uri.parse('$baseUrl/getAllLevels');
    final response = await http.get(url);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Level.fromJson(json)).toList();
  }

  // Get all active levels
  Future<List<Level>> getAllActiveLevels() async {
    final url = Uri.parse('$baseUrl/getAllActiveLevels');
    final response = await http.get(url);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Level.fromJson(json)).toList();
  }

  // Get all inactive levels
  Future<List<Level>> getAllInactiveLevels() async {
    final url = Uri.parse('$baseUrl/getAllInactiveLevels');
    final response = await http.get(url);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Level.fromJson(json)).toList();
  }

  // Get paginated levels
  Future<List<Level>> getPaginatedLevels({int page = 0, int size = 5}) async {
    final url = Uri.parse('$baseUrl/paginatedLevels?page=$page&size=$size');
    final response = await http.get(url);
    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> content = data['content'];
    return content.map((json) => Level.fromJson(json)).toList();
  }

  // Get paginated active levels
  Future<List<Level>> getPaginatedActiveLevels({
    int page = 0,
    int size = 5,
  }) async {
    final url = Uri.parse(
      '$baseUrl/getPaginatedActiveLevels?page=$page&size=$size',
    );
    final response = await http.get(url);
    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> content = data['content'];
    return content.map((json) => Level.fromJson(json)).toList();
  }

  // Get paginated inactive levels
  Future<List<Level>> getPaginatedInactiveLevels({
    int page = 0,
    int size = 5,
  }) async {
    final url = Uri.parse(
      '$baseUrl/getPaginatedInactiveLevels?page=$page&size=$size',
    );
    final response = await http.get(url);
    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> content = data['content'];
    return content.map((json) => Level.fromJson(json)).toList();
  }

  // Get all descendants of a level
  Future<List<Level>> getAllDescendants(String parentId) async {
    final url = Uri.parse('$baseUrl/getAllDescendants?parentId=$parentId');
    final response = await http.get(url);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Level.fromJson(json)).toList();
  }

  // Get active descendants
  Future<List<Level>> getActiveDescendants(String parentId) async {
    final url = Uri.parse('$baseUrl/getActiveDescendants?parentId=$parentId');
    final response = await http.get(url);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Level.fromJson(json)).toList();
  }

  // Get inactive descendants
  Future<List<Level>> getInactiveDescendants(String parentId) async {
    final url = Uri.parse('$baseUrl/getInactiveDescendants?parentId=$parentId');
    final response = await http.get(url);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Level.fromJson(json)).toList();
  }

  // Get level by ID
  Future<Level?> getLevelById(String levelId) async {
    final url = Uri.parse('$baseUrl/getLevelById?levelId=$levelId');
    final response = await http.get(url);
    if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
      final data = jsonDecode(response.body);
      return Level.fromJson(data);
    }
    return null;
  }

  // Disable level and descendants
  Future<String> disableLevelAndDescendants(String levelId) async {
    final url = Uri.parse(
      '$baseUrl/disableLevelAndDescendants?levelId=$levelId',
    );
    final response = await http.put(url);
    return response.body;
  }

  // Enable level and descendants
  Future<String> enableLevelAndDescendants(String levelId) async {
    final url = Uri.parse(
      '$baseUrl/enableLevelAndDescendants?levelId=$levelId',
    );
    final response = await http.put(url);
    return response.body;
  }

  // Update level name or address
  Future<String> updateLevelNameOrAddress(
    String levelId,
    Level updatedData,
  ) async {
    final url = Uri.parse('$baseUrl/updateLevelNameorAddress/$levelId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedData.toJson()),
    );
    return response.body;
  }

  // Reassign level parent
  Future<String> reassignLevelParent(String levelId, String newParentId) async {
    final url = Uri.parse(
      '$baseUrl/reassignLevelParent?levelId=$levelId&newParentId=$newParentId',
    );
    final response = await http.put(url);
    return response.body;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_churchcrm_system/constants.dart';
import '../model/visitor_model.dart';

class VisitorController {
  final String baseUrl = '$baseHost/api/visitors';

  // Create visitor
  Future<String> createVisitor({
    required Visitor visitor,
    required String userId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/createVisitor/$userId');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(visitor.toJson()),
      );

      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  Future<String> updateVisitor({
    required String visitorId,
    required Visitor updatedVisitor,
    required String userId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/updateVisitor/$visitorId/$userId');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedVisitor.toJson()),
      );

      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Get all visitors
  Future<List<Visitor>> getAllVisitors() async {
    try {
      final url = Uri.parse('$baseUrl/allVisitors');
      final response = await http.get(url);
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Visitor.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get visitor by ID
  Future<Visitor?> getVisitorById(String visitorId) async {
    try {
      final url = Uri.parse('$baseUrl/$visitorId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Visitor.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get paginated visitors
  Future<List<Visitor>> getPaginatedVisitors({
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/paginatedVisitors?page=$page&size=$size');
      final response = await http.get(url);
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => Visitor.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get scoped paginated visitors
  Future<List<Visitor>> getScopedPaginatedVisitors({
    required String userId,
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/scopedPaginatedVisitors?userId=$userId&page=$page&size=$size',
      );
      final response = await http.get(url);
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'] ?? [];
      return content.map((json) => Visitor.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get visitor stats
  Future<Map<String, int>> getVisitorStats(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/stats?userId=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'total': data['totalVisitors'] ?? 0,
          'new': data['newVisitors'] ?? 0,
          'followedUp': data['followedUpVisitors'] ?? 0,
          'converted': data['convertedVisitors'] ?? 0,
          'dropped': data['droppedVisitors'] ?? 0,
        };
      } else {
        return {
          'total': 0,
          'new': 0,
          'followedUp': 0,
          'converted': 0,
          'dropped': 0,
        };
      }
    } catch (e) {
      return {
        'total': 0,
        'new': 0,
        'followedUp': 0,
        'converted': 0,
        'dropped': 0,
      };
    }
  }
}

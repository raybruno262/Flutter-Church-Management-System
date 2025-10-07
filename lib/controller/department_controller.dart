import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_churchcrm_system/constants.dart';
import '../model/department_model.dart';

class DepartmentController {
  final String baseUrl = '$baseHost/api/department';

  // Create department
  Future<String> createDepartment(Department department) async {
    try {
      final url = Uri.parse('$baseUrl/createDepartment');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(department.toJson()),
      );
      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Update department
  Future<String> updateDepartment(
    String departmentId,
    Department newDepartment,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/updateDepartment/$departmentId');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newDepartment.toJson()),
      );
      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Delete department
  Future<String> deleteDepartment(String departmentId) async {
    try {
      final url = Uri.parse('$baseUrl/deleteDepartment/$departmentId');
      final response = await http.delete(url);
      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Get all departments
  Future<List<Department>> getAllDepartments() async {
    try {
      final url = Uri.parse('$baseUrl/allDepartments');
      final response = await http.get(url);
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Department.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get paginated departments
  Future<List<Department>> getPaginatedDepartments({
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/getPaginatedDepartments?page=$page&size=$size',
      );
      final response = await http.get(url);
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => Department.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}

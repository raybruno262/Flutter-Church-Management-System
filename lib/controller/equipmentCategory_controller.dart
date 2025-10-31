import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_churchcrm_system/model/equipmentCategory_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:http_parser/http_parser.dart';

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

  // Upload Excel file for bulk equipment category creation - WEB COMPATIBLE
  Future<String> uploadExcelEquipmentCategory(PlatformFile platformFile) async {
    try {
      final url = Uri.parse('$baseUrl/uploadExcelEquipmentCategory');

      print('=== UPLOAD DEBUG ===');
      print('File name: ${platformFile.name}');
      print('File size: ${platformFile.size} bytes');
      print('Has bytes: ${platformFile.bytes != null}');

      // Check if we have file data
      if (platformFile.bytes == null) {
        print('ERROR: No file bytes available');
        return 'Status 7000: Could not read file data';
      }

      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add file using bytes (works on both web and mobile)
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          platformFile.bytes!,
          filename: platformFile.name,
          contentType: MediaType(
            'application',
            'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ),
      );

      print('Sending request to server...');

      // Send the request with timeout
      var streamedResponse = await request.send().timeout(
        Duration(seconds: 30),
      );

      print('Response status: ${streamedResponse.statusCode}');

      // Get the response
      var responseData = await streamedResponse.stream.bytesToString();

      print('Server response: $responseData');
      print('=== UPLOAD SUCCESS ===');

      return responseData;
    } on TimeoutException catch (e) {
      print('TIMEOUT ERROR: $e');
      return 'Status 7000: Request timeout';
    } catch (e) {
      print('UPLOAD ERROR: $e');
      print('Error type: ${e.runtimeType}');
      return 'Status 7000: Error uploading file: $e';
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

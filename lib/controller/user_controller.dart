import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import '../model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController {
  final String baseUrl = '$baseHost/api/users';

  // Create user
  Future<String> createUser(
    UserModel user, {
    required Uint8List profilePic,
    required String fileExtension,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/createrUser');
      final request = http.MultipartRequest('POST', url);

      // Attach user JSON
      request.files.add(
        http.MultipartFile.fromString(
          'user',
          jsonEncode(user.toJson()),
          filename: 'user.json',
          contentType: MediaType('application', 'json'),
        ),
      );

      // Attach image
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          profilePic,
          filename: 'profile.$fileExtension',
          contentType: MediaType('image', fileExtension.toLowerCase()),
        ),
      );

      final response = await request.send();
      return await response.stream.bytesToString();
    } catch (e) {
      return 'Status 7000';
    }
  }

  Future<String> updateUser(
    String userId,
    UserModel updatedUser, {
    required Uint8List profilePic,
    required String fileExtension,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/updateUser/$userId');
      final request = http.MultipartRequest('PUT', url);

      // Attach user JSON as a file part
      request.files.add(
        http.MultipartFile.fromString(
          'user',
          jsonEncode(updatedUser.toJson()),
          filename: 'user.json',
          contentType: MediaType('application', 'json'),
        ),
      );

      // Attach image file

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          profilePic,
          filename: 'profile.$fileExtension',
          contentType: MediaType('image', fileExtension.toLowerCase()),
        ),
      );

      final response = await request.send();
      return await response.stream.bytesToString();
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final url = Uri.parse('$baseUrl/allUsers');
      final response = await http.get(url);
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }



  // Get paginated users
  Future<List<UserModel>> getPaginatedUsers({
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/getPaginatedUsers?page=$page&size=$size');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> content = data['content'];
        return content.map((json) => UserModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }




  // Send login OTP
  Future<String> sendLoginOtp(String email, String password) async {
    try {
      final url = Uri.parse(
        '$baseUrl/sendLoginOtp?email=$email&Password=$password',
      );
      final response = await http.post(url);
      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Login with OTP
  Future<UserModel?> login({
    required String email,
    required String verifyCode,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/login?email=${Uri.encodeComponent(email)}&verifyCode=${Uri.encodeComponent(verifyCode)}&Password=${Uri.encodeComponent(password)}',
      );
      final response = await http.post(url);
      final body = response.body;
      try {
        final json = jsonDecode(body);
        return UserModel.fromJson(json);
      } catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Send password reset OTP
  Future<String> sendPasswordResetOtp(String email) async {
    try {
      final url = Uri.parse('$baseUrl/sendPasswordResetOtp?email=$email');
      final response = await http.post(url);
      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Reset password
  Future<String> resetPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/resetPassword?email=${Uri.encodeComponent(email)}&verificationCode=${Uri.encodeComponent(verificationCode)}&newPassword=${Uri.encodeComponent(newPassword)}',
      );
      final response = await http.post(url);
      return response.body;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final url = Uri.parse('$baseUrl/destroySession');
      await http.post(url);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('loggedInUser');
    } catch (e) {
      return null;
    }
  }

  // Load user from local storage
  Future<UserModel?> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('loggedInUser');
    if (jsonString != null) {
      return UserModel.fromJsonString(jsonString);
    }
    return null;
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import '../model/user_model.dart';

class UserController {
  final String baseUrl = '$baseHost/api/users';

  // Create user
  Future<String> createUser(UserModel user, {Uint8List? profilePic}) async {
    final url = Uri.parse('$baseUrl/createrUser');
    final request = http.MultipartRequest('POST', url);
    request.fields['user'] = jsonEncode(user.toJson());

    if (profilePic != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          profilePic,
          filename: 'profile.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final response = await request.send();
    return await response.stream.bytesToString();
  }

  // Update user
  Future<String> updateUser(
    String userId,
    UserModel updatedUser, {
    Uint8List? profilePic,
  }) async {
    final url = Uri.parse('$baseUrl/updateUser/$userId');
    final request = http.MultipartRequest('PUT', url);
    request.fields['user'] = jsonEncode(updatedUser.toJson());

    if (profilePic != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          profilePic,
          filename: 'profile.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final response = await request.send();
    return await response.stream.bytesToString();
  }

  // Disable user
  Future<String> disableUser(String userId) async {
    final url = Uri.parse('$baseUrl/disableUser/$userId');
    final response = await http.put(url);
    return response.body;
  }

  // Enable user
  Future<String> enableUser(String userId) async {
    final url = Uri.parse('$baseUrl/enableUser/$userId');
    final response = await http.put(url);
    return response.body;
  }

  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    final url = Uri.parse('$baseUrl/allUsers');
    final response = await http.get(url);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  // Get active users
  Future<List<UserModel>> getAllActiveUsers() async {
    final url = Uri.parse('$baseUrl/getAllActiveUsers');
    final response = await http.get(url);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  // Get inactive users
  Future<List<UserModel>> getAllInactiveUsers() async {
    final url = Uri.parse('$baseUrl/getAllInActiveUsers');
    final response = await http.get(url);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  // Get paginated users
  Future<List<UserModel>> getPaginatedUsers({
    int page = 0,
    int size = 5,
  }) async {
    final url = Uri.parse('$baseUrl/getPaginatedUsers?page=$page&size=$size');
    final response = await http.get(url);
    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> content = data['content'];
    return content.map((json) => UserModel.fromJson(json)).toList();
  }

  // Get paginated active users
  Future<List<UserModel>> getPaginatedActiveUsers({
    int page = 0,
    int size = 5,
  }) async {
    final url = Uri.parse(
      '$baseUrl/getPaginatedActiveUsers?page=$page&size=$size',
    );
    final response = await http.get(url);
    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> content = data['content'];
    return content.map((json) => UserModel.fromJson(json)).toList();
  }

  // Get paginated inactive users
  Future<List<UserModel>> getPaginatedInactiveUsers({
    int page = 0,
    int size = 5,
  }) async {
    final url = Uri.parse(
      '$baseUrl/getPaginatedInactiveUsers?page=$page&size=$size',
    );
    final response = await http.get(url);
    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> content = data['content'];
    return content.map((json) => UserModel.fromJson(json)).toList();
  }

  // Send login OTP
  Future<String> sendLoginOtp(String email, String password) async {
    final url = Uri.parse(
      '$baseUrl/sendLoginOtp?email=$email&Password=$password',
    );
    final response = await http.post(url);
    return response.body;
  }

  // Login with OTP
  Future<String> login({
    required String email,
    required String verifyCode,
    required String password,
  }) async {
    final url = Uri.parse(
      '$baseUrl/login?email=${Uri.encodeComponent(email)}&verifyCode=${Uri.encodeComponent(verifyCode)}&Password=${Uri.encodeComponent(password)}',
    );
    final response = await http.post(url);
    return response.body;
  }

  // Send password reset OTP
  Future<String> sendPasswordResetOtp(String email) async {
    final url = Uri.parse('$baseUrl/sendPasswordResetOtp?email=$email');
    final response = await http.post(url);
    return response.body;
  }

  // Reset password
  Future<String> resetPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
  }) async {
    final url = Uri.parse(
      '$baseUrl/resetPassword?email=$email&verificationCode=$verificationCode&newPassword=$newPassword',
    );
    final response = await http.post(url);
    return response.body;
  }

  // Destroy session
  Future<String> destroySession() async {
    final url = Uri.parse('$baseUrl/destroySession');
    final response = await http.post(url);
    return response.body;
  }
}

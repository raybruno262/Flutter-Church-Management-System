import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';

class UserController {
  final String baseUrl = 'http://localhost:8080/api/users';

  // Send login OTP
  Future<Map<String, dynamic>> sendLoginOtp(
    String email,
    String password,
  ) async {
    final url = Uri.parse(
      '$baseUrl/sendLoginOtp?email=$email&Password=$password',
    );
    final response = await http.post(url);
    return {'code': response.statusCode, 'message': response.body};
  }

  // Verify OTP and login
  Future<Map<String, dynamic>> login({
    required String email,
    required String verifyCode,
    required String password,
  }) async {
    final url = Uri.parse(
      '$baseUrl/login?email=$email&verifyCode=$verifyCode&Password=$password',
    );

    final response = await http.post(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data);
      return {'code': 1000, 'user': user, 'message': 'Status 1000'};
    } else {
      return {'code': response.statusCode, 'message': response.body};
    }
  }

  // Send forgot password OTP
  Future<Map<String, dynamic>> sendPasswordResetOtp(String email) async {
    final url = Uri.parse('$baseUrl/sendPasswordResetOtp?email=$email');
    final response = await http.post(url);
    return {'code': response.statusCode, 'message': response.body};
  }

  // Verify OTP and reset password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
  }) async {
    final url = Uri.parse(
      '$baseUrl/resetPassword?email=$email&verificationCode=$verificationCode&newPassword=$newPassword',
    );
    final response = await http.post(url);
    return {'code': response.statusCode, 'message': response.body};
  }
}

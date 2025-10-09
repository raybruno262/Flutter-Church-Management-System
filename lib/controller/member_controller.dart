import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import '../model/member_model.dart';

// create member
class MemberController {
  final String baseUrl = '$baseHost/api/members';

  Future<String> createMember(
    Member member, {
    required Uint8List profilePic,
    required String fileExtension,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/createMember');
      final request = http.MultipartRequest('POST', url);

      // Attach member JSON as a file
      request.files.add(
        http.MultipartFile.fromString(
          'member',
          jsonEncode(member.toJson()),
          filename: 'member.json',
          contentType: MediaType('application', 'json'),
        ),
      );

      // Attach profile picture
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          profilePic,
          filename: 'profile.$fileExtension',
          contentType: MediaType('image', fileExtension.toLowerCase()),
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      return responseBody;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Update member (multipart/form-data)
  Future<String> updateMember(
    String memberId,
    Member updatedMember, {
    Uint8List? profilePic,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/updateMember/$memberId');
      final request = http.MultipartRequest('PUT', url);
      request.fields['member'] = jsonEncode(updatedMember.toJson());

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
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Get all members
  Future<List<Member>> getAllMembers() async {
    try {
      final url = Uri.parse('$baseUrl/allMembers');
      final response = await http.get(url);
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Member.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get paginated members
  Future<List<Member>> getPaginatedMembers({int page = 0, int size = 5}) async {
    try {
      final url = Uri.parse('$baseUrl/paginatedMembers?page=$page&size=$size');
      final response = await http.get(url);
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => Member.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get scoped paginated members
  Future<List<Member>> getScopedPaginatedMembers({
    required String userId,
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/scopedPaginatedMembers?userId=$userId&page=$page&size=$size',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> content = data['content'] ?? [];

        return content.map((json) => Member.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get scoped birthday members for current month
  Future<List<Member>> getScopedBirthdayMembers({
    required String userId,
    int page = 0,
    int size = 5,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/scopedBirthdayMembers?userId=$userId&page=$page&size=$size',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> content = data['content'] ?? [];

        return content.map((json) => Member.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  //get member stats

  Future<Map<String, int>> getMemberStats(String userId) async {
    try {
      final url = Uri.parse('$baseHost/api/members/stats?userId=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return {
          'total': data['totalMembers'] ?? 0,
          'active': data['activeMembers'] ?? 0,
          'inactive': data['inactiveMembers'] ?? 0,
          'transferred': data['transferredMembers'] ?? 0,
        };
      } else {
        print('Failed to fetch stats: ${response.statusCode}');
        return {'total': 0, 'active': 0, 'inactive': 0, 'transferred': 0};
      }
    } catch (e) {
      print('Error fetching member stats: $e');
      return {'total': 0, 'active': 0, 'inactive': 0, 'transferred': 0};
    }
  }
}

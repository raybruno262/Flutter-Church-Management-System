// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:flutter_churchcrm_system/constants.dart';
// import '../model/member_model.dart';

// class MemberController {
//   final String baseUrl = '$baseHost/api/members';

//   // Create member (multipart/form-data)
//   Future<String> createMember(
//     Member member, {
//     Uint8List? profilePic,
//     String? fileExtension, // e.g. 'png', 'jpg', 'webp'
//   }) async {
//     try {
//       final url = Uri.parse('$baseUrl/createMember');
//       final request = http.MultipartRequest('POST', url);
//       request.fields['member'] = jsonEncode(member.toJson());

//       if (profilePic != null && fileExtension != null) {
//         final mimeType = _getMimeType(fileExtension);
//         request.files.add(
//           http.MultipartFile.fromBytes(
//             'file',
//             profilePic,
//             filename: 'profile.$fileExtension',
//             contentType: mimeType,
//           ),
//         );
//       }

//       final response = await request.send();
//       return await response.stream.bytesToString();
//     } catch (e) {
//       return 'Status 7000';
//     }
//   }

//   // Update member (multipart/form-data)
//   Future<String> updateMember(
//     String memberId,
//     Member updatedMember, {
//     Uint8List? profilePic,
//   }) async {
//     try {
//       final url = Uri.parse('$baseUrl/updateMember/$memberId');
//       final request = http.MultipartRequest('PUT', url);
//       request.fields['member'] = jsonEncode(updatedMember.toJson());

//       if (profilePic != null) {
//         request.files.add(
//           http.MultipartFile.fromBytes(
//             'file',
//             profilePic,
//             filename: 'profile.jpg',
//             contentType: MediaType('image', 'jpeg'),
//           ),
//         );
//       }

//       final response = await request.send();
//       return await response.stream.bytesToString();
//     } catch (e) {
//       return 'Status 7000';
//     }
//   }

//   // Get all members
//   Future<List<Member>> getAllMembers() async {
//     try {
//       final url = Uri.parse('$baseUrl/allMembers');
//       final response = await http.get(url);
//       final List<dynamic> data = jsonDecode(response.body);
//       return data.map((json) => Member.fromJson(json)).toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   // Get paginated members
//   Future<List<Member>> getPaginatedMembers({int page = 0, int size = 5}) async {
//     try {
//       final url = Uri.parse('$baseUrl/paginatedMembers?page=$page&size=$size');
//       final response = await http.get(url);
//       final Map<String, dynamic> data = jsonDecode(response.body);
//       final List<dynamic> content = data['content'];
//       return content.map((json) => Member.fromJson(json)).toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   // Get scoped paginated members
//   Future<List<Member>> getScopedPaginatedMembers({
//     int page = 0,
//     int size = 5,
//   }) async {
//     try {
//       final url = Uri.parse(
//         '$baseUrl/scopedPaginatedMembers?page=$page&size=$size',
//       );
//       final response = await http.get(url);
//       final Map<String, dynamic> data = jsonDecode(response.body);
//       final List<dynamic> content = data['content'];
//       return content.map((json) => Member.fromJson(json)).toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   // Get scoped birthday members for current month
//   Future<List<Member>> getScopedBirthdayMembers({
//     int page = 0,
//     int size = 5,
//   }) async {
//     try {
//       final url = Uri.parse(
//         '$baseUrl/scopedBirthdayMembers?page=$page&size=$size',
//       );
//       final response = await http.get(url);
//       final Map<String, dynamic> data = jsonDecode(response.body);
//       final List<dynamic> content = data['content'];
//       return content.map((json) => Member.fromJson(json)).toList();
//     } catch (e) {
//       return [];
//     }
//   }
// }

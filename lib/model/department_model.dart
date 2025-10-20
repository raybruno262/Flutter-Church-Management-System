import 'dart:convert';

class Department {
  final String? departmentId;
  final String name;

  Department({this.departmentId, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      departmentId: json['departmentId'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'departmentId': departmentId, 'name': name};
  }

  static Department fromJsonString(String jsonString) {
    return Department.fromJson(jsonDecode(jsonString));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

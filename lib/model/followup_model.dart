import 'dart:convert';

class FollowUp {
  final String? followUpDate; // formatted as MM/dd/yyyy
  final String method; // Call, Visit, SMS, WhatsApp
  final String outcome; // Interested, Needs Prayer, Converted, Not Interested
  final String notes; // description of the outcome
  final String followedUpBy; // name of the person who followed up

  FollowUp({
    this.followUpDate,
    required this.method,
    required this.outcome,
    required this.notes,
    required this.followedUpBy,
  });

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      followUpDate: json['followUpDate'],
      method: json['method'] ?? '',
      outcome: json['outcome'] ?? '',
      notes: json['notes'] ?? '',
      followedUpBy: json['followedUpBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'followUpDate': followUpDate,
      'method': method,
      'outcome': outcome,
      'notes': notes,
      'followedUpBy': followedUpBy,
    };
  }

  static FollowUp fromJsonString(String jsonString) {
    return FollowUp.fromJson(jsonDecode(jsonString));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

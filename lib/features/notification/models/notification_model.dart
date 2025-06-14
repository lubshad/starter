import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class NotificationModel {
  final int id;
  final String title;
  final String description;
  final String payload;
  final DateTime dateTime;
  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.payload,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'payload': payload,
      'dateTime': dateTime.toUtc().toString(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int,
      title: map['title'] ?? "",
      description: map['short_description'] ?? "",
      payload: map['user_url'] ?? "",
      dateTime: DateTime.parse(map['created_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

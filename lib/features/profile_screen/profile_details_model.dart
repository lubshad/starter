import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProfileDetailsModel {
  final String name;
  final String? image;
  final String? phone;
  final String program;
  final String semester;

  final String email;
  ProfileDetailsModel({
    required this.email,
    required this.name,
    this.image,
    this.phone,
    required this.program,
    required this.semester,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'name': name,
      'image': image,
      'phone': phone,
      'program': program,
      'semester': semester,
    };
  }

  factory ProfileDetailsModel.fromMap(Map<String, dynamic> map) {
    return ProfileDetailsModel(
      email: map["email"] as String,
      name: map['name'] as String,
      image: map['image'],
      phone: map['phone'],
      program: map['program'] as String,
      semester: map['semester'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileDetailsModel.fromJson(String source) =>
      ProfileDetailsModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

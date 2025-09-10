import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProfileDetailsModel {
  final String id ;
  final String name;
  final String? image;
  final String? phone;

  final String email;
  ProfileDetailsModel({
    required this.id, 
    required this.email,
    required this.name,
    this.image,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'name': name,
      'image': image,
      'phone': phone,
    };
  }

  factory ProfileDetailsModel.fromMap(Map<String, dynamic> map) {
    return ProfileDetailsModel(
      id: map['id'] ,
      email: map["email"] as String,
      name: map['name'] as String,
      image: map['image'],
      phone: map['phone'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileDetailsModel.fromJson(String source) =>
      ProfileDetailsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  ProfileDetailsModel copyWith({
    String? name,
    String? image,
    String? phone,
    String? program,
    String? semester,
    String? email,
    String? id,
  }) {
    return ProfileDetailsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}

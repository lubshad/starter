import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class NameId {
  final dynamic id;
  final dynamic name;
  dynamic secondary;
  dynamic third;
  NameId({
    required this.id,
    required this.name,
    this.secondary,
    this.third,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  static NameId? fromMap(map) {
    if (map == null || map is List) return null;
    return NameId(
      third: map["email"],
      id: map['id'] ?? 0,
      name: map['name'] ?? map["display_name"] ?? "",
      secondary: map['text'] ??
          map["color_code"] ??
          map["color"] ??
          map["image"] ??
          map["url"] ??
          map["selected"] ??
          "",
    );
  }

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(covariant NameId other) {
    if (identical(this, other)) return true;

    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'NameId(id: $id, name: $name, text: $secondary)';

  NameId copyWith({
    int? id,
    String? name,
    dynamic secondary,
    dynamic third,
  }) {
    return NameId(
      id: id ?? this.id,
      name: name ?? this.name,
      secondary: secondary ?? this.secondary,
      third: third ?? this.third,
    );
  }
}

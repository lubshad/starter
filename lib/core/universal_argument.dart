// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: prefer_null_aware_operators

class UniversalArgument {
  final int? id;
  final int? parentId;
  final int? childId;
  final int? page;
  final DateTime? updatedAt;
  final String? text;
  final int? pageSize;
  final dynamic extra;

  UniversalArgument(
      {this.id,
      this.parentId,
      this.extra,
      this.childId,
      this.page,
      this.pageSize,
      this.updatedAt,
      this.text});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'parentId': parentId,
      'childId': childId,
      "page": page,
      "updated_at": updatedAt,
      "text": text,
      "page_size": pageSize,
      "secondary": extra,
    };
  }

  factory UniversalArgument.fromMap(Map<String, dynamic> map) {
    return UniversalArgument(
        extra: map["extra"],
        pageSize: map["page_size"],
        text: map["text"],
        id: map['id'] != null ? map['id'] as int : null,
        parentId: map['parentId'] != null ? map['parentId'] as int : null,
        childId: map['childId'] != null ? map['childId'] as int : null,
        page: map["page"],
        updatedAt: map["updated_at"] == null
            ? null
            : DateTime.parse(map["updated_at"]));
  }

  factory UniversalArgument.fromquery(Map<String, dynamic> map) {
    return UniversalArgument(
        pageSize: map["page_size"] == "" ? null : int.parse(map["page_size"]),
        text: map["text"],
        extra: map["extra"],
        id: map['id'] != "" ? int.parse(map['id']) : null,
        parentId: map['parentId'] != "" ? int.parse(map['parentId']) : null,
        childId: map['childId'] != "" ? int.parse(map['childId']) : null,
        page: map['childId'] != "" ? int.parse(map["page"]) : null,
        updatedAt:
            map["updated_at"] == "" ? null : DateTime.parse(map["updated_at"]));
  }
  Map<String, dynamic> toquery() {
    final map = <String, dynamic>{
      "page_size": pageSize == null ? null : pageSize.toString(),
      'id': id != null ? id.toString() : null,
      'parentId': parentId == null ? null : parentId.toString(),
      'childId': childId == null ? null : childId.toString(),
      "page": page == null ? null : page.toString(),
      "updated_at": updatedAt == null ? null : updatedAt?.toIso8601String(),
      "text": text,
      "extra": extra,
    };
    return map;
  }

  UniversalArgument copyWith({
    int? id,
    int? parentId,
    int? childId,
    int? page,
    DateTime? updatedAt,
    String? text,
    int? pageSize,
    dynamic extra,
  }) {
    return UniversalArgument(
      extra: extra ?? this.extra,
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      childId: childId ?? this.childId,
      page: page ?? this.page,
      updatedAt: updatedAt ?? this.updatedAt,
      text: text ?? this.text,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class PaginationModel<T> {
  final bool isLastPage;
  final int? nextPage;
  final int? previousPage;
   List<T> newItems;
  final int totalCount;
  final dynamic extra;

  PaginationModel({
    this.extra,
    this.totalCount = 0,
    required this.isLastPage,
    required this.nextPage,
    required this.newItems,
    required this.previousPage,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'totalCount': totalCount,
      'isLastPage': isLastPage,
      'nextPage': nextPage,
      'newItems': newItems,
      "previousPage": previousPage,
    };
  }

  factory PaginationModel.fromMap(Map<String, dynamic> map, newItems,
      {dynamic extra}) {
    Uri? nextPageUrl = (map["next_page_url"] ?? map["next"]) == null
        ? null
        : Uri.tryParse(map["next_page_url"] ?? map["next"]);
    int? nextPage = nextPageUrl == null
        ? null
        : int.tryParse(nextPageUrl.queryParameters["page"].toString());
    Uri? previousPageUrl = (map["previous_page_url"] ?? map["previous"]) == null
        ? null
        : Uri.tryParse(map["previous_page_url"] ?? map["previous"]);
    int? previousPage = previousPageUrl == null
        ? null
        : int.tryParse(previousPageUrl.queryParameters["page"].toString());
    return PaginationModel<T>(
        extra: extra,
        isLastPage: map['isLastPage'] ?? nextPage == null,
        nextPage: map['nextPage'] ?? nextPage,
        newItems: newItems,
        totalCount: map['count'] ?? 0,
        previousPage: map["previousPage"] ?? previousPage);
  }
}

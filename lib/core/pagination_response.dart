class PaginationResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  const PaginationResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginationResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginationResponse<T>(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results:
          (json['results'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results,
    };
  }

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;
  int get totalPages =>
      results.isNotEmpty ? (count / results.length).ceil() : 0;
}

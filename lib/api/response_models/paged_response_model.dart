class PagedResponse<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final bool hasMore;

  PagedResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.hasMore,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawItems = (json['items'] as List? ?? []);
    return PagedResponse<T>(
      items: rawItems.map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      page: (json['page'] ?? 1) as int,
      pageSize: (json['pageSize'] ?? 20) as int,
      totalCount: (json['totalCount'] ?? 0) as int,
      hasMore: (json['hasMore'] ?? false) as bool,
    );
  }
}

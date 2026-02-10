class OrdersRequestModel {
  final int storeId;
  final DateTime startDate;
  final DateTime endDate;
  final int page;
  final int pageSize;
  final String? searchQuery;

  OrdersRequestModel({
    required this.storeId,
    required this.startDate,
    required this.endDate,
    this.page = 1,
    this.pageSize = 20,
    this.searchQuery,
  });

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'page': page,
      'page_size': pageSize,
      if (searchQuery != null && searchQuery!.isNotEmpty)
        'search_query': searchQuery,
    };
  }
}

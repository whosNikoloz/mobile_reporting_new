class ProductRestRequestModel {
  final DateTime asOfDate;
  final int storeId;
  final int page;
  final int pageSize;

  ProductRestRequestModel({
    required this.asOfDate,
    this.storeId = 0,
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toJson() => {
        'as_of_date': asOfDate.toIso8601String(),
        'store_id': storeId,
        'page': page,
        'page_size': pageSize,
      };
}

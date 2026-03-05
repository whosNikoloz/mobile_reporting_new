class ProductSalesSummaryRequestModel {
  final DateTime startDate;
  final DateTime endDate;
  final int storeId;
  final int page;
  final int pageSize;

  ProductSalesSummaryRequestModel({
    required this.startDate,
    required this.endDate,
    this.storeId = 0,
    this.page = 1,
    this.pageSize = 50,
  });

  Map<String, dynamic> toJson() => {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'store_id': storeId,
        'page': page,
        'page_size': pageSize,
      };
}

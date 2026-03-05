class StoreTransferDetailsRequestModel {
  final DateTime startDate;
  final DateTime endDate;
  final int fromStoreId;
  final int toStoreId;
  final int page;
  final int pageSize;

  StoreTransferDetailsRequestModel({
    required this.startDate,
    required this.endDate,
    this.fromStoreId = 0,
    this.toStoreId = 0,
    this.page = 1,
    this.pageSize = 100,
  });

  Map<String, dynamic> toJson() => {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'from_store_id': fromStoreId,
        'to_store_id': toStoreId,
        'page': page,
        'page_size': pageSize,
      };
}
